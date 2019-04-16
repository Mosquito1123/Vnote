//
//  CJProtocolVC.m
//  VNote
//
//  Created by ccj on 2019/4/13.
//  Copyright © 2019 ccj. All rights reserved.
//

#import "CJProtocolVC.h"
#import <WebKit/WebKit.h>
@interface CJProtocolVC ()<WKNavigationDelegate>
@property (weak, nonatomic) IBOutlet WKWebView *wkwebView;
@property (strong,nonatomic) CJProgressHUD *hud;
@end

@implementation CJProtocolVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSURLRequest *req = [[NSURLRequest alloc]initWithURL:[NSURL URLWithString:PRIVACY] cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:TIME_OUT];
    [self.wkwebView loadRequest:req];
    self.wkwebView.navigationDelegate = self;
    
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation{
    self.hud = [CJProgressHUD cjShowInView:self.view timeOut:0 withText:@"加载中..." withImages:nil];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error{
    [self.hud cjShowError:@"加载失败!"];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    [self.hud cjHideProgressHUD];
}




@end
