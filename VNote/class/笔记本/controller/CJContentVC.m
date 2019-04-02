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
@interface CJContentVC ()<WKNavigationDelegate,WKUIDelegate,UIScrollViewDelegate,WKScriptMessageHandler>
@property (strong, nonatomic) SDWebView *webView;
@property WKWebViewJavascriptBridge *webViewBridge;
@property(nonatomic,assign,getter=isEdit) BOOL edit;

@property(nonatomic,strong) UIActivityIndicatorView *indicatorView;
@property(nonatomic,strong) NSIndexPath *selectIndexPath;
@property(nonatomic,strong) UIBarButtonItem *styleItem;// 可能是code图片，可以是保存
@property(nonatomic,strong) UIBarButtonItem *editItem;// 编辑/查看
@property(nonatomic,strong) UIView *coverView;
@property(nonatomic,strong) CJCodeStyleView *codeStyleView;
@end

@implementation CJContentVC

-(UIBarButtonItem *)styleItem{
    if (!_styleItem){
        _styleItem= [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"代码"] style:UIBarButtonItemStylePlain target:self action:@selector(styleClick:)];
    }
    return _styleItem;
}
-(UIBarButtonItem *)editItem{
    if(!_editItem){
        _editItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"编辑"] style:UIBarButtonItemStylePlain target:self action:@selector(rightClick:)];
    }
    return _editItem;
}


-(UIActivityIndicatorView *)indicatorView{
    if (!_indicatorView){
        _indicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    }
    return _indicatorView;
}


-(void)setEdit:(BOOL)edit{
    _edit = edit;
    if (edit){
        
        [self.webView evaluateJavaScript:@"edit()" completionHandler:^(id _Nullable res, NSError * _Nullable error) {
            
        }];
        
    }else{
        self.navigationItem.rightBarButtonItems = @[self.editItem,self.styleItem];
        [self.webView evaluateJavaScript:@"markdown()" completionHandler:^(id _Nullable res, NSError * _Nullable error) {
            
        }];
    }
    self.editItem.image = edit?[UIImage imageNamed:@"查看"]:[UIImage imageNamed:@"编辑"];
    self.styleItem.image = edit?[UIImage imageNamed:@"保存"]:[UIImage imageNamed:@"代码"];
}

-(void)saveNote{
    CJProgressHUD *hud = [CJProgressHUD cjShowInView:self.view timeOut:TIME_OUT withText:@"加载中..." withImages:nil];
    
    [self.webView evaluateJavaScript:@"get_content()" completionHandler:^(id _Nullable res, NSError * _Nullable error) {
        NSString *content = res;
        [CJAPI saveNoteWithParams:@{@"note_uuid":self.uuid,@"note_title":self.noteTitle,@"content":content} success:^(NSDictionary *dic) {
    
            if ([dic[@"status"] integerValue] == 0){
                [hud cjShowSuccess:@"保存成功"];
            }
        } failure:^(NSError *error) {
            [hud cjShowError:net101code];
        }];
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
        [CJAPI changeCodeStyleWithParams:@{@"email":user.email,@"code_style":style} success:^(NSDictionary *dic) {
            [hud cjShowSuccess:@"修改成功"];
            user.code_style = style;
            [CJUser userWithDict:[user toDic]];
            [CJTool catchAccountInfo2Preference:[user toDic]];
            
        } failure:^(NSError *error) {
            [hud cjShowError:net101code];
        }];
        
    } selectIndexPath:weakself.selectIndexPath competion:^{
        [self tapCoverView];
    }];
}

-(void)viewDidLoad{
    [super viewDidLoad];
    self.navigationItem.title = self.noteTitle;
    self.webView = [[SDWebView alloc]init];
    self.webView.scrollView.delegate = self;
    CJWeak(self)
    [self.view addSubview:self.webView];
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.and.top.bottom.equalTo(weakself.view);
    }];
    
    self.webView.scrollView.backgroundColor = [UIColor whiteColor]; // 防止黑色
    self.webView.backgroundColor = [UIColor whiteColor];
    self.webView.opaque = NO;
    self.webView.UIDelegate = self;
    self.webView.scrollView.delegate = self;
    
    NSMutableURLRequest * requestM = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:API_NOTE_DETAIL(self.uuid)] cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:TIME_OUT];
    requestM.HTTPMethod = @"POST";
    CJUser *user = [CJUser sharedUser];
    NSString *data = [NSString stringWithFormat:@"{\"email\":\"%@\"}",user.email];
    NSString * url = API_NOTE_DETAIL(self.uuid);
    NSString * js = [NSString stringWithFormat:@"%@my_post(\"%@\", %@)",POST_JS,url,data];    // 执行JS代码
    [self.webView evaluateJavaScript:js completionHandler:nil];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:self.indicatorView];
    [self.indicatorView startAnimating];
    
    self.selectIndexPath = nil;
    [self addCodeStyleView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadWebViewDone) name:LOAD_WEBVIEW object:nil];
}
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    
    return nil;
    
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
-(void)rightClick:(UIBarButtonItem *)item{
    self.edit = !self.isEdit;
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    
    if ([request.URL.scheme isEqualToString:@"image-preview"]) {
        
        return NO;
    }
    if ([request.URL.absoluteString isEqualToString:API_NOTE_DETAIL(self.uuid)]){
        return YES;
    }
    CJWebVC *vc = [[CJWebVC alloc]init];
    vc.request = request;
    [self.navigationController pushViewController:vc animated:YES];
    
    return NO;
}

-(void)styleClick:(UIBarButtonItem *)item{
    if (self.edit){
        // 保存
        [self saveNote];
        return;
    }
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


- (void)loadWebViewDone{
    [self.indicatorView stopAnimating];
    if (self.isMe){
        self.edit = NO;
        self.navigationItem.rightBarButtonItems = @[self.editItem,self.styleItem];
    }
    NSString *style = [CJUser sharedUser].code_style;
    NSString *js = [NSString stringWithFormat:@"change_code_style('%@')",style];
    [self.webView evaluateJavaScript:js completionHandler:^(id _Nullable res, NSError * _Nullable error) {

    }];


}



@end
