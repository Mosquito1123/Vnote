//
//  CJLoginVC.m
//
//  Created by ccj on 2017/5/8.
//  Copyright © 2017年 ccj. All rights reserved.
//

#import "CJLoginVC.h"
#import "CJMainVC.h"
#import "AppDelegate.h"
#import "CJMainNaVC.h"
#import "CJProtocolVC.h"
@interface CJLoginVC ()<UIPopoverPresentationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIView *loginBgView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logoLeftMagin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *loginBtnTopMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightMargin;
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
@property (assign) int flag; // flag = 0 登录;-1：忘记密码 ;1:注册
@property (strong, nonatomic) CJProtocolVC *protocolVc;
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
- (IBAction)protocolBtnClick:(id)sender {
    CJProtocolVC *vc = [[CJProtocolVC alloc]init];
    self.protocolVc = vc;
    vc.modalPresentationStyle = UIModalPresentationPopover;
    vc.preferredContentSize = CGSizeMake(CJScreenWidth - 40, CJScreenHeight - 80);
    UIPopoverPresentationController *popController = vc.popoverPresentationController;
    popController.backgroundColor = [UIColor whiteColor];
    popController.delegate = self;
    popController.permittedArrowDirections = UIPopoverArrowDirectionDown;
    UIButton *button = sender;
    popController.sourceView = button.superview;
    popController.sourceRect = button.superview.bounds;
    [self presentViewController:vc animated:YES completion:nil];
    
}


- (BOOL)popoverPresentationControllerShouldDismissPopover:(UIPopoverPresentationController *)popoverPresentationController;
{
    return YES;
}

-(UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
    return UIModalPresentationNone;
}

- (IBAction)getResetCode:(id)sender {
    CJWeak(self)
    CJProgressHUD *hud = [CJProgressHUD cjShowInView:self.view timeOut:TIME_OUT withText:@"发送中..." withImages:nil];
    [CJAPI requestWithAPI:API_GET_CODE params:@{@"email":weakself.accountT.text} success:^(NSDictionary *dic) {
        [hud cjShowSuccess:@"发送成功"];
        weakself.sendCodeBtn.enabled = NO;
        [NSTimer scheduledTimerWithTimeInterval:1 target:weakself selector:@selector(timmer2) userInfo:nil repeats:YES];
    } failure:^(NSDictionary *dic) {
        [hud cjShowError:dic[@"msg"]];
    } error:^(NSError *error) {
        [hud cjShowError:net101code];
    }];
}
- (IBAction)getCode:(id)sender {
    CJWeak(self)
    CJProgressHUD *hud = [CJProgressHUD cjShowInView:self.view timeOut:TIME_OUT withText:@"发送中..." withImages:nil];
    [CJAPI requestWithAPI:API_GET_CODE params:@{@"email":weakself.setEmail.text} success:^(NSDictionary *dic) {
        [hud cjShowSuccess:@"发送成功"];
        weakself.sendCodeBtn.enabled = NO;
        [NSTimer scheduledTimerWithTimeInterval:1 target:weakself selector:@selector(timmer2) userInfo:nil repeats:YES];
    } failure:^(NSDictionary *dic) {
        [hud cjShowError:dic[@"msg"]];
    } error:^(NSError *error) {
        [hud cjShowError:net101code];
    }];
    
}
- (IBAction)register:(id)sender {
    [self.view endEditing:YES];
    
    CJProgressHUD *hud = [CJProgressHUD cjShowInView:self.view timeOut:TIME_OUT withText:@"加载中..." withImages:nil];
    CJWeak(self)
    [CJAPI requestWithAPI:API_REGISTER params:@{@"email":weakself.setEmail.text,@"active_code":weakself.code.text,@"passwd":weakself.setPasswd.text} success:^(NSDictionary *dic) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [CJUser userWithDict:dic];
            [hud cjHideProgressHUD];
            UITabBarController *mainVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateInitialViewController];
            CJAddNoteVC *addNoteVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"addNoteVC"];
            CJMainNaVC *leftVC = [[CJMainNaVC alloc]initWithRootViewController:addNoteVC];
            CJLeftSliderVC *sliderVC = [[CJLeftSliderVC alloc]initWithMainViewController:mainVC leftVC:leftVC];
            UIWindow *w = [UIApplication sharedApplication].keyWindow;
            w.rootViewController = sliderVC;
            
        }];
    } failure:^(NSDictionary *dic) {
        [hud cjShowError:@"注册失败!"];
    } error:^(NSError *error) {
        [hud cjShowError:net101code];
    }];
    
}
-(void)textChanged{
    self.sendCode.enabled = self.setEmail.text.length && self.setPasswd.text.length;
    self.registerBtn.enabled = self.sendCode.enabled && self.code.text.length;
    self.loginBtn.enabled = self.email.text.length && self.passwd.text.length;
    self.sendCodeBtn.enabled = self.accountT.text.length && self.passwdT.text.length;
    self.resetBtn.enabled = self.sendCodeBtn.enabled && self.codeT.text.length;
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    self.rightMargin.constant = self.leftMargin.constant = self.loginBtnTopMargin.constant = 100.f;
    [self.view layoutIfNeeded];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    CJWeak(self)
    weakself.loginBtnTopMargin.constant = 25.f;
    weakself.logoLeftMagin.constant = 20.f;
    [UIView animateWithDuration:0.5 animations:^{
        [weakself.view layoutIfNeeded];
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:@"邮箱" attributes:@{NSForegroundColorAttributeName:[UIColor grayColor]}];
    self.email.attributedPlaceholder = attrString;
    self.passwd.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"密码" attributes:@{NSForegroundColorAttributeName:[UIColor grayColor]}];
    self.setEmail.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请设置邮箱" attributes:@{NSForegroundColorAttributeName:[UIColor grayColor]}];
    self.setPasswd.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请设置密码" attributes:@{NSForegroundColorAttributeName:[UIColor grayColor]}];
    self.code.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"验证码" attributes:@{NSForegroundColorAttributeName:[UIColor grayColor]}];
    
    
    self.accountT.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"注册邮箱" attributes:@{NSForegroundColorAttributeName:[UIColor grayColor]}];
    self.passwdT.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"设置新密码密码" attributes:@{NSForegroundColorAttributeName:[UIColor grayColor]}];
    self.codeT.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"验证码" attributes:@{NSForegroundColorAttributeName:[UIColor grayColor]}];
    
    
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
    
    CJUser *user = [CJUser sharedUser];
    if (!user.is_tourist){
        self.email.text = user.email;
    }
    self.flag = 0;
}

