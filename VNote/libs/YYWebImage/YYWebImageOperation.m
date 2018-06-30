//
//  YYWebImageOperation.m
//  YYWebImage <https://github.com/ibireme/YYWebImage>
//
//  Created by ibireme on 15/2/15.
//  Copyright (c) 2015 ibireme.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import "YYWebImageOperation.h"
#import "UIImage+YYWebImage.h"
#import <ImageIO/ImageIO.h>
#import <libkern/OSAtomic.h>

#if __has_include(<YYImage/YYImage.h>)
#import <YYImage/YYImage.h>
#else
#import "YYImage.h"
#endif

#if __has_include("YYDispatchQueuePool.h")
#import "YYDispatchQueuePool.h"
#endif

#define MIN_PROGRESSIVE_TIME_INTERVAL 0.2
#define MIN_PROGRESSIVE_BLUR_TIME_INTERVAL 0.4


/// Returns nil in App Extension.
static UIApplication *_YYSharedApplication() {
    static BOOL isAppExtension = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class cls = NSClassFromString(@"UIApplication");
        if(!cls || ![cls respondsToSelector:@selector(sharedApplication)]) isAppExtension = YES;
        if ([[[NSBundle mainBundle] bundlePath] hasSuffix:@".appex"]) isAppExtension = YES;
    });
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    return isAppExtension ? nil : [UIApplication performSelector:@selector(sharedApplication)];
#pragma clang diagnostic pop
}

/// Returns YES if the right-bottom pixel is filled.
///当最右下角那个像素也被填充完毕后就返回YES
static BOOL YYCGImageLastPixelFilled(CGImageRef image) {
    if (!image) return NO;
    size_t width = CGImageGetWidth(image);
    size_t height = CGImageGetHeight(image);
    if (width == 0 || height == 0) return NO;
    CGContextRef ctx = CGBitmapContextCreate(NULL, 1, 1, 8, 0, YYCGColorSpaceGetDeviceRGB(), kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrderDefault);
    if (!ctx) return NO;
    CGContextDrawImage(ctx, CGRectMake( -(int)width + 1, 0, width, height), image);
    uint8_t *bytes = CGBitmapContextGetData(ctx);
    BOOL isAlpha = bytes && bytes[0] == 0;
    CFRelease(ctx);
    return !isAlpha;
}

/// Returns JPEG SOS (Start Of Scan) Marker
static NSData *JPEGSOSMarker() {
    // "Start Of Scan" Marker
    static NSData *marker = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        uint8_t bytes[2] = {0xFF, 0xDA};
        marker = [NSData dataWithBytes:bytes length:2];
    });
    return marker;
}


static NSMutableSet *URLBlacklist;//url黑名单,是一个集合
static OSSpinLock URLBlacklistLock;//黑名单锁,OSSpinLock(自旋锁)大概是iOS中效率最高的一种锁了

/**
 *  初始化URL黑名单,使用了单例保证仅仅会创建一次,同时使用了自旋锁保证了多个地方同时进行黑名单读写操作的时候不会出错并且性能高效
 */
static void URLBlacklistInit() {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        URLBlacklist = [NSMutableSet new];
        URLBlacklistLock = OS_SPINLOCK_INIT;
    });
}

/**
 *  判断黑名单是否包含某个url的函数
 */
static BOOL URLBlackListContains(NSURL *url) {
    if (!url || url == (id)[NSNull null]) return NO;
    URLBlacklistInit();
    //初始化黑名单之后,在调用containsObject方法前后都对黑名单进行加锁处理
    OSSpinLockLock(&URLBlacklistLock);
    BOOL contains = [URLBlacklist containsObject:url];
    OSSpinLockUnlock(&URLBlacklistLock);
    return contains;
}

/**
 *  把url添加进黑名单
 *
 *  @param url 
 */
static void URLInBlackListAdd(NSURL *url) {
    if (!url || url == (id)[NSNull null]) return;
    URLBlacklistInit();
    OSSpinLockLock(&URLBlacklistLock);
    [URLBlacklist addObject:url];
    OSSpinLockUnlock(&URLBlacklistLock);
}


/// A proxy used to hold a weak object.用来保持weak属性对象的协议
@interface _YYWebImageWeakProxy : NSProxy
@property (nonatomic, weak, readonly) id target;
- (instancetype)initWithTarget:(id)target;
+ (instancetype)proxyWithTarget:(id)target;
@end

