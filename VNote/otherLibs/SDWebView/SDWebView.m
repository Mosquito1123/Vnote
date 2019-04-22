//
//  SDWebView.m
//  YTXEducation
//
//  Created by 薛林 on 17/2/25.
//  Copyright © 2017年 YunTianXia. All rights reserved.
//

#import "SDWebView.h"
#import <Foundation/Foundation.h>
#import "SDPhotoBrowserd.h"
@interface SDWebView ()<SDPhotoBrowserDelegate>
@property(nonatomic,assign) BOOL displayHTML;//  显示页面元素
@property(nonatomic,assign) BOOL displayCookies;// 显示页面Cookies
@property(nonatomic,assign) BOOL displayURL;// 显示即将调转的URL
@property(nonatomic,strong) NSString *imgSrc;//  预览图片的URL路径
@end


@implementation SDWebView
//  MARK: - init
- (instancetype)initWithURLString:(NSString *)urlString {
    self = [super init];
    self.URLString = urlString;
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    [self setDefaultValue];
    return self;
}


- (void)setURLString:(NSString *)URLString {
    _URLString = URLString;
    [self setDefaultValue];
}

-(instancetype)init{
    if (self = [super init]){
        [self setDefaultValue];
    }
    return self;
}

- (void)setDefaultValue {
    _displayHTML = YES;
    _displayCookies = NO;
    _displayURL = YES;
    self.UIDelegate = self;
    self.navigationDelegate = self;
    self.scrollView.showsVerticalScrollIndicator = NO;
}

//  MARK: - 加载本地URL
- (void)loadLocalHTMLWithFileName:(nonnull NSString *)htmlName {
    
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:path];
    NSString * htmlPath = [[NSBundle mainBundle] pathForResource:htmlName
                                                          ofType:@"html"];
    NSString * htmlCont = [NSString stringWithContentsOfFile:htmlPath
                                                    encoding:NSUTF8StringEncoding
                                                       error:nil];
    
    [self loadHTMLString:htmlCont baseURL:baseURL];
}


- (void)setJsHandlers:(NSArray<NSString *> *)jsHandlers {
    _jsHandlers = jsHandlers;
    [jsHandlers enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
         [self.configuration.userContentController addScriptMessageHandler:self name:obj];
    }];
}

//  MARK: - js调用原生方法 可在此方法中获得传递回来的参数
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if(self.webDelegate !=nil && [self.webDelegate respondsToSelector:@selector(userContentController:didReceiveScriptMessage:)]){
        [self.webDelegate userContentController:userContentController didReceiveScriptMessage:message];
    }
}

//  MARK: - 检查cookie及页面HTML元素
//页面加载完成后调用
-(void)getImagesAndRegisterClickAction{
    
    //获取图片数组
    [self evaluateJavaScript:@"getImages()" completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        
        self->_imgSrcArray = [NSMutableArray arrayWithArray:[result componentsSeparatedByString:@"+"]];
        NSLog(@"images=%@",self->_imgSrcArray);
        if (self->_imgSrcArray.count >= 1) {
            [self->_imgSrcArray removeLastObject];
        }
        NSLog(@"images=%@",self->_imgSrcArray);
    }];
    
    [self evaluateJavaScript:@"registerImageClickAction();" completionHandler:nil];
    
    if (_displayCookies) {
        NSHTTPCookie *cookie;
        NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        for (cookie in [cookieJar cookies]) {
            NSLog(@"%@", cookie);
        }
    }
    if (_displayHTML) {
        NSString *jsToGetHTMLSource = @"document.getElementsByTagName('html')[0].innerHTML";
        [self evaluateJavaScript:jsToGetHTMLSource completionHandler:^(id _Nullable HTMLsource, NSError * _Nullable error) {
            
        }];
    }

}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [NSThread sleepForTimeInterval:0.2];
    [self getImagesAndRegisterClickAction];
    if([self.webDelegate respondsToSelector:@selector(webView:didFinishNavigation:)]){
        [self.webDelegate webView:webView didFinishNavigation:navigation];
    }
}

//  MARK: - 页面开始加载就调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    if (self.webDelegate != nil && [self.webDelegate respondsToSelector:@selector(webView:didStartProvisionalNavigation:)]) {
        [self.webDelegate webView:webView didStartProvisionalNavigation:navigation];
    }
    
}