// 游客登录
- (IBAction)loginWithTourist:(id)sender {
    // 向服务器请求一个游客的账号进行登录
    CJProgressHUD *hud = [CJProgressHUD cjShowInView:self.view timeOut:TIME_OUT withText:@"初始化..." withImages:nil];
    NSString *uuid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSLog(@"uuid=%@",uuid);
    [CJAPI requestWithAPI:API_REGISTER_TOURIST params:@{@"uuid":uuid} success:^(NSDictionary *dic) {
        [CJUser userWithDict:dic];
        [CJTool catchAccountInfo2Preference:dic];
        [hud cjHideProgressHUD];
        UITabBarController *mainVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateInitialViewController];
        CJAddNoteVC *addNoteVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"addNoteVC"];
        CJMainNaVC *leftVC = [[CJMainNaVC alloc]initWithRootViewController:addNoteVC];
        CJLeftSliderVC *sliderVC = [[CJLeftSliderVC alloc]initWithMainViewController:mainVC leftVC:leftVC];
        UIWindow *w = [UIApplication sharedApplication].keyWindow;
        w.rootViewController = sliderVC;
    } failure:^(NSDictionary *dic) {
        [hud cjShowError:dic[@"msg"]];
    } error:^(NSError *error) {
        [hud cjShowError:net101code];
    }];
}

-(void)viewWillLayoutSubviews{
    CGFloat m = 0;
    CGFloat w = self.view.safeAreaInsets.left;
    if (self.flag == 0) {
        
    }else if (self.flag == -1){
        // 忘记密码
        m = CJScreenWidth - 2*w;
    }else if (self.flag == 1){
        m = -(CJScreenWidth - 2*w);
    }
    self.rightMargin.constant = self.leftMargin.constant = m;
    [self.view layoutIfNeeded];
    self.protocolVc.preferredContentSize = CGSizeMake(CJScreenWidth - 40, CJScreenHeight - 80);
}