@implementation _YYWebImageWeakProxy
//这里主要是重写了proxy类的方法,指向了自定义的target
//对象构造方法
- (instancetype)initWithTarget:(id)target {
    _target = target;
    return self;
}
//类的构造方法
+ (instancetype)proxyWithTarget:(id)target {
    return [[_YYWebImageWeakProxy alloc] initWithTarget:target];
}
- (id)forwardingTargetForSelector:(SEL)selector {
    return _target;
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    void *null = NULL;
    [invocation setReturnValue:&null];
}
- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
    return [NSObject instanceMethodSignatureForSelector:@selector(init)];
}
- (BOOL)respondsToSelector:(SEL)aSelector {
    return [_target respondsToSelector:aSelector];
}
- (BOOL)isEqual:(id)object {
    return [_target isEqual:object];
}
- (NSUInteger)hash {
    return [_target hash];
}
- (Class)superclass {
    return [_target superclass];
}
- (Class)class {
    return [_target class];
}
- (BOOL)isKindOfClass:(Class)aClass {
    return [_target isKindOfClass:aClass];
}
- (BOOL)isMemberOfClass:(Class)aClass {
    return [_target isMemberOfClass:aClass];
}
- (BOOL)conformsToProtocol:(Protocol *)aProtocol {
    return [_target conformsToProtocol:aProtocol];
}
- (BOOL)isProxy {
    return YES;
}
- (NSString *)description {
    return [_target description];
}
- (NSString *)debugDescription {
    return [_target debugDescription];
}
@end

/**
 *  YYWebImageOperation的具体实现,遵循NSURLConnectionDelegate方法
 */
@interface YYWebImageOperation() <NSURLConnectionDelegate>
/**
 *  这里四个BOOL值是operation的四个状态,
 */
/**
 *  是否执行
 */
@property (readwrite, getter=isExecuting) BOOL executing;
/**
 *  是否结束
 */
@property (readwrite, getter=isFinished) BOOL finished;
/**
 *  是否取消,
 */
@property (readwrite, getter=isCancelled) BOOL cancelled;
/**
 *  是否开始
 */
@property (readwrite, getter=isStarted) BOOL started;
/**
 *  递归锁
 */
@property (nonatomic, strong) NSRecursiveLock *lock;

@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSMutableData *data;
/**
 *  数据的实际大小
 */
@property (nonatomic, assign) NSInteger expectedSize;
/**
 *  开启后台任务需要的
 */
@property (nonatomic, assign) UIBackgroundTaskIdentifier taskID;

@property (nonatomic, assign) NSTimeInterval lastProgressiveDecodeTimestamp;
/**
 *  带进度的渐进式解码
 */
@property (nonatomic, strong) YYImageDecoder *progressiveDecoder;
/**
 *  是否忽略渐进式
 */
@property (nonatomic, assign) BOOL progressiveIgnored;
/**
 *  是否表明是渐进式加载
 */
@property (nonatomic, assign) BOOL progressiveDetected;
@property (nonatomic, assign) NSUInteger progressiveScanedLength;
@property (nonatomic, assign) NSUInteger progressiveDisplayCount;

/**
 *  这三个block在YYWebImageManager里面有注释
 */
@property (nonatomic, copy) YYWebImageProgressBlock progress;
@property (nonatomic, copy) YYWebImageTransformBlock transform;
@property (nonatomic, copy) YYWebImageCompletionBlock completion;
@end


@implementation YYWebImageOperation
@synthesize executing = _executing;
@synthesize finished = _finished;
@synthesize cancelled = _cancelled;

/// Network thread entry point.
+ (void)_networkThreadMain:(id)object {
    @autoreleasepool {
        [[NSThread currentThread] setName:@"com.ibireme.webimage.request"];
        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        [runLoop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
        [runLoop run];
    }
}

/// Global image request network thread, used by NSURLConnection delegate.
///这里是一个全局的网络请求线程,提供给conllection的代理使用的
+ (NSThread *)_networkThread {
    static NSThread *thread = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        thread = [[NSThread alloc] initWithTarget:self selector:@selector(_networkThreadMain:) object:nil];
        if ([thread respondsToSelector:@selector(setQualityOfService:)]) {
            thread.qualityOfService = NSQualityOfServiceBackground;
        }
        [thread start];
    });
    return thread;
}

/// Global image queue, used for image reading and decoding.
///全局图片线程,用于读取图片解码
+ (dispatch_queue_t)_imageQueue {
#ifdef YYDispatchQueuePool_h
    return YYDispatchQueueGetForQOS(NSQualityOfServiceUtility);
#else
    //最大线程数
    #define MAX_QUEUE_COUNT 16
    static int queueCount;
    static dispatch_queue_t queues[MAX_QUEUE_COUNT];
    static dispatch_once_t onceToken;
    static int32_t counter = 0;
    dispatch_once(&onceToken, ^{
        queueCount = (int)[NSProcessInfo processInfo].activeProcessorCount;
        //如果线程数小于1,返回1,否则返回queueCount或者MAX_QUEUE_COUNT,取决于MAX_QUEUE_COUNT有没有值
        queueCount = queueCount < 1 ? 1 : queueCount > MAX_QUEUE_COUNT ? MAX_QUEUE_COUNT : queueCount;
        
        if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0) {
            for (NSUInteger i = 0; i < queueCount; i++) {
                dispatch_queue_attr_t attr = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_UTILITY, 0);
                queues[i] = dispatch_queue_create("com.ibireme.image.decode", attr);
            }
        } else {
            for (NSUInteger i = 0; i < queueCount; i++) {
                queues[i] = dispatch_queue_create("com.ibireme.image.decode", DISPATCH_QUEUE_SERIAL);
                dispatch_set_target_queue(queues[i], dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0));
            }
        }
    });
    int32_t cur = OSAtomicIncrement32(&counter);
    if (cur < 0) cur = -cur;
    return queues[(cur) % queueCount];
    #undef MAX_QUEUE_COUNT
