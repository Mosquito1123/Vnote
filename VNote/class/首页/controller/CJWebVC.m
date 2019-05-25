//
//  CJWebVC.m
//  VNote
//
//  Created by ccj on 2018/9/6.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import "CJWebVC.h"

@interface CJWebVC ()<UIWebViewDelegate,UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property(nonatomic,strong) CJProgressHUD *hud;
@end

@implementation CJWebVC



- (void)viewDidLoad {
    [super viewDidLoad];
    [self.webView loadRequest:self.request];
    self.navigationController.hidesBarsOnSwipe = self.webTitle ? NO : YES;
    
    self.navigationItem.title = self.webTitle ? self.webTitle : self.request.URL.absoluteString;
    self.view.backgroundColor = BlueBg;
    self.webView.backgroundColor = BlueBg;
    self.webView.opaque = NO;;
    self.webView.scrollView.backgroundColor = BlueBg;
    
}

-(void)viewWillLayoutSubviews{
    [self setWebViewFontSize];
}



-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    
    
    return YES;
}
-(void)webViewDidStartLoad:(UIWebView *)webView{
    _hud = [CJProgressHUD cjShowInView:self.view timeOut:0 withText:@"加载中..." withImages:nil];
    
}

-(void)webViewDidFinishLoad:(UIWebView *)webView{
    [self setWebViewFontSize];
    [_hud cjHideProgressHUD];
}

-(void)setWebViewFontSize{
    NSString* fontSize = [NSString stringWithFormat:@"%d",100];
    fontSize = [fontSize stringByAppendingFormat:@"%@",@"%"];;
    NSString* str = [NSString stringWithFormat:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '%@'",fontSize];
    [self.webView stringByEvaluatingJavaScriptFromString:str];
}

@end
