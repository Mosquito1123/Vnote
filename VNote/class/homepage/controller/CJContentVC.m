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
@property (nonatomic,strong)UIActivityIndicatorView *activewIndicator;
@end

@implementation CJContentVC
-(void)setTitleView{
    UIView *titleView = [[UIView alloc]init];
    titleView.backgroundColor = [UIColor whiteColor];
    UILabel *l= [[UILabel alloc]init];
    l.text = self.title;
    l.textColor = [UIColor whiteColor];
    [l sizeToFit];
    [titleView addSubview:l];
    
    [titleView sizeToFit];
    l.center = titleView.center;
    self.navigationItem.titleView = titleView;
    UIActivityIndicatorView *refresh = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [titleView addSubview:refresh];
    refresh.cj_x = l.cj_maxX;
    refresh.cj_centerY = titleView.cj_centerY;
    [refresh startAnimating];
    self.activewIndicator = refresh;

}

-(void)viewDidLoad{
    [super viewDidLoad];
    [self setTitleView];
    self.view.backgroundColor = BlueBg;
    self.webView.backgroundColor = BlueBg;
    self.webView.scrollView.delegate = self;
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:API_NOTE_DETAIL(self.uuid)]]];

}




- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [self.activewIndicator stopAnimating];
}




@end
