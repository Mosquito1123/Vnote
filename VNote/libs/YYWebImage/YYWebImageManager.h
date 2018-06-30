//
//  YYWebImageManager.h
//  YYWebImage <https://github.com/ibireme/YYWebImage>
//
//  Created by ibireme on 15/2/19.
//  Copyright (c) 2015 ibireme.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import <UIKit/UIKit.h>

#if __has_include(<YYWebImage/YYWebImage.h>)
#import <YYWebImage/YYImageCache.h>
#else
#import "YYImageCache.h"
#endif

@class YYWebImageOperation;


/// The options to control image operation.
///控制图片请求的模式
typedef NS_OPTIONS(NSUInteger, YYWebImageOptions) {
    
    /// Show network activity on status bar when download image.
    ///当下载图片的时候会在状态栏显示一个当前网络状况
    YYWebImageOptionShowNetworkActivity = 1 << 0,
    
    /// Display progressive/interlaced/baseline image during download (same as web browser).
    ///能够像浏览器一样显示一个逐渐显示的图片,有三种方式:换换显示,中间带交叉效果,基于基线显示.这里可以看demo理解三种模式的区别
    YYWebImageOptionProgressive = 1 << 1,
    
    /// Display blurred progressive JPEG or interlaced PNG image during download.
    /// This will ignore baseline image for better user experience.
    ///下载的时候显示一个模糊的渐渐显示的JPEG图片,或者一个交错显示的PNG图片,具体效果还是看demo
    ///这种模式会忽略baseline这种显示模式来获得更好的用户体验
    YYWebImageOptionProgressiveBlur = 1 << 2,
    
    /// Use NSURLCache instead of YYImageCache.
    ///使用NSURLCache来代替YYImageCache
    YYWebImageOptionUseNSURLCache = 1 << 3,
    
    /// Allows untrusted SSL ceriticates.
    ///允许未受信任的SSL证书,PS:基于我的理解以及对比SDWebImage,这种模式一般用户调试过程,不用于生产过程
    YYWebImageOptionAllowInvalidSSLCertificates = 1 << 4,
    
    /// Allows background task to download image when app is in background.
    ///app进入后台的时候允许后台下载图片
    YYWebImageOptionAllowBackgroundTask = 1 << 5,
    
    /// Handles cookies stored in NSHTTPCookieStore.
    ///把cookies存储进NSHTTPCookieStore
    YYWebImageOptionHandleCookies = 1 << 6,
    
    /// Load the image from remote and refresh the image cache.
    ///从远程下载图片并且刷新图片缓存,这种模式可以用于更换了图片内容,但是图片URL不替换
    YYWebImageOptionRefreshImageCache = 1 << 7,
    
    /// Do not load image from/to disk cache.
    ///不从硬盘缓存加载图片,同时也不会把图片缓存进磁盘
    YYWebImageOptionIgnoreDiskCache = 1 << 8,
    
    /// Do not change the view's image before set a new URL to it.
    ///当没有通过一个URL下载到一个新的图片的时候不去修改图片
    YYWebImageOptionIgnorePlaceHolder = 1 << 9,
    
    /// Ignore image decoding.
    /// This may used for image downloading without display.
    ///忽略图片解码
    ///这种模式可能用于下载的时候并不去显示该图片
    YYWebImageOptionIgnoreImageDecoding = 1 << 10,
    
    /// Ignore multi-frame image decoding.
    /// This will handle the GIF/APNG/WebP/ICO image as single frame image.
    ///忽略多frame图片解码
    ///这种模式会讲 GIF/APNG/WebP/ICO图片转换为单一frame的图片,开发中如果需求图片固定显示大小,这个模式可能会有用
    YYWebImageOptionIgnoreAnimatedImage = 1 << 11,
    
    /// Set the image to view with a fade animation.
    /// This will add a "fade" animation on image view's layer for better user experience.
    ///设置图片的时候带有一个fade的动画效果
    ///会给view's layer添加一个淡入淡出动画效果来获取更好的用户体验
    YYWebImageOptionSetImageWithFadeAnimation = 1 << 12,
    
    /// Do not set the image to the view when image fetch complete.
    /// You may set the image manually.
    ///当图片下载完成之前不去设置它
    ///你可以手动设置图片
    YYWebImageOptionAvoidSetImage = 1 << 13,
    
    /// This flag will add the URL to a blacklist (in memory) when the URL fail to be downloaded,
    /// so the library won't keep trying.
    ///这种模式会把URL加进黑名单当下载失败的时候,黑名单存储在内存中,所以这种模式不会尝试重复下载
    YYWebImageOptionIgnoreFailedURL = 1 << 14,
};

