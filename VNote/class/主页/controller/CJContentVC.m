//
//  CJContentVC.m
//  VNote
//
//  Created by ccj on 2018/6/3.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import "CJContentVC.h"
#import <WebKit/WebKit.h>
@interface CJContentVC ()<UIWebViewDelegate,UIScrollViewDelegate>
@property (nonatomic,strong)IBOutlet UIWebView *webView;
@property (nonatomic,strong) CJProgressHUD *hud;
@end

@implementation CJContentVC


-(void)viewDidLoad{
    [super viewDidLoad];
    self.navigationItem.title = self.title;
    self.view.backgroundColor = BlueBg;
    self.webView.backgroundColor = BlueBg;
    self.webView.scrollView.delegate = self;
    CJProgressHUD *hud = [CJProgressHUD cjShowWithPosition:CJProgressHUDPositionNavigationBar timeOut:0 withText:@"加载中..." withImages:nil];
    self.hud = hud;
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:API_NOTE_DETAIL(self.uuid)]]];
    if (self.isMe){
       self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(rightClick:)];
    }
    

}
-(void)rightClick:(UIBarButtonItem *)item{
    NSString *title = item.title;
    if ([title isEqualToString:@"编辑"]){
        // 切换webview的显示
        [self.webView stringByEvaluatingJavaScriptFromString:@"edit()"];
        item.title = @"预览";
        
    }else{
        [self.webView stringByEvaluatingJavaScriptFromString:@"markdown()"];
        item.title = @"编辑";
    }
}


-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    if ([request.URL.scheme isEqualToString:@"image-preview"]) {
        
//        NSString *path = [request.URL.absoluteString substringFromIndex:[@"image-preview:" length]];
        
//        path = [path stringByAddingPercentEncodingWithAllowedCharacters:NSUTF8StringEncoding];
        
        //path 就是被点击图片的url
        
        return NO;
    }
    
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [self.hud cjHideProgressHUD];
    
    
}




@end
