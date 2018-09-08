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
    self.navigationController.hidesBarsOnSwipe = YES;
    
}


-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    
    
    return YES;
}
-(void)webViewDidStartLoad:(UIWebView *)webView{
    _hud = [CJProgressHUD cjShowWithPosition:CJProgressHUDPositionBothExist timeOut:0 withText:@"加载中..." withImages:nil];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView{
    [_hud cjHideProgressHUD];
}

@end
