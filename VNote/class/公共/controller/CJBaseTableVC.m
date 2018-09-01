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
        
    }
}

-(void)changeAccountNoti:(NSNotification *)noti{
    
    CJUser *user = [CJUser sharedUser];
    [self.avtar yy_setImageWithURL:IMG_URL(user.avtar_url) placeholder:[UIImage imageNamed:@"avtar"]];
    self.accounts = nil;
    
}

-(void)longTap:(UILongPressGestureRecognizer *)ges{
    
   
}


-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
