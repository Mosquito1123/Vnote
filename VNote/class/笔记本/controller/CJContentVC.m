//
//  CJContentVC.m
//  VNote
//
//  Created by ccj on 2018/6/3.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import "CJContentVC.h"
#import <WebKit/WebKit.h>
#import "CJCodeStyleVC.h"
@interface CJContentVC ()<UIWebViewDelegate,UIScrollViewDelegate>
@property (nonatomic,strong)IBOutlet UIWebView *webView;
@property(nonatomic,strong) UIBarButtonItem *rightItem;
@property(nonatomic,assign,getter=isEdit) BOOL edit;
@property(nonatomic,strong) UIButton *penBtn;
@property(nonatomic,strong) UIActivityIndicatorView *indicatorView;
@property(nonatomic,strong) NSIndexPath *selectIndexPath;
@property(nonatomic,strong) UIBarButtonItem *styleItem;
@property(nonatomic,strong) UIBarButtonItem *editItem;
@property(nonatomic,strong) UIView *maskView;
@end

@implementation CJContentVC

-(UIView *)maskView{
    if (!_maskView){
        _maskView = [[UIView alloc]initWithFrame:self.view.bounds];
        _maskView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.4];
    }
    return _maskView;
}
-(UIBarButtonItem *)styleItem{
    if (!_styleItem){
        _styleItem= [[UIBarButtonItem alloc]initWithTitle:@"样式" style:UIBarButtonItemStylePlain target:self action:@selector(styleClick)];
    }
    return _styleItem;
}
-(UIBarButtonItem *)editItem{
    if(!_editItem){
        _editItem = [[UIBarButtonItem alloc]initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(rightClick:)];
    }
    return _editItem;
}


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
    
    self.penBtn.superview.hidden = !edit;
    if (edit){
        self.navigationItem.rightBarButtonItems = @[self.editItem];
        [self.webView stringByEvaluatingJavaScriptFromString:@"edit()"];
        
    }else{
        self.navigationItem.rightBarButtonItems = @[self.editItem,self.styleItem];
        [self.webView stringByEvaluatingJavaScriptFromString:@"markdown()"];
    }
    self.editItem.title = edit?@"预览":@"编辑";
}

-(void)addPenBtn{
    UIView *shawView = [[UIView alloc]init];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"保存"] forState:UIControlStateNormal];
    [button sizeToFit];
    [button setTitleColor:BlueBg forState:UIControlStateNormal];
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
    NSMutableURLRequest * requestM = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:API_NOTE_DETAIL(self.uuid)]];
    requestM.HTTPMethod = @"POST";
    CJUser *user = [CJUser sharedUser];
    NSString *data = [NSString stringWithFormat:@"email=%@",user.email];
    requestM.HTTPBody = [data dataUsingEncoding:NSUTF8StringEncoding];
    [self.webView loadRequest:requestM];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:self.indicatorView];
    [self.indicatorView startAnimating];
    
    self.selectIndexPath = nil;
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

-(void)styleClick{
    CJCodeStyleVC *vc = [[CJCodeStyleVC alloc]init];
    vc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    CJWeak(self)
    [vc selectItem:^(NSString *style,NSIndexPath *indexPath) {
        weakself.selectIndexPath = indexPath;
        NSString *js = [NSString stringWithFormat:@"change_code_style('%@')",style];
        [weakself.webView stringByEvaluatingJavaScriptFromString:js];
    } confirm:^(NSString *style){
        CJProgressHUD *hud = [CJProgressHUD cjShowWithPosition:CJProgressHUDPositionBothExist timeOut:0 withText:@"修改中..." withImages:nil];
        CJUser *user = [CJUser sharedUser];
        [CJAPI changeCodeStyleWithParams:@{@"email":user.email,@"code_style":style} success:^(NSDictionary *dic) {
            [hud cjShowSuccess:@"修改成功"];
            user.code_style = style;
            [CJUser userWithDict:[user toDic]];
            CJTool *tool = [CJTool sharedTool];
            [tool catchAccountInfo2Preference:[user toDic]];
            
        } failure:^(NSError *error) {
            [hud cjShowError:@"修改失败!"];
        }];
        
    } selectIndexPath:weakself.selectIndexPath competion:^{
        [weakself.maskView removeFromSuperview];
    }];
    [self.view addSubview:self.maskView];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [self.indicatorView stopAnimating];
    if (self.isMe){
        self.edit = NO;
        [self addPenBtn];
        self.navigationItem.rightBarButtonItems = @[self.editItem,self.styleItem];
        self.penBtn.superview.hidden = YES;
    }
    
    
}




@end
