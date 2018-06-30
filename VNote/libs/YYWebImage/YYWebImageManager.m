//
//  YYWebImageManager.m
//  YYWebImage <https://github.com/ibireme/YYWebImage>
//
//  Created by ibireme on 15/2/19.
//  Copyright (c) 2015 ibireme.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import "YYWebImageManager.h"
#import "YYImageCache.h"
#import "YYWebImageOperation.h"
#import <objc/runtime.h>

#define kNetworkIndicatorDelay (1/30.0)


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


@interface _YYWebImageApplicationNetworkIndicatorInfo : NSObject
@property (nonatomic, assign) NSInteger count;
@property (nonatomic, strong) NSTimer *timer;
@end
@implementation _YYWebImageApplicationNetworkIndicatorInfo
@end

@implementation YYWebImageManager

/**
 *  单例类
    在生成的时候会生成一个YYImageCache单例类,会新建一个NSOperationQueue
 *
 *  @return <#return value description#>
 */
+ (instancetype)sharedManager {
    static YYWebImageManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        YYImageCache *cache = [YYImageCache sharedCache];
        NSOperationQueue *queue = [NSOperationQueue new];
        if ([queue respondsToSelector:@selector(setQualityOfService:)]) {
            queue.qualityOfService = NSQualityOfServiceBackground;
        }
        manager = [[self alloc] initWithCache:cache queue:queue];
    });
    return manager;
}

- (instancetype)init {
    @throw [NSException exceptionWithName:@"YYWebImageManager init error" reason:@"Use the designated initializer to init." userInfo:nil];
    return [self initWithCache:nil queue:nil];
}

/**
 *  构造方法,本单例类生成的时候会调用这个方法,传入两个参数,一个缓存,一个队列
 *
 *
 *  @return <#return value description#>
 */
- (instancetype)initWithCache:(YYImageCache *)cache queue:(NSOperationQueue *)queue{
    self = [super init];
    if (!self) return nil;
    //这里很好的遵循了苹果规范,初始化的时候先调用父类,同时初始化了_cache,_queue,_timeout,_header这些属性
    _cache = cache;
    _queue = queue;
    _timeout = 15.0;
    _headers = @{ @"Accept" : @"image/webp,image/*;q=0.8" };
    return self;
}

/**
 *  这里就是具体的下载请求方法了
 *
 *  @param url        图片URL
 *  @param options    加载模式
 *  @param progress   进度
 *  @param transform  下载完成前对图片进行操作形变的block
 *  @param completion 下载完成的block
 *
 *  @return 一个YYWebImageOperation对象
 */
- (YYWebImageOperation *)requestImageWithURL:(NSURL *)url
                                     options:(YYWebImageOptions)options
                                    progress:(YYWebImageProgressBlock)progress
                                   transform:(YYWebImageTransformBlock)transform
                                  completion:(YYWebImageCompletionBlock)completion {
    
    //1.先生成一个request,并且根据传入参数生成request参数
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.timeoutInterval = _timeout;
    request.HTTPShouldHandleCookies = (options & YYWebImageOptionHandleCookies) != 0;
    //设置请求头
    request.allHTTPHeaderFields = [self headersForURL:url];
    request.HTTPShouldUsePipelining = YES;
    //设置缓存策略,如果加载图片模式存在并且 =YYWebImageOptionUseNSURLCache,使用NSURLRequestUseProtocolCachePolicy策略,否则的话使用NSURLRequestReloadIgnoringLocalCacheData
    //说明:NSURLRequestUseProtocolCachePolicy这个是系统默认的缓存策略,缓存不存在,就去重新服务端拉去,如果存在的话,根据下一步请求的Cache-control字段来进行下一步的操作,比如如果cache-control = must-revalidata,那么还会去询问服务端是否有数据更新,有的话就拉取新数据,没有就返回缓存
    //    NSURLRequestReloadIgnoringLocalCacheData:忽略本地缓存,每次都去请求服务端
    request.cachePolicy = (options & YYWebImageOptionUseNSURLCache) ?
        NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData;
    
    //2.根据request,option,cache,cacheKey,progress,transformblock,completionblock生成一个YYWebImageOperation对象
    YYWebImageOperation *operation = [[YYWebImageOperation alloc] initWithRequest:request
                                                                          options:options
                                                                            cache:_cache
                                                                         cacheKey:[self cacheKeyForURL:url]
                                                                         progress:progress
                                                                        transform:transform ? transform : _sharedTransformBlock
                                                                       completion:completion];
    //如果有用户名跟密码,operation的credential属性通过系统提供的NSURLCredential类生成
    if (_username && _password) {
        operation.credential = [NSURLCredential credentialWithUser:_username password:_password persistence:NSURLCredentialPersistenceForSession];
    }
    //如果operation初始化成功
    if (operation) {
        NSOperationQueue *queue = _queue;
        //并且存在一个queue
        if (queue) {
            //就把生成的operation添加到队列中
            [queue addOperation:operation];
        } else {
        //如果queue不存在,直接开始这个operation
            [operation start];
        }
    }
    return operation;
}

