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
    self.webTitle ? [self addAvtar]:nil;
    if (self.webTitle){
        self.rt_navigationController.tabBarItem.title = @"关于";
        self.rt_navigationController.tabBarItem.image = [UIImage imageNamed:@"关于灰"];
        self.rt_navigationController.tabBarItem.selectedImage = [UIImage imageNamed:@"关于蓝"];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rotate) name:ROTATE_NOTI object:nil];
    
}
-(void)rotate{
    [self setWebViewFontSize];
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}


-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    
    
    return YES;
}
-(void)webViewDidStartLoad:(UIWebView *)webView{
    _hud = [CJProgressHUD cjShowInView:self.view timeOut:TIME_OUT withText:@"加载中..." withImages:nil];
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
