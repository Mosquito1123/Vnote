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
    UIView *titleView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CJScreenWidth * 0.8, 40)];
    

    UILabel *l= [[UILabel alloc]init];
    l.frame = CGRectMake(0, 0, CJScreenWidth*0.5, 40);
    l.center = titleView.center;
    l.text = self.title;
    l.textColor = [UIColor whiteColor];
    l.lineBreakMode = NSLineBreakByTruncatingTail;
    [titleView addSubview:l];
    
    UIActivityIndicatorView *refresh = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [titleView addSubview:refresh];
    refresh.cj_x = l.cj_maxX;
    refresh.cj_centerY = l.cj_centerY;
    [refresh startAnimating];
    self.activewIndicator = refresh;
    self.navigationItem.titleView = titleView;
}

-(void)viewDidLoad{
    [super viewDidLoad];
    [self setTitleView];
    self.view.backgroundColor = BlueBg;
    self.webView.backgroundColor = BlueBg;
    self.webView.scrollView.delegate = self;
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:API_NOTE_DETAIL(self.uuid)]]];

}



-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    if ([request.URL.scheme isEqualToString:@"image-preview"]) {
        
        NSString *path = [request.URL.absoluteString substringFromIndex:[@"image-preview:" length]];
        
//        path = [path stringByAddingPercentEncodingWithAllowedCharacters:NSUTF8StringEncoding];
        
        //path 就是被点击图片的url
        
        return NO;
    }
    
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [self.activewIndicator stopAnimating];
    
}




@end