/**
 *  设置请求头的方法
    可以看出在每一步操作的时候都进行了判空处理,这对于第三方库来说尤为重要,因为不知道使用者会怎么非法的调用你的api
 *
 *  @param url <#url description#>
 *
 *  @return <#return value description#>
 */
- (NSDictionary *)headersForURL:(NSURL *)url {
    if (!url) return nil;
    //如果有_headersFilter这个blcok就把url跟_headers传递回去并且返回这个block,没有的返回_headers
    return _headersFilter ? _headersFilter(url, _headers) : _headers;
}

/**
 *  生成cackeKey的方法
 *
 *  如果这个cacheKeyFilterblock存在的话,就把url作为参数传入block并且返回这个block,_cacheKeyFilter这个block的返回值为NSString类型,
    反之如果不存在的话直接以url的完整地址作为key
 *
 *  @return cacheKey字符串
 */
- (NSString *)cacheKeyForURL:(NSURL *)url {
    if (!url) return nil;
    return _cacheKeyFilter ? _cacheKeyFilter(url) : url.absoluteString;
}


/**
 *  以下是网络状态指示器部分的代码
 */
#pragma mark Network Indicator

+ (_YYWebImageApplicationNetworkIndicatorInfo *)_networkIndicatorInfo {
    return objc_getAssociatedObject(self, @selector(_networkIndicatorInfo));
}

+ (void)_setNetworkIndicatorInfo:(_YYWebImageApplicationNetworkIndicatorInfo *)info {
    objc_setAssociatedObject(self, @selector(_networkIndicatorInfo), info, OBJC_ASSOCIATION_RETAIN);
}

/**
 *  设置网络状态,默认1/30秒会加载一次
 *
 */
+ (void)_delaySetActivity:(NSTimer *)timer {
    UIApplication *app = _YYSharedApplication();
    if (!app) return;
    
    NSNumber *visiable = timer.userInfo;
    if (app.networkActivityIndicatorVisible != visiable.boolValue) {
        [app setNetworkActivityIndicatorVisible:visiable.boolValue];
    }
    [timer invalidate];
}

/**
 *  修改数量
 *
 *  @param delta <#delta description#>
 */
+ (void)_changeNetworkActivityCount:(NSInteger)delta {
    if (!_YYSharedApplication()) return;
    
    //定义一个无参无反block,在这个block中操作计数加减
    void (^block)() = ^{
        _YYWebImageApplicationNetworkIndicatorInfo *info = [self _networkIndicatorInfo];
        if (!info) {
            info = [_YYWebImageApplicationNetworkIndicatorInfo new];
            [self _setNetworkIndicatorInfo:info];
        }
        NSInteger count = info.count;
        count += delta;
        info.count = count;
        [info.timer invalidate];//这里紧紧销毁计时器,不置nil会不会销毁失败?
        //每1/30秒执行一次timer,同时把info.count作为参数传递过去,
        //其实这里有个思考,初始化就调度这个NSTimer,设置repeats属性为YES,不需要每次增加网络数量跟减少活跃数量的时候都新初始化这个timer,需要发起的时候调用setFireDate来执行开始与停止定时器工作,岂不是效率更高?
        info.timer = [NSTimer timerWithTimeInterval:kNetworkIndicatorDelay target:self selector:@selector(_delaySetActivity:) userInfo:@(info.count > 0) repeats:NO];
        [[NSRunLoop mainRunLoop] addTimer:info.timer forMode:NSRunLoopCommonModes];
    };
    //如果在主线程,调用block
    if ([NSThread isMainThread]) {
        block();
    } else {
        //如果不在,获取主线程调用block
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

/**
 *  增加活跃网络数量
 */
+ (void)incrementNetworkActivityCount {
    [self _changeNetworkActivityCount:1];
}
/**
 *  减少
 */
+ (void)decrementNetworkActivityCount {
    [self _changeNetworkActivityCount:-1];
}
/**
 *  获取当前的活跃请求数量
 *
 *  @return <#return value description#>
 */
+ (NSInteger)currentNetworkActivityCount {
    _YYWebImageApplicationNetworkIndicatorInfo *info = [self _networkIndicatorInfo];
    return info.count;
}

@end