//  MARK: - 导航每次跳转调用跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    //预览图片
    if ([navigationAction.request.URL.scheme isEqualToString:@"image-preview"]) {
        NSString* path = [navigationAction.request.URL.absoluteString substringFromIndex:[@"image-preview:" length]];
        path = [path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        _imgSrc = path;
        [self previewPicture];
        decisionHandler(WKNavigationActionPolicyCancel); // 这个地方要加Cancel，不然加载图片，原来的会url就不请求了，出现图片加载一部分
        return;
    }
    if (_displayURL) {
        if (self.webDelegate != nil && [self.webDelegate respondsToSelector:@selector(webView:decidePolicyForNavigationAction:decisionHandler:)]) {
            [self.webDelegate webView:webView decidePolicyForNavigationAction:navigationAction decisionHandler:decisionHandler];
        }
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}

#pragma mark - 移除jsHandler
- (void)removejsHandlers {
    NSAssert(_jsHandlers, @"未找到jsHandler!无需移除");
    if (_jsHandlers) {
        for (NSString *handlerName in _jsHandlers) {
            [self.configuration.userContentController removeScriptMessageHandlerForName:handlerName];
        }
    }
}

//  MARK: - 清除cookie
- (void)removeCookies {
    WKWebsiteDataStore *dateStore = [WKWebsiteDataStore defaultDataStore];
    [dateStore fetchDataRecordsOfTypes:[WKWebsiteDataStore allWebsiteDataTypes]
                     completionHandler:^(NSArray<WKWebsiteDataRecord *> * __nonnull records) {
                         for (WKWebsiteDataRecord *record  in records) {
                             [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:record.dataTypes
                                                                       forDataRecords:@[record]
                                                                    completionHandler:^{
                                                                        NSLog(@"Cookies for %@ deleted successfully",record.displayName);
                                                                    }];
                         }
                     }];
}

- (void)removeCookieWithHostName:(NSString *)hostName {
    WKWebsiteDataStore *dateStore = [WKWebsiteDataStore defaultDataStore];
    [dateStore fetchDataRecordsOfTypes:[WKWebsiteDataStore allWebsiteDataTypes]
                     completionHandler:^(NSArray<WKWebsiteDataRecord *> * __nonnull records) {
                         for (WKWebsiteDataRecord *record  in records) {
                             if ( [record.displayName containsString:hostName]) {
                                 [[WKWebsiteDataStore defaultDataStore]removeDataOfTypes:record.dataTypes
                                                                          forDataRecords:@[record]
                                                                       completionHandler:^{
                                                                            NSLog(@"Cookies for %@ deleted successfully",record.displayName);
                                                                          }];
                             }
                         }
                     }];
}

//  MARK: - 调用js方法
- (void)callJavaScript:(NSString *)jsMethodName {
    [self callJavaScript:jsMethodName handler:nil];
}

- (void)callJavaScript:(NSString *)jsMethodName handler:(void (^)(id _Nullable))handler {
    
    NSLog(@"call js:%@",jsMethodName);
    [self evaluateJavaScript:jsMethodName completionHandler:^(id _Nullable response, NSError * _Nullable error) {
        if (handler) {
            handler(response);
        }
    }];
}

- (void)dealloc {
    //  这里清除或者不清除cookies 按照业务要求
//    [self removeCookies];
}

// 预览图片
- (void)previewPicture {
    NSInteger currentIndex = 0;
    for (NSInteger i = 0; i < self.imgSrcArray.count; i++) {
        NSString *path = self.imgSrcArray[i];
        if ([path isEqualToString:_imgSrc]) {
            currentIndex = i;
        }
    }
    SDPhotoBrowserd *browser = [[SDPhotoBrowserd alloc] init];
    browser.imageCount = self.imgSrcArray.count; // 图片总数
    browser.currentImageIndex = currentIndex;
    browser.sourceImagesContainerView = self.superview; // 原图的父控件
    browser.delegate = self;
    [browser show];
}



// 返回高质量图片的url
- (NSURL *)photoBrowser:(SDPhotoBrowserd *)browser highQualityImageURLForIndex:(NSInteger)index {
    
    return [NSURL URLWithString:self.imgSrcArray[index]];
    
}



@end
