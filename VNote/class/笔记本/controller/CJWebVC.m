//
//  CJWebVC.m
//  VNote
//
//  Created by ccj on 2018/9/6.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import "CJWebVC.h"

@interface CJWebVC ()<UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property(nonatomic,strong) CJProgressHUD *hud;
@end

@implementation CJWebVC

-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBar.hidden = YES;
}
-(void)viewDidDisappear:(BOOL)animated{
    self.navigationController.navigationBar.hidden = NO;

}

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc]init] forBarMetrics:UIBarMetricsDefault];
//
//    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc]init]];
//    [self.rt_navigationController.navigationBar setBackgroundImage:[[UIImage alloc]init] forBarMetrics:UIBarMetricsDefault];
//
//    [self.rt_navigationController.navigationBar setShadowImage:[[UIImage alloc]init]];
//    // Do any additional setup after loading the view from its nib.
    [self.webView loadRequest:self.request];
    
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
