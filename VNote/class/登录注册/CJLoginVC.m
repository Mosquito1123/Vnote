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
@property (weak, nonatomic) IBOutlet UITextField *code;
@property (weak, nonatomic) IBOutlet UITextField *setEmail;
@property (weak, nonatomic) IBOutlet UITextField *setPasswd;

@property (weak, nonatomic) IBOutlet UITextField *accountT;
@property (weak, nonatomic) IBOutlet UITextField *passwdT;
@property (weak, nonatomic) IBOutlet UITextField *codeT;
@property (weak, nonatomic) IBOutlet UIButton *sendCodeBtn;

@property (weak, nonatomic) IBOutlet UIButton *resetBtn;
@end

@implementation CJLoginVC
static NSInteger s1 = 0;
static NSInteger s2 = 0;
-(void)timmer1{
    s1 += 1;
    if (s1 == 30){
        s1 = 0;
        self.sendCode.enabled = YES;
        [self.sendCode setTitle:@"发送验证码" forState:UIControlStateDisabled];
    }
    NSString *text = [NSString stringWithFormat:@"%ld秒重发",30-s1];
    [self.sendCode setTitle:text forState:UIControlStateDisabled];
}
-(void)timmer2{
    s2 += 1;
    if (s2 == 30){
        s2 = 0;
        self.sendCodeBtn.enabled = YES;
        [self.sendCodeBtn setTitle:@"发送验证码" forState:UIControlStateDisabled];
    }
    NSString *text = [NSString stringWithFormat:@"%ld秒重发",30-s2];
    [self.sendCodeBtn setTitle:text forState:UIControlStateDisabled];
}