/// Indicated where the image came from.
///用来告诉我们图片来源
typedef NS_ENUM(NSUInteger, YYWebImageFromType) {
    
    /// No value.空
    YYWebImageFromNone = 0,
    
    /// Fetched from memory cache immediately.
    /// If you called "setImageWithURL:..." and the image is already in memory,
    /// then you will get this value at the same call.
    ///立刻从内存中查找图片,如果你调用了"setImageWithURL..."并且图片已经存在于内存,你会从相同的回调里面得到这个值
    YYWebImageFromMemoryCacheFast,
    
    /// Fetched from memory cache. ///从内存中来
    YYWebImageFromMemoryCache,
    
    /// Fetched from disk cache. ///从磁盘中来
    YYWebImageFromDiskCache,
    
    /// Fetched from remote (web or file path).///从远程下载的,可以是web或者一个路径
    YYWebImageFromRemote,
};

/// Indicated image fetch complete stage.
///用来告诉我们图片下载的完成度的
typedef NS_ENUM(NSInteger, YYWebImageStage) {
    
    /// Incomplete, progressive image.///未完成,带进度的image
    YYWebImageStageProgress  = -1,
    
    /// Cancelled.///已经取消了
    YYWebImageStageCancelled = 0,
    
    /// Finished (succeed or failed).///已经结束,可能是成功或者失败
    YYWebImageStageFinished  = 1,
};


/**
 The block invoked in remote image fetch progress.
 
 @param receivedSize Current received size in bytes.
 @param expectedSize Expected total size in bytes (-1 means unknown).
 */
///从远程下载完成过程的回调,参数receivedSize是已经下载的大小,expectedSize是总共大小,因此可以通过receivedSize/expectedSize获得progress,如果expectedSize = -1代表着不知道一共有多大
typedef void(^YYWebImageProgressBlock)(NSInteger receivedSize, NSInteger expectedSize);

/**
 The block invoked before remote image fetch finished to do additional image process.
 
 @discussion This block will be invoked before `YYWebImageCompletionBlock` to give
 you a chance to do additional image process (such as resize or crop). If there's
 no need to transform the image, just return the `image` parameter.
 
 @example You can clip the image, blur it and add rounded corners with these code:
    ^(UIImage *image, NSURL *url) {
        // Maybe you need to create an @autoreleasepool to limit memory cost.
        image = [image yy_imageByResizeToSize:CGSizeMake(100, 100) contentMode:UIViewContentModeScaleAspectFill];
        image = [image yy_imageByBlurRadius:20 tintColor:nil tintMode:kCGBlendModeNormal saturation:1.2 maskImage:nil];
        image = [image yy_imageByRoundCornerRadius:5];
        return image;
    }
 
 @param image The image fetched from url.
 @param url   The image url (remote or local file path).
 @return The transformed image.
 */
/**
 图片从远程下载完成之前会执行这个block,用来执行一些额外的操作
 @discussion 当'YYWebImageCompletionBlock'这个完成度额回调在下载完成之前会执行这个回调用来给你一个机会做一些额外的处理,比如用来修改图片尺寸等.如果这里不需要对图片进行transform处理,只会返回image这一个参数
 @example 你可以裁剪/模糊图片,或者添加一些边角通过以下代码:
 ^(UIImage *image, NSURL *url){
 //可能你需要创建一个 @autoreleasepool来限制内存开销
 image = [image yy_imageByResizeToSize:CGSizeMake(100, 100) contentMode:UIViewContentModeScaleAspectFill];
 image = [image yy_imageByBlurRadius:20 tintColor:nil tintMode:kCGBlendModeNormal saturation:1.2 maskImage:nil];
 image = [image yy_imageByRoundCornerRadius:5];
 return image;
 }
 */
