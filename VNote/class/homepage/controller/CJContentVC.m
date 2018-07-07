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
    self.navigationItem.title = self.title;
    self.webView = [[UIWebView alloc]initWithFrame:self.view.bounds];
    self.webView.cj_height -= 64;
    [self.view addSubview:self.webView];
    self.webView.backgroundColor = BlueBg;
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:API_NOTE_DETAIL(self.uuid)]]];
}







@end
