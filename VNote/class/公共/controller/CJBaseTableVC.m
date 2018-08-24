//
//  CJBaseTableVC.m
//  VNote
//
//  Created by ccj on 2018/8/10.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import "CJBaseTableVC.h"
#import "CJAddAccountVC.h"


@interface CJBaseTableVC ()

@property(nonatomic,strong) UIImageView *avtar;
@property(nonatomic,strong) CJDropView *dropView;
@property(nonatomic,strong) NSMutableArray <NSDictionary *> *accounts;

@end

@implementation CJBaseTableVC

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



-(CJDropView *)dropView{
    if (!_dropView){
        CJWeak(self)
        _dropView = [CJDropView cjShowDropVieWAnimationWithOption:CJDropViewAnimationTypeFadeInFadeOut tranglePosition:CJTranglePositionLeft cellModelArray:self.accounts detailAttributes:@{} cjDidSelectRowAtIndex:^(NSInteger index) {
            if (index == weakself.accounts.count){
                CJAddAccountVC *vc = [[CJAddAccountVC alloc]init];
                vc.modalPresentationStyle = UIModalPresentationOverFullScreen;
                [weakself presentViewController:vc animated:YES completion:nil];
                return ;
            }
            CJProgressHUD *hud = [CJProgressHUD cjShowWithPosition:CJProgressHUDPositionBothExist timeOut:0 withText:@"切换中..." withImages:nil];
            NSDictionary *dict = self.accounts[index];
            [CJAPI loginWithParams:@{@"email":dict[@"email"],@"passwd":dict[@"password"]} success:^(NSDictionary *dic) {
                if ([dic[@"status"] integerValue] == 0){
                    
                    [hud cjShowSuccess:@"切换成功"];
                    
                }else{
                    [hud cjShowError:@"切换失败!"];
                }
                
            } failure:^(NSError *error) {
                [hud cjShowError:@"切换失败!"];
            }];
        } hideCompletion:^{
            
        }];
        
    }
    return _dropView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    CJUser *user = [CJUser sharedUser];
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 35, 35)];
    imgView.backgroundColor = [UIColor whiteColor];
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeAccountNoti:) name:LOGIN_ACCOUT_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accountNumNoti:) name:ACCOUNT_NUM_CHANGE_NOTI object:nil];
}
-(void)accountNumNoti:(NSNotification *)noti{
    if ([noti.name isEqualToString:ACCOUNT_NUM_CHANGE_NOTI]){
        self.accounts = nil;
        self.dropView.cjDropViewCellModelArray = self.accounts;
        [self.dropView cjResetDropView];
    }
}

-(void)changeAccountNoti:(NSNotification *)noti{
    
    CJUser *user = [CJUser sharedUser];
    [self.avtar yy_setImageWithURL:IMG_URL(user.avtar_url) placeholder:[UIImage imageNamed:@"avtar"]];
    self.accounts = nil;
    self.dropView.cjDropViewCellModelArray = self.accounts;
    [self.dropView cjResetDropView];
    
}

-(void)longTap:(UILongPressGestureRecognizer *)ges{
    
    if (_dropView && _dropView.isShow) return ;
    UIImpactFeedbackGenerator*impactLight = [[UIImpactFeedbackGenerator alloc]initWithStyle:UIImpactFeedbackStyleMedium];
    [impactLight impactOccurred];
    
    [self.dropView cjShowDropViewCompletion:^{
        
    }];
    
}


-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