typedef UIImage *(^YYWebImageTransformBlock)(UIImage *image, NSURL *url);

/**
 The block invoked when image fetch finished or cancelled.
 
 @param image       The image.
 @param url         The image url (remote or local file path).
 @param from        Where the image came from.
 @param error       Error during image fetching.
 @param finished    If the operation is cancelled, this value is NO, otherwise YES.
 */
/**
 这个block会在当图片下载完成或者取消的时候调用
 
 @param image       The image.
 @param url         图片url,远程或者本地路径
 @param from        图片从哪来,
 @param error       图片下载中的错误
 @param finished    如果请求取消掉了,返回NO,其他是YES
 */

typedef void (^YYWebImageCompletionBlock)(UIImage *image, NSURL *url, YYWebImageFromType from, YYWebImageStage stage, NSError *error);




/**
 A manager to create and manage web image operation.
 */
/**
 *  用来创建和管理网络图片任务的管理器,这个类其实就一个作用,管理生成一个YYWebImageOperation实例
 */
@interface YYWebImageManager : NSObject

/**
 Returns global YYWebImageManager instance.
 
 不需要多解释,返回单例类
 @return YYWebImageManager shared instance.
 */
+ (instancetype)sharedManager;

/**
 Creates a manager with an image cache and operation queue.
 
 @param cache  Image cache used by manager (pass nil to avoid image cache).
 @param queue  The operation queue on which image operations are scheduled and run
                (pass nil to make the new operation start immediately without queue).
 @return A new manager.
 */
/**
 *  生成一个manager,带有缓存与操作队列
 *
 *  @param cache 图片缓存用到的manager,
 *  @param queue 图片请求,调度运行的请求队列
 *
 *  @return 一个新的manager
 */
- (instancetype)initWithCache:(YYImageCache *)cache queue:(NSOperationQueue *)queue NS_DESIGNATED_INITIALIZER;

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;

/**
 Creates and returns a new image operation, the operation will start immediately.
 
 @param url        The image url (remote or local file path).
 @param options    The options to control image operation.
 @param progress   Progress block which will be invoked on background thread (pass nil to avoid).
 @param transform  Transform block which will be invoked on background thread  (pass nil to avoid).
 @param completion Completion block which will be invoked on background thread  (pass nil to avoid).
 @return A new image operation.
 */
/**
 *  创建返回一个新的operation,这个operation会立刻开始执行
 *
 *  @param url        图片url,可以是远程或者本地路径
 *  @param options    控制下载的option
 *  @param progress   进度block,会在后台线程的时候调用,传空的话会禁用此特性
 *  @param transform  进入后台线程会调用此block,传空禁用此block
 *  @param completion 进入后台线程会调用此block,传空禁用此block
 *
 *  @return 一个新的图片operation
 */
- (YYWebImageOperation *)requestImageWithURL:(NSURL *)url
                                     options:(YYWebImageOptions)options
                                    progress:(YYWebImageProgressBlock)progress
                                   transform:(YYWebImageTransformBlock)transform
                                  completion:(YYWebImageCompletionBlock)completion;

/**
 The image cache used by image operation. 
 You can set it to nil to avoid image cache.
 */
/**
 *  图片请求用到的缓存,可以设置为nil来禁用缓存
 */
@property (nonatomic, strong) YYImageCache *cache;

/**
 The operation queue on which image operations are scheduled and run.
 You can set it to nil to make the new operation start immediately without queue.
 
 You can use this queue to control maximum number of concurrent operations, to obtain 
 the status of the current operations, or to cancel all operations in this manager.
 */
/**
 *  图片的请求调度运行的队列
    你不通过队列新建一个新的operation的时候可以给这个值置为nil
    
    你可以用这个队列来控制请求的最大值最小值,获得当前操作队列的状态值,或者来取消这个manager中所有的operation
 */
