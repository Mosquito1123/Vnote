//
//  CJContentVC.m
//  VNote
//
//  Created by ccj on 2018/6/3.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import "CJContentVC.h"
#import <WebKit/WebKit.h>
#import "CJWebVC.h"
#import "CJCodeStyleView.h"
#import <AVFoundation/AVFoundation.h>
#import <WKWebViewJavascriptBridge.h>
#import "SDWebView.h"
#import "CJInputTool.h"
@interface CJContentVC ()<WKNavigationDelegate,WKUIDelegate,UIScrollViewDelegate,WKScriptMessageHandler>
@property (strong, nonatomic) SDWebView *webView;
@property WKWebViewJavascriptBridge *webViewBridge;
@property(nonatomic,strong) UIActivityIndicatorView *indicatorView;
@property(nonatomic,strong) NSIndexPath *selectIndexPath;
@property(nonatomic,strong) UIBarButtonItem *styleItem;// codeStyle
@property(nonatomic,strong) UIBarButtonItem *saveItem;// 保存
@property(nonatomic,strong) UIView *coverView;
@property(nonatomic,strong) CJCodeStyleView *codeStyleView;
@property(nonatomic,strong) UISegmentedControl *segment;

@end

@implementation CJContentVC

-(void)changeSegmentSelect:(UISegmentedControl *)seg{
    NSInteger index = seg.selectedSegmentIndex;
    if (index == 0){
        // edit
        [self.webView evaluateJavaScript:[self markdown:index] completionHandler:nil];
        self.navigationItem.rightBarButtonItems = @[self.saveItem];

    }else if (index == 1){
        // markdown
        
        [self.view endEditing:YES];
        self.navigationItem.rightBarButtonItems = @[self.styleItem];
        [self.webView evaluateJavaScript:[self markdown:index] completionHandler:nil];

    }else if (index == 2){
        // 两个
        self.navigationItem.rightBarButtonItems = @[self.saveItem,self.styleItem];
        [self.webView evaluateJavaScript:[self markdown:index] completionHandler:nil];
        
    }
    
}
-(UISegmentedControl *)segment{
    if (!_segment){
        UIImage *editImage = [UIImage imageNamed:@"pen"];
        UIImage *eyeImage = [UIImage imageNamed:@"eye"];
        UIImage *pansImage = [UIImage imageNamed:@"分栏"];
        
        _segment = [[UISegmentedControl alloc]initWithItems:@[editImage,eyeImage,pansImage]];
        _segment.cj_width = 150;
        _segment.selectedSegmentIndex = 1;
        [_segment addTarget:self action:@selector(changeSegmentSelect:) forControlEvents:UIControlEventValueChanged];
    }
    return _segment;
}


-(UIBarButtonItem *)styleItem{
    if (!_styleItem){
        _styleItem= [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"代码"] style:UIBarButtonItemStylePlain target:self action:@selector(styleClick:)];
    }
    return _styleItem;
}
-(UIBarButtonItem *)saveItem{
    if(!_saveItem){
        _saveItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"保存"] style:UIBarButtonItemStylePlain target:self action:@selector(saveNote)];
    }
    return _saveItem;
}


-(UIActivityIndicatorView *)indicatorView{
    if (!_indicatorView){
        _indicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    }
    return _indicatorView;
}


-(void)saveNote{
    CJProgressHUD *hud = [CJProgressHUD cjShowInView:self.view timeOut:TIME_OUT withText:@"加载中..." withImages:nil];
    
    CJWeak(self)
    [self.webView evaluateJavaScript:@"save_note()" completionHandler:^(id _Nullable res, NSError * _Nullable error) {
        NSDictionary *d = res;
        if ([d[@"status"] integerValue] == 0){
            [[CJRlm shareRlm] transactionWithBlock:^{
                weakself.note.title = d[@"title"];
                weakself.note.updated_at = d[@"updated_at"];
            }];
            [hud cjShowSuccess:@"保存成功"];
            [[NSNotificationCenter defaultCenter]postNotificationName:NOTE_CHANGE_NOTI object:nil];
        }else{
            [hud cjShowSuccess:d[@"msg"]];
        }
    }];
}

