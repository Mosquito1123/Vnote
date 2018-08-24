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

@end

@implementation CJLaunchScreenVC
- (IBAction)login:(id)sender {
    CJLoginVC *vc = [[CJLoginVC alloc]init];
    vc.action = YES;
    vc.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:vc animated:YES completion:nil];
}

- (IBAction)register:(id)sender {
    CJLoginVC *vc = [[CJLoginVC alloc]init];
    vc.action = NO;
    vc.modalPresentationStyle = UIModalPresentationOverFullScreen;
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
-(void)viewWillAppear:(BOOL)animated{
    NSUserDefaults *userD = [NSUserDefaults standardUserDefaults];
    NSString *email = [userD valueForKey:@"email"];
    NSString *passwd = [userD valueForKey:@"password"];
    [CJUser userWithUserDefaults:userD];
    UIImage *img;
    if (email && passwd){
        self.isAuthented = YES;
        self.seconds = 0;
        img = [UIImage imageNamed:@"引导页"];
    }else{
        self.isAuthented = NO;
        self.seconds = 0;
        img = [UIImage imageNamed:@"登录注册"];
    }
    self.bgImageView.image = img;
    self.loginBtn.hidden = self.registerBtn.hidden = self.isAuthented;
}

-(void)viewDidAppear:(BOOL)animated
{
    if (self.isAuthented){
        CJWeak(self)
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.seconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            UITabBarController *tabVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateInitialViewController];
            CJLeftXViewController *leftVC = [[CJLeftXViewController alloc]initWithMainViewController:tabVC];
            leftVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
            [weakself presentViewController:leftVC animated:NO completion:nil];
        });
    }
    
    
    
}


@end
