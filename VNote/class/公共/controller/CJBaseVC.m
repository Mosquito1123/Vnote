//
//  CJBaseVC.m
//  VNote
//
//  Created by ccj on 2018/7/30.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import "CJBaseVC.h"

@interface CJBaseVC ()

@property(nonatomic,strong) UIImageView *avtar;
@end

@implementation CJBaseVC
-(void)showLeft{
    DBHWindow *window = (DBHWindow *)[UIApplication sharedApplication].keyWindow;
    [window showLeftViewAnimation];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    CJUser *user = [CJUser sharedUser];
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
    UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
    self.avtar = imgView;
    if ([user.avtar_url length]){
        imgView.yy_imageURL = IMG_URL(user.avtar_url);
        
    }else{
        imgView.image = [UIImage imageNamed:@"avtar.png"];
    }
    imgView.yy_imageURL = IMG_URL(user.avtar_url);
    imgView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showLeft)];
    [imgView addGestureRecognizer:tap];
    [view addSubview:imgView];
    CJCornerRadius(imgView) = imgView.cj_width / 2;

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:view];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeAccountNoti:) name:CHANGE_ACCOUNT_NOTI object:nil];
}
-(void)changeAccountNoti:(NSNotification *)noti{
    if([noti.name isEqualToString:CHANGE_ACCOUNT_NOTI]){
        CJUser *user = [CJUser sharedUser];
        if ([user.avtar_url length]){
            self.avtar.yy_imageURL = IMG_URL(user.avtar_url);
            
        }else{
            self.avtar.image = [UIImage imageNamed:@"avtar.png"];
        }
    }
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
