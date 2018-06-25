//
//  CJContentVC.m
//  VNote
//
//  Created by ccj on 2018/6/3.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import "CJContentVC.h"
#import <WebKit/WebKit.h>
@interface CJContentVC ()<UIWebViewDelegate>
@property (nonatomic,strong)UIWebView *webView;
@end

@implementation CJContentVC

-(void)viewDidLoad{
    [super viewDidLoad];
    self.webView = [[UIWebView alloc]initWithFrame:self.view.bounds];
    [self.view addSubview:self.webView];
    NSLog(@"%@",self.uuid);
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:API_NOTE_DETAIL(self.uuid)]]];
}

//- (void)viewDidLoad {
//    [super viewDidLoad];
//    self.webView = [[UIWebView alloc]initWithFrame:self.view.bounds];
//    [self.view addSubview:self.webView];
//    NSURL *url = [[NSBundle mainBundle] URLForResource:@"index" withExtension:@"html"];
//    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
//    self.webView.delegate = self;
//}


//- (void)webViewDidFinishLoad:(UIWebView *)webView{
//    NSInteger maxLength = 5000;
//    NSString *str = [self.content substringWithRange:NSMakeRange(1, self.content.length-2)];
//    NSString *tmp = str;
//    while (tmp.length >= maxLength) {
//        NSString *t = [NSString stringWithFormat:@"markdown('%@')",[tmp substringWithRange:NSMakeRange(0, maxLength)]];
//        [self.webView stringByEvaluatingJavaScriptFromString:t];
//        tmp = [tmp substringWithRange:NSMakeRange(maxLength, tmp.length-maxLength)];
//    }
//    NSString *t = [NSString stringWithFormat:@"markdown('%@')",tmp];
//    [self.webView stringByEvaluatingJavaScriptFromString:t];
//}




@end
