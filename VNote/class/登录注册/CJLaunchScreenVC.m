//
//  CJLaunchScreenVC.m
//  VNote
//
//  Created by ccj on 2018/7/8.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import "CJLaunchScreenVC.h"
#import "CJLoginVC.h"
@interface CJLaunchScreenVC ()
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UIButton *registerBtn;
@property (nonatomic,assign) CJAuthenType authenType;
@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;
@property (assign,nonatomic) NSTimeInterval seconds;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityView;

@end

@implementation CJLaunchScreenVC

-(void)setAuthenType:(CJAuthenType)authenType{
    _authenType = authenType;
    [self updateUI];
}
- (IBAction)login:(id)sender {
    CJLoginVC *vc = [[CJLoginVC alloc]init];
    vc.action = YES;
    [self presentViewController:vc animated:YES completion:nil];
}

- (IBAction)register:(id)sender {
    CJLoginVC *vc = [[CJLoginVC alloc]init];
    vc.action = NO;
    [self presentViewController:vc animated:YES completion:nil];
}



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = BlueBg;
    CJCornerRadius(self.loginBtn) = 5;
    CJCornerRadius(self.registerBtn) = 5;
    self.loginBtn.layer.borderWidth = 1;
    
    
    self.loginBtn.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.registerBtn.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.registerBtn.layer.borderWidth = 1;
    _authenType = CJAuthenTypeUnkonw;
    
}
-(void)resetUI:(BOOL) b{
    if (b){
        self.bgImageView.image = [UIImage imageNamed:@"登录注册"];
        
    }else{
        self.bgImageView.image = [UIImage imageNamed:@"引导页"];
    }
    self.loginBtn.hidden = self.registerBtn.hidden = !b;
}

-(void)updateUI{
    
    [self.activityView stopAnimating];
    self.activityView.hidden = YES;
    
    if (self.authenType == CJAuthenTypeUnkonw){
        [self resetUI:YES];
    }else if(self.authenType == CJAuthenTypeSuccess){
        [self resetUI:NO];
        CJWeak(self)
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            UITabBarController *tabVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateInitialViewController];
            CJLeftXViewController *leftVC = [[CJLeftXViewController alloc]initWithMainViewController:tabVC];
            [weakself presentViewController:leftVC animated:NO completion:^{
                [self resetUI:YES];
            }];
        });
    }
    
    else if(self.authenType == CJAuthenTypeWrongNet || self.authenType == CJAuthenTypeWrongAccountOrPasswd){
        // 跳入登录界面
        CJLoginVC *vc = [[CJLoginVC alloc]init];
        vc.action = YES;
        [self presentViewController:vc animated:NO completion:^{
            [self resetUI:YES];
        }];
    }
    
}

-(void)checkPasswd{
    NSUserDefaults *userD = [NSUserDefaults standardUserDefaults];
    
    CJUser *user = [CJUser userWithUserDefaults:userD];
    NSString *email = user.email;
    NSString *passwd = user.password;
    
    
    if (email.length && passwd.length){
        [self.activityView startAnimating];
        [CJAPI loginWithParams:@{@"email":email,@"passwd":passwd} success:^(NSDictionary *dic) {
            
            if ([dic[@"status"] intValue] == 0){
                self.authenType = CJAuthenTypeSuccess;
            }
            else{
                self.authenType = CJAuthenTypeWrongAccountOrPasswd;
            }
        } failure:^(NSError *error) {
            self.authenType = CJAuthenTypeWrongNet;
        }];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // 在这个地方检测账号密码是否正确,正好可以停在这个引导页面欣赏
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self checkPasswd];
    });
    

}


@end