-(void)addCodeStyleView{
    CJWeak(self)
    
    CJCodeStyleView *codeStyleView = [CJCodeStyleView xibWithCodeStyleView];
    self.codeStyleView = codeStyleView;
    [self.codeStyleView addInView:self.navigationController.view];
    [codeStyleView selectItem:^(NSString *style,NSIndexPath *indexPath) {
        weakself.selectIndexPath = indexPath;
        NSString *js = [NSString stringWithFormat:@"change_code_style('%@')",style];
        [weakself.webView evaluateJavaScript:js completionHandler:^(id _Nullable res, NSError * _Nullable error) {
            
        }];
    } confirm:^(NSString *style){
        CJProgressHUD *hud = [CJProgressHUD cjShowInView:self.view timeOut:TIME_OUT withText:@"修改中..." withImages:nil];
        CJUser *user = [CJUser sharedUser];
        [CJAPI requestWithAPI:API_CHANGE_CODE_STYLE params:@{@"email":user.email,@"code_style":style} success:^(NSDictionary *dic) {
            [hud cjShowSuccess:@"修改成功"];
            user.code_style = style;
            [CJUser userWithDict:[user toDic]];
            [CJTool catchAccountInfo2Preference:[user toDic]];
        } failure:^(NSDictionary *dic) {
            [hud cjShowError:dic[@"msg"]];
        } error:^(NSError *error) {
            [hud cjShowError:net101code];
        }];
        
    } selectIndexPath:weakself.selectIndexPath competion:^{
        [weakself tapCoverView];
    }];
}

-(void)viewDidLoad{
    [super viewDidLoad];
    if (self.isMe){
       self.navigationItem.titleView = self.segment;
    }else{
        self.navigationItem.title = self.note.title;
    }
    
    self.webView = [[SDWebView alloc]init];
    self.webView.scrollView.delegate = self;
    self.webView.webDelegate = self;
    CJWeak(self)
    [self.view addSubview:self.webView];
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.and.top.bottom.equalTo(weakself.view);
    }];
    
    self.webView.scrollView.backgroundColor = [UIColor whiteColor]; // 防止底部刚开始加载黑色
    self.webView.backgroundColor = [UIColor whiteColor];
    self.webView.opaque = NO;
    
    NSMutableURLRequest * requestM = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:API_NOTE_DETAIL(self.note.uuid)] cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:TIME_OUT];
    requestM.HTTPMethod = @"POST";
    CJUser *user = [CJUser sharedUser];
    NSString *data = [NSString stringWithFormat:@"{\"email\":\"%@\"}",user.email];
    NSString * url = API_NOTE_DETAIL(self.note.uuid);
    NSString * js = [NSString stringWithFormat:@"%@my_post(\"%@\", %@)",POST_JS,url,data];    // 执行JS代码
    [self.webView evaluateJavaScript:js completionHandler:nil];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:self.indicatorView];
    [self.indicatorView startAnimating];
    
    self.selectIndexPath = nil;
    [self addCodeStyleView];
}



- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    
    return nil;
}
-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    [self loadWebViewDone];
}

-(void)styleClick:(UIBarButtonItem *)item{
    CJWeak(self)
    self.coverView = [[UIView alloc]init];
    [self.navigationController.view addSubview:self.coverView];
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapCoverView)];
    [self.coverView addGestureRecognizer:tapGes];
    self.coverView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    [self.coverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.and.top.and.bottom.equalTo(weakself.navigationController.view);
    }];
    [self.navigationController.view layoutIfNeeded];
    [self.navigationController.view bringSubviewToFront:self.codeStyleView];
    [self.codeStyleView show];
    
}


-(void)tapCoverView{
    [self.coverView removeFromSuperview];
    [self.codeStyleView hide];
}


-(NSString *)markdown:(NSInteger)index{
    NSInteger i = self.isMe ? 1 : 0;
    return [NSString stringWithFormat:@"markdown(%ld,%ld)",index,i];
}

- (void)loadWebViewDone{
    [self.indicatorView stopAnimating];
    if (self.isMe){
        self.navigationItem.rightBarButtonItems = @[self.styleItem];
    }
    [self.webView evaluateJavaScript:[self markdown:1] completionHandler:nil];
}

-(void)viewWillLayoutSubviews{
    [self.webView evaluateJavaScript:@"re_handle_img_size()" completionHandler:nil];
    [self.webView evaluateJavaScript:[self markdown:self.segment.selectedSegmentIndex] completionHandler:nil];
}

@end