@property (nonatomic, strong) NSOperationQueue *queue;

/**
 The shared transform block to process image. Default is nil.
 
 When called `requestImageWithURL:options:progress:transform:completion` and
 the `transform` is nil, this block will be used.
 */
/**
 *  默认值为nil,共享的图片变换的过程,
    当调用`requestImageWithURL:options:progress:transform:completion`并且`transform`为nil时,这个block才有用
 */
@property (nonatomic, copy) YYWebImageTransformBlock sharedTransformBlock;

/**
 The image request timeout interval in seconds. Default is 15.
 */
/**
 *  请求超时时间,默认15秒
 */
@property (nonatomic, assign) NSTimeInterval timeout;

/**
 The username used by NSURLCredential, default is nil.
 */
/**
 *  NSURLCredential使用的用户名,默认为nil
 */
@property (nonatomic, strong) NSString *username;

/**
 The password used by NSURLCredential, default is nil.
 */
/**
 *  同上,密码,默认为nil
 */
@property (nonatomic, strong) NSString *password;

/**
 The image HTTP request header. Default is "Accept:image/webp,image/\*;q=0.8".
 */
/**
 *  图片TTTP的请求头,默认是"Accept:image/webp,image/\*;q=0.8"
 */
@property (nonatomic, copy) NSDictionary *headers;

/**
 A block which will be invoked for each image HTTP request to do additional
 HTTP header process. Default is nil.
 
 Use this block to add or remove HTTP header field for a specified URL.
 */
/**
 *  每个图片http请求做额外的HTTP header操作的时候会调用这个block,默认为nil
 */
@property (nonatomic, copy) NSDictionary *(^headersFilter)(NSURL *url, NSDictionary *header);

/**
 A block which will be invoked for each image operation. Default is nil.
 
 Use this block to provide a custom image cache key for a specified URL.
 */
/**
 *  每个图片的操作都会调用这个block,默认为nil
    使用这个block能够给URL提供一个自定义的的图片
 */
@property (nonatomic, copy) NSString *(^cacheKeyFilter)(NSURL *url);

/**
 Returns the HTTP headers for a specified URL.
 
 @param url A specified URL.
 @return HTTP headers.
 */
/**
 *  返回URL的HTTP headers
 *
 *  @param url 当前URL
 *
 *  @return http header
 */
- (NSDictionary *)headersForURL:(NSURL *)url;

/**
 Returns the cache key for a specified URL.
 
 @param url A specified URL
 @return Cache key used in YYImageCache.
 */
/**
 *  给URL返回一个cacheKey
 *
 *  @param url 该URL
 *
 *  @return cache key在YYImageCache中有用到
 */
- (NSString *)cacheKeyForURL:(NSURL *)url;


/**
 Increments the number of active network requests.
 If this number was zero before incrementing, this will start animating the
 status bar network activity indicator.
 
 This method is thread safe.
 
 This method has no effect in App Extension.
 */
/**
 *  增加活跃的网络请求数量
    如果在增加前数量为0,那么会在状态来开始有一个网络菊花动画
    该方法是线程安全的
    该方法不会对APP扩展产生影响
 */
+ (void)incrementNetworkActivityCount;

/**
 Decrements the number of active network requests.
 If this number becomes zero after decrementing, this will stop animating the
 status bar network activity indicator.
 
 This method is thread safe.
 
 This method has no effect in App Extension.
 */
/**
 *  与上面对应,减少活跃的网络请求数量,如果执行完毕之后数量变为0,那么会停止在状态栏的网络指示器动画
    线程安全
    不会影响APP扩展
 */
+ (void)decrementNetworkActivityCount;

/**
 Get current number of active network requests.
 
 This method is thread safe.
 
 This method has no effect in App Extension.
 */
/**
 *  获取当前活跃的网络请求数量
 *  线程安全
    不会影响APP扩展
 *  @return
 */
+ (NSInteger)currentNetworkActivityCount;

@end