#endif
}

/**
 *  初始化,失败的话会抛出异常
 *
 *  @return <#return value description#>
 */
- (instancetype)init {
    @throw [NSException exceptionWithName:@"YYWebImageOperation init error" reason:@"YYWebImageOperation must be initialized with a request. Use the designated initializer to init." userInfo:nil];
    return [self initWithRequest:nil options:0 cache:nil cacheKey:nil progress:nil transform:nil completion:nil];
}

/**
 *  构造方法
 *
 *  @param request    请求
 *  @param options    option
 *  @param cache      缓存
 *  @param cacheKey   缓存key
 *  @param progress   进入
 *  @param transform  预处理
 *  @param completion 完成
 *
 *  @return <#return value description#>
 */
- (instancetype)initWithRequest:(NSURLRequest *)request
                        options:(YYWebImageOptions)options
                          cache:(YYImageCache *)cache
                       cacheKey:(NSString *)cacheKey
                       progress:(YYWebImageProgressBlock)progress
                      transform:(YYWebImageTransformBlock)transform
                     completion:(YYWebImageCompletionBlock)completion {
    self = [super init];
    if (!self) return nil;
    if (!request) return nil;
    _request = request;
    _options = options;
    _cache = cache;
    //缓存key存在就使用,不存在使用url全路径
    _cacheKey = cacheKey ? cacheKey : request.URL.absoluteString;
    _shouldUseCredentialStorage = YES;
    _progress = progress;
    _transform = transform;
    _completion = completion;
    
    _executing = NO;
    _finished = NO;
    _cancelled = NO;
    _taskID = UIBackgroundTaskInvalid;
    return self;
}

/**
 *  析构方法里面使用了递归锁防止死锁,因为请求可能是有多个的.
    这个方法里面的操作可以保证开启了新的操作队列不会被旧的影响,同时把该清理的状态都归位完毕
 */
- (void)dealloc {
    [_lock lock];
    if (_taskID != UIBackgroundTaskInvalid) {
        [_YYSharedApplication() endBackgroundTask:_taskID];
        _taskID = UIBackgroundTaskInvalid;
    }
    
    
    //如果正在执行,设置取消为YES,结束为YES
    if ([self isExecuting]) {
        self.cancelled = YES;
        self.finished = YES;
        //如果存在连接,取消它,
        if (_connection) {
            [_connection cancel];
            
            //如果文件URL可达并且option是YYWebImageOptionShowNetworkActivity,那么请求数量-1
            if (![_request.URL isFileURL] && (_options & YYWebImageOptionShowNetworkActivity)) {
                [YYWebImageManager decrementNetworkActivityCount];
            }
        }
        //如果完成的回调存在,开启一个自动释放池,把参数传空,全置为nil,
        if (_completion) {
            @autoreleasepool {
                _completion(nil, _request.URL, YYWebImageFromNone, YYWebImageStageCancelled, nil);
            }
        }
    }
    [_lock unlock];
}

- (void)_endBackgroundTask {
    [_lock lock];
    if (_taskID != UIBackgroundTaskInvalid) {
        [_YYSharedApplication() endBackgroundTask:_taskID];
        _taskID = UIBackgroundTaskInvalid;
    }
    [_lock unlock];
}

#pragma mark - Runs in operation thread
/**
 *  结束,设置正在执行为NO,结束为YES
 */
- (void)_finish {
    self.executing = NO;
    self.finished = YES;
    [self _endBackgroundTask];
}

// runs on network thread
//开启一个操作,
- (void)_startOperation {
    //如果取消了直接返回,开启一个自动释放池完成以下操作
    if ([self isCancelled]) return;
    @autoreleasepool {
        // get image from cache
        //如果缓存存在,并且option不等于使用NSURLCache,并且option不是刷新缓存,那么直接通过缓存key从缓存中取取图片,同时设置缓存类型为内存缓存
        if (_cache &&
            !(_options & YYWebImageOptionUseNSURLCache) &&
            !(_options & YYWebImageOptionRefreshImageCache)) {
            UIImage *image = [_cache getImageForKey:_cacheKey withType:YYImageCacheTypeMemory];
            if (image) {//取到了图片
                [_lock lock];
            
                if (![self isCancelled]) {//没有取消,
                    //如果已经完成,把图片,图片url,缓存类型,下载结果通过block传递回去
                    if (_completion) _completion(image, _request.URL, YYWebImageFromMemoryCache, YYWebImageStageFinished, nil);
                }
                //调用结束方法
                [self _finish];
                [_lock unlock];
                return;
            }
            //如果下载模式不等于YYWebImageOptionIgnoreDiskCache
            if (!(_options & YYWebImageOptionIgnoreDiskCache)) {
                __weak typeof(self) _self = self;
                //开启一个同步的线程
                dispatch_async([self.class _imageQueue], ^{
                    __strong typeof(_self) self = _self;
                    if (!self || [self isCancelled]) return;//判空处理
                    //直接从磁盘缓存中通过cachekey获取图片
                    UIImage *image = [self.cache getImageForKey:self.cacheKey withType:YYImageCacheTypeDisk];
                    //如果取到了图片
                    if (image) {
                        //先把图片再存进内存缓存
                        [self.cache setImage:image imageData:nil forKey:self.cacheKey withType:YYImageCacheTypeMemory];
                        //在网络线程调用_didReceiveImageFromDiskCache方法
                        [self performSelector:@selector(_didReceiveImageFromDiskCache:) onThread:[self.class _networkThread] withObject:image waitUntilDone:NO];
                    } else {
                    //没有取到图片,就开始在网络线程,开始请求
                        [self performSelector:@selector(_startRequest:) onThread:[self.class _networkThread] withObject:nil waitUntilDone:NO];
                    }
                });
                return;
            }
        }
    }
    //在网络线程立刻开始请求
    [self performSelector:@selector(_startRequest:) onThread:[self.class _networkThread] withObject:nil waitUntilDone:NO];
}

