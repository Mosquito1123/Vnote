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
@property(nonatomic,strong) UIBarButtonItem *rightItem;
@property(nonatomic,assign,getter=isEdit) BOOL edit;
@property(nonatomic,strong) UIButton *penBtn;
@property(nonatomic,strong) UIActivityIndicatorView *indicatorView;
@end

@implementation CJContentVC

-(UIActivityIndicatorView *)indicatorView{
    if (!_indicatorView){
        _indicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    }
    return _indicatorView;
}
-(void)viewWillAppear:(BOOL)animated{
    self.penBtn.superview.hidden = YES;
}
-(void)viewWillDisappear:(BOOL)animated{
    self.penBtn.superview.hidden = YES;

}

-(void)setEdit:(BOOL)edit{
    _edit = edit;
    self.navigationItem.rightBarButtonItem.title = edit?@"预览":@"编辑";
    self.penBtn.superview.hidden = !edit;
    if (edit){
        [self.webView stringByEvaluatingJavaScriptFromString:@"edit()"];
        
    }else{
        [self.webView stringByEvaluatingJavaScriptFromString:@"markdown()"];
    }
    
}

-(void)addPenBtn{
    UIView *shawView = [[UIView alloc]init];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"Save" forState:UIControlStateNormal];
    [button setTitleColor:BlueBg forState:UIControlStateNormal];
    button.cj_width = button.cj_height = 50;
    
    [shawView addSubview:button];
    [self.navigationController.view addSubview:shawView];
    [shawView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-30);
        make.bottom.mas_equalTo(-100);
        make.width.mas_equalTo(button.cj_width);
        make.height.mas_equalTo(button.cj_height);
    }];
    shawView.layer.shadowColor = BlueBg.CGColor;
    shawView.layer.shadowOffset = CGSizeMake(0, 3);
    shawView.layer.shadowOpacity = 1;
    shawView.layer.shadowRadius = 3.0;
    shawView.layer.cornerRadius = button.cj_width/2;
    shawView.clipsToBounds = NO;
    CJCornerRadius(button) = button.cj_width/2;
    
    [button addTarget:self action:@selector(saveNote) forControlEvents:UIControlEventTouchUpInside];
    button.backgroundColor = [UIColor whiteColor];
    self.penBtn = button;
}

-(void)saveNote{
    CJProgressHUD *hud = [CJProgressHUD cjShowWithPosition:CJProgressHUDPositionNavigationBar timeOut:0 withText:@"加载中..." withImages:nil];
    NSString *content = [self.webView stringByEvaluatingJavaScriptFromString:@"get_content()"];
    
    [CJAPI saveNoteWithParams:@{@"note_uuid":self.uuid,@"note_title":self.noteTitle,@"content":content} success:^(NSDictionary *dic) {
       
        if ([dic[@"status"] integerValue] == 0){
            [hud cjShowSuccess:@"保存成功"];
        }
    } failure:^(NSError *error) {
        [hud cjShowError:@"保存失败!"];
    }];
    
}

-(void)viewDidLoad{
    [super viewDidLoad];
    self.navigationItem.title = self.noteTitle;
    self.view.backgroundColor = BlueBg;
    self.webView.backgroundColor = BlueBg;
    self.webView.scrollView.delegate = self;
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:API_NOTE_DETAIL(self.uuid)]]];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:self.indicatorView];
    [self.indicatorView startAnimating];
    

}
-(void)rightClick:(UIBarButtonItem *)item{
    self.edit = !self.isEdit;
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
    [self.indicatorView stopAnimating];
    if (self.isMe){
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(rightClick:)];
        self.edit = NO;
        [self addPenBtn];
        self.penBtn.superview.hidden = YES;
    }
    
    
}




@end
