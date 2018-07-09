//
//  CJLoginVC.m
//  百思不得姐
//
//  Created by ccj on 2017/5/8.
//  Copyright © 2017年 ccj. All rights reserved.
//

#import "CJLoginVC.h"
#import "CJMainVC.h"
#import "AppDelegate.h"
#import "CJMainNaVC.h"
@interface CJLoginVC ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftMargin;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UITextField *email;
@property (weak, nonatomic) IBOutlet UITextField *passwd;
@property (weak, nonatomic) IBOutlet UIButton *sendCode;
@property (weak, nonatomic) IBOutlet UIButton *registerBtn;
@property (weak, nonatomic) IBOutlet UIButton *changeBtn;

@end

@implementation CJLoginVC

- (void)viewDidLoad {
    [super viewDidLoad];
   
    CJCornerRadius(self.loginBtn) = 5;
    CJCornerRadius(self.sendCode) = 5;
    CJCornerRadius(self.registerBtn) = 5;
    
    if (!self.action){
        // 注册
        self.leftMargin.constant = -CJScreenWidth;
        [self.changeBtn setTitle:@"已有账号" forState:UIControlStateNormal];
        [self.view layoutIfNeeded];
        
    }else{
        CJUser *user = [CJUser sharedUser];
        self.email.text = user.email;
    }
    
    
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}
- (IBAction)cancelBtn:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)loginBtnClick:(UIButton *)sender {
    
    if (self.email.text.length && self.passwd.text.length){
        
        AFHTTPSessionManager *manger = [AFHTTPSessionManager manager];
        CJProgressHUD *hud = [CJProgressHUD cjShowWithPosition:CJProgressHUDPositionBothExist timeOut:0 withText:@"登录中..." withImages:nil];
        [manger POST:API_LOGIN parameters:@{@"email":self.email.text,@"passwd":self.passwd.text} progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSDictionary *dict = responseObject;
            
            if ([dict[@"status"] intValue] == 0){
                // 保存账号和密码
                
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    [CJUser userWithDict:dict];
                    [hud cjHideProgressHUD];
                    UITabBarController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateInitialViewController];
                    [self presentViewController:vc animated:YES completion:nil];
                    
                }];
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            if (error.code == NSURLErrorCannotConnectToHost){
                // 无网络
                [hud cjShowError:@"无网络..."];
            }else if (error.code == NSURLErrorTimedOut){
                // 请求超时
                [hud cjShowError:@"超时..."];
            }
        }];
        
    }
}
- (IBAction)registerBtnClick:(UIButton *)sender {
    
    
    //退出键盘
    [self.view endEditing:YES];
    if([[sender titleForState:UIControlStateNormal] isEqualToString:@"注册帐号"])
    {
    
        
        [sender setTitle:@"已有帐号" forState:UIControlStateNormal];
        self.leftMargin.constant = -CJScreenWidth;
        
    }
    else
    {
        [sender setTitle:@"注册帐号" forState:UIControlStateNormal];
        self.leftMargin.constant = 0;
    
    }
    
    [UIView animateWithDuration:0.5 animations:^{
        
        //
        [self.view layoutIfNeeded];
    }];
    
    
}


-(UIStatusBarStyle)preferredStatusBarStyle
{

    return UIStatusBarStyleLightContent;
}


- (IBAction)closeBtnClick:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{

    //退出键盘
    [self.view endEditing:YES];
    
}



@end