// runs on network thread
//这个方法会确保跑在网络请求线程
- (void)_startRequest:(id)object {
    if ([self isCancelled]) return;
    @autoreleasepool {
        //如果模式是YYWebImageOptionIgnoreFailedURL,并且黑名单里面存在这个URL,
        if ((_options & YYWebImageOptionIgnoreFailedURL) && URLBlackListContains(_request.URL)) {
            //生成一个error
            NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorFileDoesNotExist userInfo:@{ NSLocalizedDescriptionKey : @"Failed to load URL, blacklisted." }];
            [_lock lock];
            //把error以及合适的参数传递给完成的回调,
            if (![self isCancelled]) {
                if (_completion) _completion(nil, _request.URL, YYWebImageFromNone, YYWebImageStageFinished, error);
            }
            [self _finish];
            [_lock unlock];
            return;
        }
        
        //如果url是可达的
        //这步计算文件size的
        if (_request.URL.isFileURL) {
            NSArray *keys = @[NSURLFileSizeKey];
            NSDictionary *attr = [_request.URL resourceValuesForKeys:keys error:nil];
            NSNumber *fileSize = attr[NSURLFileSizeKey];
            _expectedSize = fileSize ? fileSize.unsignedIntegerValue : -1;
        }
        
        // request image from web
        //开始下载了,先锁一下
        [_lock lock];
        if (![self isCancelled]) {
            //开启一个connection连接
            _connection = [[NSURLConnection alloc] initWithRequest:_request delegate:[_YYWebImageWeakProxy proxyWithTarget:self]];
            //url不可用,并且模式是YYWebImageOptionShowNetworkActivity,给网络请求数量+1
            if (![_request.URL isFileURL] && (_options & YYWebImageOptionShowNetworkActivity)) {
                [YYWebImageManager incrementNetworkActivityCount];
            }
        }
        //结果出来了,解锁
        [_lock unlock];
    }
}

// runs on network thread, called from outer "cancel"
/**
 *  跑在网络线程上,被另外一个"cancel方法调用"
 */
- (void)_cancelOperation {
    @autoreleasepool {
        if (_connection) {
            
            //url不可用并且模式是YYWebImageOptionShowNetworkActivity,请求数量-1
            if (![_request.URL isFileURL] && (_options & YYWebImageOptionShowNetworkActivity)) {
                [YYWebImageManager decrementNetworkActivityCount];
            }
        }
        //取消操作并置空
        [_connection cancel];
        _connection = nil;
        //如果实现了完成的block,把相应参数与状态传递回去
        if (_completion) _completion(nil, _request.URL, YYWebImageFromNone, YYWebImageStageCancelled, nil);
        [self _endBackgroundTask];
    }
}


// runs on network thread
//从磁盘缓存中接受图片
- (void)_didReceiveImageFromDiskCache:(UIImage *)image {
    @autoreleasepool {
        [_lock lock];
        if (![self isCancelled]) {
            if (image) {
                //如果有完成的回调,则传递回去,标记为磁盘缓存
                if (_completion) _completion(image, _request.URL, YYWebImageFromDiskCache, YYWebImageStageFinished, nil);
                [self _finish];
            } else {
                [self _startRequest:nil];
            }
        }
        [_lock unlock];
    }
}

/**
 *  从网络下载的图片
 *
 *  @param image <#image description#>
 */
