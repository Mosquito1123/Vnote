//
//  CJBindEmailVC.m
//  VNote
//
//  Created by ccj on 2019/4/22.
//  Copyright © 2019 ccj. All rights reserved.
//

#import "CJBindEmailVC.h"

@interface CJBindEmailVC ()
@property (weak, nonatomic) IBOutlet UITextField *emailL;

@property (weak, nonatomic) IBOutlet UIButton *sendCodeBtn;
@property (weak, nonatomic) IBOutlet UITextField *codeL;
@property (weak, nonatomic) IBOutlet UIButton *bindBtn;
@property (weak, nonatomic) IBOutlet UITextField *passwdL;
@end

@implementation CJBindEmailVC
static NSInteger s1 = 0;
-(void)timmer1{
    s1 += 1;
    if (s1 == 30){
        s1 = 0;
        self.sendCodeBtn.enabled = YES;
        [self.sendCodeBtn setTitle:@"发送验证码" forState:UIControlStateDisabled];
    }
    NSString *text = [NSString stringWithFormat:@"%ld秒重发",30-s1];
    [self.sendCodeBtn setTitle:text forState:UIControlStateDisabled];
}

- (IBAction)cancelClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    CJCornerRadius(self.sendCodeBtn) = 5;
    CJCornerRadius(self.bindBtn) = 5;
    self.sendCodeBtn.enabled = NO;
    self.bindBtn.enabled = NO;
    [self.emailL addTarget:self action:@selector(textChanged) forControlEvents:UIControlEventEditingChanged];
    [self.passwdL addTarget:self action:@selector(textChanged) forControlEvents:UIControlEventEditingChanged];
    [self.codeL addTarget:self action:@selector(textChanged) forControlEvents:UIControlEventEditingChanged];
}
-(void)textChanged{
    self.sendCodeBtn.enabled = self.emailL.text.length && self.passwdL.text.length;
    self.bindBtn.enabled = self.sendCodeBtn.enabled && self.codeL.text.length;
}

- (IBAction)sendCode:(id)sender {
    CJProgressHUD *hud = [CJProgressHUD cjShowInView:self.view timeOut:TIME_OUT withText:@"发送中..." withImages:nil];
    [CJAPI requestWithAPI:API_GET_BIND_EMAIL_CODE params:@{@"email":self.emailL.text,@"nickname":[CJUser sharedUser].nickname} success:^(NSDictionary *dic) {
        [hud cjShowSuccess:@"发送成功"];
        self.sendCodeBtn.enabled = NO;
        [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timmer1) userInfo:nil repeats:YES];
    } failure:^(NSDictionary *dic) {
        [hud cjShowError:dic[@"msg"]];
    } error:^(NSError *error) {
        [hud cjShowError:net101code];
    }];
    
}
- (IBAction)bindClick:(id)sender {
    CJProgressHUD *hud = [CJProgressHUD cjShowInView:self.view timeOut:TIME_OUT withText:@"绑定中..." withImages:nil];
    CJWeak(self)
    [CJAPI requestWithAPI:API_BIND_EMAIL params:@{@"email":self.emailL.text,@"nickname":[CJUser sharedUser].nickname,@"passwd":self.passwdL.text,@"active_code":self.codeL.text} success:^(NSDictionary *dic) {
        [hud cjShowSuccess:@"绑定成功"];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakself dismissViewControllerAnimated:YES completion:nil];
        });
    } failure:^(NSDictionary *dic) {
        [hud cjShowError:dic[@"msg"]];
    } error:^(NSError *error) {
        [hud cjShowError:net101code];
    }];
    
}


@end
