//
//  CJBaseVC.m
//  VNote
//
//  Created by ccj on 2018/7/30.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import "CJBaseVC.h"
#import "CJAddAccountVC.h"
#import "CJDropMenuVC.h"
#import "CJTabBarVC.h"
@interface CJBaseVC ()<UIPopoverPresentationControllerDelegate>

@property(nonatomic,strong) UIImageView *avtar;
@property(nonatomic,strong) NSMutableArray <NSDictionary *> *accounts;
@property(nonatomic,weak) CJDropMenuVC *menuVC;

@end

@implementation CJBaseVC


-(NSMutableArray *)accounts{
    if (!_accounts){
        _accounts = [NSMutableArray array];
        NSUserDefaults *userD = [NSUserDefaults standardUserDefaults];
        NSMutableArray *array = [NSMutableArray arrayWithArray:[userD objectForKey:ALL_ACCOUNT]];
        CJUser *user = [CJUser sharedUser];
        for (NSDictionary *d in array) {
            if ([d[@"email"] isEqualToString:user.email])continue;
            [_accounts addObject:d];
        }
    }
    return _accounts;
}

-(void)showLeft{
    [[NSNotificationCenter defaultCenter] postNotificationName:AVTAR_CLICK_NOTI object:nil];
}

-(void)addAvtar{
    CJUser *user = [CJUser sharedUser];
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
    CGFloat h = self.navigationController.navigationBar.cj_height;
    imgView.cj_height = imgView.cj_width = h - 7;
    imgView.cj_centerY = view.cj_height / 2;
    imgView.backgroundColor = [UIColor whiteColor];
    imgView.layer.borderWidth = 1;
    imgView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.avtar = imgView;
    [self.avtar yy_setImageWithURL:IMG_URL(user.avtar_url) placeholder:[UIImage imageNamed:@"avtar"]];
    
    view.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showLeft)];
    [view addGestureRecognizer:tap];
    [view addSubview:imgView];
    
    
    UILongPressGestureRecognizer *longTap = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longTap:)];
    longTap.minimumPressDuration = 0.2;
    [view addGestureRecognizer:longTap];
    
    CJCornerRadius(imgView) = imgView.cj_width / 2;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:view];
}

- (void)viewDidLoad {
    [super viewDidLoad];
   
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeAccountNoti:) name:LOGIN_ACCOUT_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accountNumNoti:) name:ACCOUNT_NUM_CHANGE_NOTI object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(rotateChange) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(rotateChange) name:UIDeviceOrientationDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(statusChange) name:STATUS_FRAME_CHANGE_NOTI object:nil];
    [self statusChange];
}

-(void)statusChange{
//    CJLog(@"STATUS=%f--tabBar=%f--navigationBar=%f",STATUSH,self.tabBarController.tabBar.cj_height,self.navigationController.navigationBar.cj_height);
//    self.view.cj_height = CJScreenHeight - STATUSH - self.tabBarController.tabBar.cj_height - self.navigationController.navigationBar.cj_height;
    
}

-(void)rotateChange{
    
    CGFloat h = self.navigationController.navigationBar.cj_height;
    self.avtar.cj_height = self.avtar.cj_width = h - 7;
    CJCornerRadius(self.avtar) = self.avtar.cj_width / 2;
    self.avtar.cj_centerY = self.avtar.superview.cj_height / 2;
    
}
-(void)accountNumNoti:(NSNotification *)noti{
    if ([noti.name isEqualToString:ACCOUNT_NUM_CHANGE_NOTI]){
        self.accounts = nil;
        
    }
}



-(void)changeAccountNoti:(NSNotification *)noti{

    CJUser *user = [CJUser sharedUser];
    [self.avtar yy_setImageWithURL:IMG_URL(user.avtar_url) placeholder:[UIImage imageNamed:@"avtar"]];
    self.accounts = nil;
    
}



-(void)longTap:(UILongPressGestureRecognizer *)ges{
    if (!self.menuVC){
        UIImpactFeedbackGenerator*impactLight = [[UIImpactFeedbackGenerator alloc]initWithStyle:UIImpactFeedbackStyleMedium];
        [impactLight impactOccurred];
        CJDropMenuVC *vc = [[CJDropMenuVC alloc]init];
        self.menuVC = vc;
        vc.accounts = self.accounts;
        CJWeak(self)
        vc.didSelectIndex = ^(NSInteger index){
            if (index == weakself.accounts.count){
                CJAddAccountVC *vc = [[CJAddAccountVC alloc]init];
                vc.modalPresentationStyle = UIModalPresentationOverFullScreen;
                [weakself presentViewController:vc animated:YES completion:nil];
                return ;
            }
            CJProgressHUD *hud = [CJProgressHUD cjShowInView:self.view timeOut:TIME_OUT withText:@"切换中..." withImages:nil];

            NSDictionary *dict = self.accounts[index];
            [CJAPI loginWithParams:@{@"email":dict[@"email"],@"passwd":dict[@"password"]} success:^(NSDictionary *dic) {
                if ([dic[@"status"] integerValue] == 0){
                    
                    [hud cjShowSuccess:@"切换成功"];
                    
                }else{
                    //  来到这说明密码错误，重新登录
                    CJTabBarVC *tabVC = (CJTabBarVC *)self.tabBarController;
                    CJLeftXViewController *vc = (CJLeftXViewController *)[tabVC parentViewController];
                    [vc toRootViewController];
                    NSUserDefaults *userD = [NSUserDefaults standardUserDefaults];
                    [userD removeObjectForKey:@"email"];
                    [userD removeObjectForKey:@"password"];
                    [userD synchronize];
                }
                
            } failure:^(NSError *error) {
                [hud cjShowError:net101code];
            }];
        };
        CGFloat menuH = (self.accounts.count + 1) * 40.0;
        vc.preferredContentSize = CGSizeMake(150, menuH);
        vc.modalPresentationStyle = UIModalPresentationPopover;
        UIPopoverPresentationController *popController = vc.popoverPresentationController;
        popController.backgroundColor = [UIColor whiteColor];
        popController.delegate = self;
        popController.permittedArrowDirections = UIPopoverArrowDirectionUp;
        popController.barButtonItem = self.navigationItem.leftBarButtonItem;
        
        [self presentViewController:vc animated:YES completion:nil];
    }
    
    
}
-(UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
    return UIModalPresentationNone;
}


-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