- (void)_didReceiveImageFromWeb:(UIImage *)image {
    @autoreleasepool {
        [_lock lock];
        if (![self isCancelled]) {
            if (_cache) {
                //有图片 或者 模式是刷新缓存的
                if (image || (_options & YYWebImageOptionRefreshImageCache)) {
                    NSData *data = _data;
                    //开一个异步线程,把图片同时存进磁盘与内存缓存
                    dispatch_async([YYWebImageOperation _imageQueue], ^{
                        [_cache setImage:image imageData:data forKey:_cacheKey withType:YYImageCacheTypeAll];
                    });
                }
            }
            _data = nil;
            NSError *error = nil;
            //如果没有图片
            if (!image) {
                error = [NSError errorWithDomain:@"com.ibireme.image" code:-1 userInfo:@{ NSLocalizedDescriptionKey : @"Web image decode fail." }];
                //模式是YYWebImageOptionIgnoreFailedURL的话,如果黑名单包括URL,给一个错误警告,否则把它加到黑名单
                if (_options & YYWebImageOptionIgnoreFailedURL) {
                    if (URLBlackListContains(_request.URL)) {
                        error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorFileDoesNotExist userInfo:@{ NSLocalizedDescriptionKey : @"Failed to load URL, blacklisted." }];
                    } else {
                        URLInBlackListAdd(_request.URL);
                    }
                }
            }
            //把结果与error同时传递给block
            if (_completion) _completion(image, _request.URL, YYWebImageFromRemote, YYWebImageStageFinished, error);
            //结束
            [self _finish];
        }
        [_lock unlock];
    }
}

//NSURLConnectionDelegate放在,跑在请求线程上面
#pragma mark - NSURLConnectionDelegate runs in operation thread

- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection {
    return _shouldUseCredentialStorage;
}

//即将发送请求验证,验证授权的一大堆乱七八糟东西,暂时不去管
- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    @autoreleasepool {
        if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
            if (!(_options & YYWebImageOptionAllowInvalidSSLCertificates) &&
                [challenge.sender respondsToSelector:@selector(performDefaultHandlingForAuthenticationChallenge:)]) {
                [challenge.sender performDefaultHandlingForAuthenticationChallenge:challenge];
            } else {
                NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
                [[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
            }
        } else {
            if ([challenge previousFailureCount] == 0) {
                if (_credential) {
                    [[challenge sender] useCredential:_credential forAuthenticationChallenge:challenge];
                } else {
                    [[challenge sender] continueWithoutCredentialForAuthenticationChallenge:challenge];
                }
            } else {
                [[challenge sender] continueWithoutCredentialForAuthenticationChallenge:challenge];
            }
        }
    }
}

//即将缓存请求结果
- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    //如果为空,直接返回
    if (!cachedResponse) return cachedResponse;
    //如果模式=YYWebImageOptionUseNSURLCache,返回这个cache相应结果
    if (_options & YYWebImageOptionUseNSURLCache) {
        return cachedResponse;
    } else {
        
        //这里就是忽略NSURLCache了,作者有一套自己的缓存机制YYCache
        // ignore NSURLCache
        return nil;
    }
}

//请求已经收到相应
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    @autoreleasepool {
        NSError *error = nil;
        //先判断是不是NSHTTPURLResponse相应类,是的话,先把状态码记录下来,如果出错,记录一个error
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            NSHTTPURLResponse *httpResponse = (id) response;
            NSInteger statusCode = httpResponse.statusCode;
            if (statusCode >= 400 || statusCode == 304) {
                error = [NSError errorWithDomain:NSURLErrorDomain code:statusCode userInfo:nil];
            }
        }
        //有error了,取消连接,调用连接失败的方法同时把error传递过去
        if (error) {
            [_connection cancel];
            [self connection:_connection didFailWithError:error];
        } else {
            //通过length判断有内容,赋值
            if (response.expectedContentLength) {
                _expectedSize = (NSInteger)response.expectedContentLength;
                //没有直接返回-1
                if (_expectedSize < 0) _expectedSize = -1;
            }
            
            //给进度block赋值
            _data = [NSMutableData dataWithCapacity:_expectedSize > 0 ? _expectedSize : 0];
            if (_progress) {
                [_lock lock];
                if ([self isCancelled]) _progress(0, _expectedSize);
                [_lock unlock];
            }
        }
    }
}