- (IBAction)getResetCode:(id)sender {
    CJProgressHUD *hud = [CJProgressHUD cjShowWithPosition:CJProgressHUDPositionBothExist timeOut:0 withText:@"发送中..." withImages:nil];
    [CJAPI getCodeWithParams:@{@"email":self.accountT.text} success:^(NSDictionary *dic) {
        [hud cjShowSuccess:@"发送成功"];
        self.sendCodeBtn.enabled = NO;
        [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timmer2) userInfo:nil repeats:YES];
    } failure:^(NSError *error) {
        
    }];
}
- (IBAction)getCode:(id)sender {
    CJProgressHUD *hud = [CJProgressHUD cjShowWithPosition:CJProgressHUDPositionBothExist timeOut:0 withText:@"发送中..." withImages:nil];
    [CJAPI getCodeWithParams:@{@"email":self.setEmail.text} success:^(NSDictionary *dic) {
        [hud cjShowSuccess:@"发送成功"];
        self.sendCode.enabled = NO;
        [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timmer1) userInfo:nil repeats:YES];
    } failure:^(NSError *error) {
        
    }];
    
}
- (IBAction)register:(id)sender {
    [self.view endEditing:YES];
    CJProgressHUD *hud = [CJProgressHUD cjShowWithPosition:CJProgressHUDPositionBothExist timeOut:0 withText:@"加载中..." withImages:nil];
    CJWeak(self)
    [CJAPI registerWithParams:@{@"email":self.setEmail.text,@"active_code":self.code.text,@"passwd":self.setPasswd.text} success:^(NSDictionary *dic) {
        if ([dic[@"status"] intValue] == 0){
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [CJUser userWithDict:dic];
                [hud cjHideProgressHUD];
                UITabBarController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateInitialViewController];
                CJLeftXViewController *leftVC = [[CJLeftXViewController alloc]initWithMainViewController:vc];
                [weakself presentViewController:leftVC animated:NO completion:nil];
                
            }];
        }else{
            [hud cjShowError:@"注册失败!"];
        }
    } failure:^(NSError *error) {
        
    }];
    
}
-(void)textChanged{
    self.sendCode.enabled = self.setEmail.text.length && self.setPasswd.text.length;
    self.registerBtn.enabled = self.sendCode.enabled && self.code.text.length;
    self.loginBtn.enabled = self.email.text.length && self.passwd.text.length;
    self.sendCodeBtn.enabled = self.accountT.text.length && self.passwdT.text.length;
    self.resetBtn.enabled = self.sendCodeBtn.enabled && self.codeT.text.length;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:@"邮箱" attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.email.attributedPlaceholder = attrString;
    self.passwd.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"密码" attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.setEmail.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请设置邮箱" attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.setPasswd.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请设置密码" attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.code.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"验证码" attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    
    self.accountT.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"注册邮箱" attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.passwdT.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"设置新密码密码" attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.codeT.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"验证码" attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    
    self.sendCode.enabled = NO;
    self.registerBtn.enabled = NO;
    self.loginBtn.enabled = NO;
    self.sendCodeBtn.enabled = NO;
    self.resetBtn.enabled = NO;
    
    [self.code addTarget:self action:@selector(textChanged) forControlEvents:UIControlEventEditingChanged];
    [self.email addTarget:self action:@selector(textChanged) forControlEvents:UIControlEventEditingChanged];
    [self.passwd addTarget:self action:@selector(textChanged) forControlEvents:UIControlEventEditingChanged];
    [self.setPasswd addTarget:self action:@selector(textChanged) forControlEvents:UIControlEventEditingChanged];
    [self.setEmail addTarget:self action:@selector(textChanged) forControlEvents:UIControlEventEditingChanged];
    [self.codeT addTarget:self action:@selector(textChanged) forControlEvents:UIControlEventEditingChanged];
    [self.accountT addTarget:self action:@selector(textChanged) forControlEvents:UIControlEventEditingChanged];
    [self.passwdT addTarget:self action:@selector(textChanged) forControlEvents:UIControlEventEditingChanged];
    CJCornerRadius(self.loginBtn) = 5;
    CJCornerRadius(self.sendCode) = 5;
    CJCornerRadius(self.registerBtn) = 5;
    CJCornerRadius(self.sendCodeBtn) = 5;
    CJCornerRadius(self.resetBtn) = 5;
    
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

- (IBAction)forgetPasswd:(id)sender {
    [self.view endEditing:YES];
    [self.changeBtn setTitle:@"已有帐号" forState:UIControlStateNormal];
    self.leftMargin.constant = CJScreenWidth;
    
    [UIView animateWithDuration:0.5 animations:^{
        [self.view layoutIfNeeded];
    }];
    
}

- (IBAction)loginBtnClick:(UIButton *)sender {
    [self.view endEditing:YES];
    if (self.email.text.length && self.passwd.text.length){
        CJProgressHUD *hud = [CJProgressHUD cjShowWithPosition:CJProgressHUDPositionBothExist timeOut:0 withText:@"登录中..." withImages:nil];
        CJWeak(self)
        [CJAPI loginWithParams:@{@"email":self.email.text,@"passwd":self.passwd.text} success:^(NSDictionary *dic) {
            if ([dic[@"status"] intValue] == 0){
                // 保存账号和密码
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    
                    [hud cjHideProgressHUD];
                    UITabBarController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateInitialViewController];
                    CJLeftXViewController *leftVC = [[CJLeftXViewController alloc]initWithMainViewController:vc];
                    leftVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
                    [weakself presentViewController:leftVC animated:YES completion:nil];
                }];
            }
            else{
                [hud cjShowError:@"账号或密码错误!"];
            }
        } failure:^(NSError *error) {
            
        }];
        
    }
}
- (IBAction)resetBtnClick:(id)sender {
    [self.view endEditing:YES];
    CJProgressHUD *hud = [CJProgressHUD cjShowWithPosition:CJProgressHUDPositionBothExist timeOut:0 withText:@"加载中..." withImages:nil];
    CJWeak(self)
    [CJAPI registerWithParams:@{@"email":self.accountT.text,@"active_code":self.codeT.text,@"passwd":self.passwdT.text} success:^(NSDictionary *dic) {
        if ([dic[@"status"] intValue] == 0){
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [CJUser userWithDict:dic];
                [hud cjHideProgressHUD];
                UITabBarController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateInitialViewController];
                CJLeftXViewController *leftVC = [[CJLeftXViewController alloc]initWithMainViewController:vc];
                [weakself presentViewController:leftVC animated:NO completion:nil];
                
            }];
        }else{
            [hud cjShowError:@"重置失败!"];
        }
    } failure:^(NSError *error) {
        
    }];

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
