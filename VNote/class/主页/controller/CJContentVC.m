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
@property(nonatomic,strong) UIBarButtonItem *rightItem;
@property(nonatomic,assign,getter=isEdit) BOOL edit;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *toolItem;
@end

@implementation CJContentVC
-(void)setEdit:(BOOL)edit{
    _edit = edit;
    self.navigationItem.rightBarButtonItem.title = edit?@"预览":@"编辑";
    self.toolItem.title = edit?@"保存":@"编辑";
    if (edit){
        [self.webView stringByEvaluatingJavaScriptFromString:@"edit()"];
    }else{
        [self.webView stringByEvaluatingJavaScriptFromString:@"markdown()"];
    }
}
- (IBAction)toolItem:(UIBarButtonItem *)sender {
    if (self.isEdit){
        
        AFHTTPSessionManager *manger = [AFHTTPSessionManager manager];
        CJProgressHUD *hud = [CJProgressHUD cjShowWithPosition:CJProgressHUDPositionNavigationBar timeOut:0 withText:@"加载中..." withImages:nil];
        NSString *content = [self.webView stringByEvaluatingJavaScriptFromString:@"get_content()"];
        NSLog(@"%@",content);
        [manger POST:API_SAVE_NOTE parameters:@{@"note_uuid":self.uuid,@"note_title":self.title,@"content":content} progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSDictionary *dict = responseObject;
            if ([dict[@"status"] integerValue] == 0){
                [hud cjShowSuccess:@"保存成功"];
            }
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [hud cjShowError:@"保存失败!"];
        }];
    }
    self.edit = !self.isEdit;
}


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
    self.edit = NO;

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
    [self.hud cjHideProgressHUD];
    
    
}




@end