//收到数据回调
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    @autoreleasepool {
        //如果取消了,直接返回
        [_lock lock];
        BOOL canceled = [self isCancelled];
        [_lock unlock];
        if (canceled) return;
        
        //如果data存在,拼接data,把计算data大小传递给进度block
        if (data) [_data appendData:data];
        if (_progress) {
            [_lock lock];
            if (![self isCancelled]) {
                _progress(_data.length, _expectedSize);
            }
            [_lock unlock];
        }
        
        /*--------------------------- progressive ----------------------------*/
        //根据模式判断是否需要返回进度以及是否需要渐进显示
        BOOL progressive = (_options & YYWebImageOptionProgressive) > 0;
        BOOL progressiveBlur = (_options & YYWebImageOptionProgressiveBlur) > 0;
        //如果没有实现了完成block,或者没有任何进度,直接返回
        if (!_completion || !(progressive || progressiveBlur)) return;
        //如果data长度小于一个字节,直接返回
        if (data.length <= 16) return;
        //其实就是length大于1,直接返回
        if (_expectedSize > 0 && data.length >= _expectedSize * 0.99) return;
        //如果设置了忽略渐进式加载,直接返回
        if (_progressiveIgnored) return;
        
        
        NSTimeInterval min = progressiveBlur ? MIN_PROGRESSIVE_BLUR_TIME_INTERVAL : MIN_PROGRESSIVE_TIME_INTERVAL;
        NSTimeInterval now = CACurrentMediaTime();
        if (now - _lastProgressiveDecodeTimestamp < min) return;
        
        //没有解码,初始化一个解码器
        if (!_progressiveDecoder) {
            _progressiveDecoder = [[YYImageDecoder alloc] initWithScale:[UIScreen mainScreen].scale];
        }
        //解码器更新数据
        [_progressiveDecoder updateData:_data final:NO];
        //如果调用取消方法,直接返回
        if ([self isCancelled]) return;
        
        
        if (_progressiveDecoder.type == YYImageTypeUnknown ||
            _progressiveDecoder.type == YYImageTypeWebP ||
            _progressiveDecoder.type == YYImageTypeOther) {
            _progressiveDecoder = nil;
            _progressiveIgnored = YES;
            return;
        }
        
        //只支持渐进式的JPEG图像和interlanced类型的PNG图像
        if (progressiveBlur) { // only support progressive JPEG and interlaced PNG
            if (_progressiveDecoder.type != YYImageTypeJPEG &&
                _progressiveDecoder.type != YYImageTypePNG) {
                _progressiveDecoder = nil;
                _progressiveIgnored = YES;
                return;
            }
        }
        if (_progressiveDecoder.frameCount == 0) return;
        //不存在渐进显示的话
        if (!progressiveBlur) {
            //从解码中获取图片帧
            YYImageFrame *frame = [_progressiveDecoder frameAtIndex:0 decodeForDisplay:YES];
            if (frame.image) {
                [_lock lock];
                if (![self isCancelled]) {
                    //没有取消,把数据传递给完成block,
                    _completion(frame.image, _request.URL, YYWebImageFromRemote, YYWebImageStageProgress, nil);
                    //给_lastProgressiveDecodeTimestamp赋值
                    _lastProgressiveDecodeTimestamp = now;
                }
                [_lock unlock];
            }
            return;
        } else {
            //解码之后发现是JPEG格式的
            if (_progressiveDecoder.type == YYImageTypeJPEG) {
                //如果表明了不是渐进式加载
                if (!_progressiveDetected) {
                    //从解码中取值
                    NSDictionary *dic = [_progressiveDecoder framePropertiesAtIndex:0];
                    NSDictionary *jpeg = dic[(id)kCGImagePropertyJFIFDictionary];
                    NSNumber *isProg = jpeg[(id)kCGImagePropertyJFIFIsProgressive];
                    if (!isProg.boolValue) {
                        _progressiveIgnored = YES;
                        _progressiveDecoder = nil;
                        return;
                    }
                    _progressiveDetected = YES;
                }
                //缩放长度为 接收到数据length - _progressiveScanedLength - 4
                NSInteger scanLength = (NSInteger)_data.length - (NSInteger)_progressiveScanedLength - 4;
                //如果<=2,直接返回
                if (scanLength <= 2) return;
                NSRange scanRange = NSMakeRange(_progressiveScanedLength, scanLength);
                NSRange markerRange = [_data rangeOfData:JPEGSOSMarker() options:kNilOptions range:scanRange];
                _progressiveScanedLength = _data.length;
                if (markerRange.location == NSNotFound) return;
                if ([self isCancelled]) return;
                
            } else if (_progressiveDecoder.type == YYImageTypePNG) {//PNG类型图片
                if (!_progressiveDetected) {
                    //从解码中取值,解码,赋值
                    NSDictionary *dic = [_progressiveDecoder framePropertiesAtIndex:0];
                    NSDictionary *png = dic[(id)kCGImagePropertyPNGDictionary];
                    NSNumber *isProg = png[(id)kCGImagePropertyPNGInterlaceType];
                    if (!isProg.boolValue) {
                        _progressiveIgnored = YES;
                        _progressiveDecoder = nil;
                        return;
                    }
                    _progressiveDetected = YES;
                }
            }
            
            YYImageFrame *frame = [_progressiveDecoder frameAtIndex:0 decodeForDisplay:YES];
            UIImage *image = frame.image;
            if (!image) return;
            //再次检查是否取消了
            if ([self isCancelled]) return;
            
            //最后一个像素没有填充完毕,以为没有下载成功,返回
            if (!YYCGImageLastPixelFilled(image.CGImage)) return;
            //进度++
            _progressiveDisplayCount++;
            
            CGFloat radius = 32;
            if (_expectedSize > 0) {
                radius *= 1.0 / (3 * _data.length / (CGFloat)_expectedSize + 0.6) - 0.25;
            } else {
                radius /= (_progressiveDisplayCount);
            }
            //处理图片
            image = [image yy_imageByBlurRadius:radius tintColor:nil tintMode:0 saturation:1 maskImage:nil];
            
            if (image) {
                [_lock lock];
                if (![self isCancelled]) {
                    //图片存在,给完成block赋值
                    _completion(image, _request.URL, YYWebImageFromRemote, YYWebImageStageProgress, nil);
                    //给时间戳赋值
                    _lastProgressiveDecodeTimestamp = now;
                }
                [_lock unlock];
            }
        }
    }
}