- (IBAction)forgetPasswd:(id)sender {
    self.flag = -1;
    [self.view endEditing:YES];
    [self.changeBtn setTitle:@"已有帐号" forState:UIControlStateNormal];
    self.rightMargin.constant = self.leftMargin.constant = self.loginBgView.cj_width;
    CJWeak(self)
    [UIView animateWithDuration:0.5 animations:^{
        [weakself.view layoutIfNeeded];
    }];
    
}

- (IBAction)loginBtnClick:(UIButton *)sender {
    [self.view endEditing:YES];
    CJWeak(self)
    if (self.email.text.length && self.passwd.text.length){
        CJProgressHUD *hud = [CJProgressHUD cjShowInView:self.view timeOut:TIME_OUT withText:@"登录中..." withImages:nil];
        [CJAPI requestWithAPI:API_LOGIN params:@{@"email":weakself.email.text,@"passwd":weakself.passwd.text} success:^(NSDictionary *dic) {
            // 保存账号和密码
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                
                [hud cjHideProgressHUD];
                UITabBarController *mainVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateInitialViewController];
                CJAddNoteVC *addNoteVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"addNoteVC"];
                CJMainNaVC *leftVC = [[CJMainNaVC alloc]initWithRootViewController:addNoteVC];
                CJLeftSliderVC *sliderVC = [[CJLeftSliderVC alloc]initWithMainViewController:mainVC leftVC:leftVC];
                UIWindow *w = [UIApplication sharedApplication].keyWindow;
                w.rootViewController = sliderVC;
            }];
        } failure:^(NSDictionary *dic) {
            [hud cjShowError:@"账号或密码错误!"];
        } error:^(NSError *error) {
            [hud cjShowError:net101code];
        }];
        
    }
}
- (IBAction)resetBtnClick:(id)sender {
    [self.view endEditing:YES];
    CJWeak(self)
    CJProgressHUD *hud = [CJProgressHUD cjShowInView:self.view timeOut:TIME_OUT withText:@"加载中..." withImages:nil];
    [CJAPI requestWithAPI:API_REGISTER params:@{@"email":weakself.accountT.text,@"active_code":weakself.codeT.text,@"passwd":weakself.passwdT.text} success:^(NSDictionary *dic) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [hud cjHideProgressHUD];
            UITabBarController *mainVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateInitialViewController];
            CJAddNoteVC *addNoteVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"addNoteVC"];
            CJMainNaVC *leftVC = [[CJMainNaVC alloc]initWithRootViewController:addNoteVC];
            CJLeftSliderVC *sliderVC = [[CJLeftSliderVC alloc]initWithMainViewController:mainVC leftVC:leftVC];
            UIWindow *w = [UIApplication sharedApplication].keyWindow;
            w.rootViewController = sliderVC;
            
        }];
    } failure:^(NSDictionary *dic) {
        [hud cjShowError:@"重置失败!"];
    } error:^(NSError *error) {
        [hud cjShowError:net101code];
    }];

}
- (IBAction)registerBtnClick:(UIButton *)sender {
    
    
    //退出键盘
    [self.view endEditing:YES];
    if([[sender titleForState:UIControlStateNormal] isEqualToString:@"注册帐号"])
    {
        [sender setTitle:@"已有帐号" forState:UIControlStateNormal];
        self.rightMargin.constant = self.leftMargin.constant = -self.loginBgView.cj_width;
        
        self.flag = 1;
    }
    else
    {
        [sender setTitle:@"注册帐号" forState:UIControlStateNormal];
        self.rightMargin.constant = self.leftMargin.constant = 0;
        self.flag = 0;
    }
    
    [UIView animateWithDuration:0.5 animations:^{
        [self.view layoutIfNeeded];
    }];
    
    
}


-(UIStatusBarStyle)preferredStatusBarStyle
{

    return UIStatusBarStyleLightContent;
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{

    //退出键盘
    [self.view endEditing:YES];
    
}



@end
