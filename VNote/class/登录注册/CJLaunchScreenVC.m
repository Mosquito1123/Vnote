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
@property (nonatomic,assign) BOOL isAuthented;
@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;
@property (assign,nonatomic) NSTimeInterval seconds;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityView;

@end

@implementation CJLaunchScreenVC
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

}
-(void)checkPasswd{
    NSUserDefaults *userD = [NSUserDefaults standardUserDefaults];
    
    CJUser *user = [CJUser userWithUserDefaults:userD];
    NSString *email = user.email;
    NSString *passwd = user.password;
    UIImage *img;
    if (email.length && passwd.length){
        [self.activityView startAnimating];
        [CJAPI loginWithParams:@{@"email":email,@"passwd":passwd} success:^(NSDictionary *dic) {
            
            if ([dic[@"status"] intValue] == 0){
                self.isAuthented = YES;
            }
            else{
                self.isAuthented = NO;
            }
        } failure:^(NSError *error) {
            self.isAuthented = NO;
        }];
        self.isAuthented = YES;
        
        
    }else{
        self.isAuthented = NO;
    }
    if (self.isAuthented){
        img = [UIImage imageNamed:@"引导页"];
    }else{
        img = [UIImage imageNamed:@"登录注册"];
    }
    
    self.bgImageView.image = img;
    self.loginBtn.hidden = self.registerBtn.hidden = self.isAuthented;
}

-(void)viewDidAppear:(BOOL)animated
{
    // 在这个地方检测账号密码是否正确,正好可以停在这个引导页面欣赏
    [self checkPasswd];
    if (self.isAuthented){
        CJWeak(self)
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            weakself.activityView.hidden = YES;
            UITabBarController *tabVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateInitialViewController];
            CJLeftXViewController *leftVC = [[CJLeftXViewController alloc]initWithMainViewController:tabVC];
            [weakself presentViewController:leftVC animated:NO completion:nil];
        });
    }
}


@end