//连接已经结束加载
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    @autoreleasepool {
        [_lock lock];
        _connection = nil;
        if (![self isCancelled]) {
            __weak typeof(self) _self = self;
            //开启一个异步线程
            dispatch_async([self.class _imageQueue], ^{
                __strong typeof(_self) self = _self;
                if (!self) return;
                //通过是否是YYWebImageOptionIgnoreImageDecoding模式判断是否需要解码
                BOOL shouldDecode = (self.options & YYWebImageOptionIgnoreImageDecoding) == 0;
                //通过YYWebImageOptionIgnoreAnimatedImage模式判断是否需要显示动画小姑
                BOOL allowAnimation = (self.options & YYWebImageOptionIgnoreAnimatedImage) == 0;
                UIImage *image;
                BOOL hasAnimation = NO;
                //如果允许动画,通过YYImage这个类加载图片
                if (allowAnimation) {
                    image = [[YYImage alloc] initWithData:self.data scale:[UIScreen mainScreen].scale];
                    //如果需要解码,就解码了0.0
                    if (shouldDecode) image = [image yy_imageByDecoded];
                    //操作动画
                    if ([((YYImage *)image) animatedImageFrameCount] > 1) {
                        hasAnimation = YES;
                    }
                    //不允许动画
                } else {
                    //解码
                    YYImageDecoder *decoder = [YYImageDecoder decoderWithData:self.data scale:[UIScreen mainScreen].scale];
                    //直接取图片
                    image = [decoder frameAtIndex:0 decodeForDisplay:shouldDecode].image;
                }
                
                /*
                 If the image has animation, save the original image data to disk cache.
                 If the image is not PNG or JPEG, re-encode the image to PNG or JPEG for
                 better decoding performance.
                 */
                //如果是动图,保存原始图片数据到磁盘缓存,如果图片不是PNG或者JPEG格式,把图片转码成PNG或者JPEG格式,此举是为了得到更好的解码表现O.O
                YYImageType imageType = YYImageDetectType((__bridge CFDataRef)self.data);
                switch (imageType) {
                    case YYImageTypeJPEG:
                    case YYImageTypeGIF:
                    case YYImageTypePNG:
                    case YYImageTypeWebP: { // save to disk cache,以上这几种图片村早磁盘
                        if (!hasAnimation) {
                            if (imageType == YYImageTypeGIF ||
                                imageType == YYImageTypeWebP) {
                                //没有动图,并且图片类型是GIF或者WebP,清空数据,给缓存转码
                                self.data = nil; // clear the data, re-encode for disk cache
                            }
                        }
                    } break;
                    default: {
                        self.data = nil; // clear the data, re-encode for disk cache
                    } break;
                }
                if ([self isCancelled]) return;//还要判断,自定义NSOperation真的好麻烦
                
                //如果预处理block在,并且有图片
                if (self.transform && image) {
                    //传递回调
                    UIImage *newImage = self.transform(image, self.request.URL);
                    //图片错了,清空
                    if (newImage != image) {
                        self.data = nil;
                    }
                    //正确GET
                    image = newImage;
                    if ([self isCancelled]) return;
                }
                
                //调用_didReceiveImageFromWeb方法表明从网络上下载的图片
                [self performSelector:@selector(_didReceiveImageFromWeb:) onThread:[self.class _networkThread] withObject:image waitUntilDone:NO];
            });
            //如果图片URL不可用,并且模式是YYWebImageOptionShowNetworkActivity,网络请求数量-1
            if (![self.request.URL isFileURL] && (self.options & YYWebImageOptionShowNetworkActivity)) {
                [YYWebImageManager decrementNetworkActivityCount];
            }
        }
        [_lock unlock];
    }
}

//连接失败
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    @autoreleasepool {
        [_lock lock];
        if (![self isCancelled]) {
            //把失败信息也传递给完成block,因为失败也算完成了
            if (_completion) {
                _completion(nil, _request.URL, YYWebImageFromNone, YYWebImageStageFinished, error);
            }
            _connection = nil;
            _data = nil;
            //如果地址不可用,并且是YYWebImageOptionShowNetworkActivity模式,网络请求数量-1
            if (![_request.URL isFileURL] && (_options & YYWebImageOptionShowNetworkActivity)) {
                [YYWebImageManager decrementNetworkActivityCount];
            }
            //手动调一下结束方法
            [self _finish];
            
            //如果模式是忽略错误URL:YYWebImageOptionIgnoreFailedURL
            if (_options & YYWebImageOptionIgnoreFailedURL) {
                if (error.code != NSURLErrorNotConnectedToInternet &&
                    error.code != NSURLErrorCancelled &&
                    error.code != NSURLErrorTimedOut &&
                    error.code != NSURLErrorUserCancelledAuthentication) {
                    //加入黑名单
                    URLInBlackListAdd(_request.URL);
                }
            }
        }
        [_lock unlock];
    }
}

#pragma mark - Override NSOperation
//下面都是重写的NSOperation的方法,自定义NSOperation需要这些操作
/**
 *  开始这个NSOperation
 */
- (void)start {
    @autoreleasepool {
        [_lock lock];
        self.started = YES;//赋值开始标记为YES
        if ([self isCancelled]) {
            //如果这时候被取消了,调用取消方法
            [self performSelector:@selector(_cancelOperation) onThread:[[self class] _networkThread] withObject:nil waitUntilDone:NO modes:@[NSDefaultRunLoopMode]];
            self.finished = YES;//标记结束位YES
            //或者如果在准备开始,并且没有结束,并且没有运行中,执行以下操作
        } else if ([self isReady] && ![self isFinished] && ![self isExecuting]) {
            //请求失败
            if (!_request) {
                self.finished = YES;//记录结束
                if (_completion) {
                    //把错误信息传递给block
                    NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorFileDoesNotExist userInfo:@{NSLocalizedDescriptionKey:@"request in nil"}];
                    _completion(nil, _request.URL, YYWebImageFromNone, YYWebImageStageFinished, error);
                }
            } else {
                //设置正在执行为YES
                self.executing = YES;
                //调用开始方法
                [self performSelector:@selector(_startOperation) onThread:[[self class] _networkThread] withObject:nil waitUntilDone:NO modes:@[NSDefaultRunLoopMode]];
                //如果模式为YYWebImageOptionAllowBackgroundTask并且在后台,后台下载
                if ((_options & YYWebImageOptionAllowBackgroundTask) && _YYSharedApplication()) {
                    __weak __typeof__ (self) _self = self;
                    if (_taskID == UIBackgroundTaskInvalid) {
                        _taskID = [_YYSharedApplication() beginBackgroundTaskWithExpirationHandler:^{
                            __strong __typeof (_self) self = _self;
                            if (self) {
                                [self cancel];
                                self.finished = YES;
                            }
                        }];
                    }
                }
            }
        }
        [_lock unlock];
    }
}

//取消方法
- (void)cancel {
    [_lock lock];
    //先检查是不是取消了,没有取消调用父类取消,设置自己取消为YES
    if (![self isCancelled]) {
        [super cancel];
        self.cancelled = YES;
        //如果正在执行中,设置执行中为NO,调用取消
        if ([self isExecuting]) {
            self.executing = NO;
            [self performSelector:@selector(_cancelOperation) onThread:[[self class] _networkThread] withObject:nil waitUntilDone:NO modes:@[NSDefaultRunLoopMode]];
        }
        //如果已经开始,直接标记结束,不做其他处理
        if (self.started) {
            self.finished = YES;
        }
    }
    [_lock unlock];
}

//手动实现KVO为了监听"isExecuting"值
- (void)setExecuting:(BOOL)executing {
    [_lock lock];
    if (_executing != executing) {
        [self willChangeValueForKey:@"isExecuting"];
        _executing = executing;
        [self didChangeValueForKey:@"isExecuting"];
    }
    [_lock unlock];
}
//以下这些get,set方法简单的赋值,
- (BOOL)isExecuting {
    [_lock lock];
    BOOL executing = _executing;
    [_lock unlock];
    return executing;
}

- (void)setFinished:(BOOL)finished {
    [_lock lock];
    if (_finished != finished) {
        [self willChangeValueForKey:@"isFinished"];
        _finished = finished;
        [self didChangeValueForKey:@"isFinished"];
    }
    [_lock unlock];
}

- (BOOL)isFinished {
    [_lock lock];
    BOOL finished = _finished;
    [_lock unlock];
    return finished;
}

- (void)setCancelled:(BOOL)cancelled {
    [_lock lock];
    if (_cancelled != cancelled) {
        [self willChangeValueForKey:@"isCancelled"];
        _cancelled = cancelled;
        [self didChangeValueForKey:@"isCancelled"];
    }
    [_lock unlock];
}

//cancel方法需要经常的去调用检测是否取消,因为不能够实时的检测
- (BOOL)isCancelled {
    [_lock lock];
    BOOL cancelled = _cancelled;
    [_lock unlock];
    return cancelled;
}

//设置为并行
- (BOOL)isConcurrent {
    return YES;
}

//设置为异步的
- (BOOL)isAsynchronous {
    return YES;
}

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key {
    if ([key isEqualToString:@"isExecuting"] ||
        [key isEqualToString:@"isFinished"] ||
        [key isEqualToString:@"isCancelled"]) {
        return NO;
    }
    return [super automaticallyNotifiesObserversForKey:key];
}

//重写desc方法方便调试
- (NSString *)description {
    NSMutableString *string = [NSMutableString stringWithFormat:@"<%@: %p ",self.class, self];
    [string appendFormat:@" executing:%@", [self isExecuting] ? @"YES" : @"NO"];
    [string appendFormat:@" finished:%@", [self isFinished] ? @"YES" : @"NO"];
    [string appendFormat:@" cancelled:%@", [self isCancelled] ? @"YES" : @"NO"];
    [string appendString:@">"];
    return string;
}

@end
