//
//  CJAccountVC.m
//  VNote
//
//  Created by ccj on 2018/6/10.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import "CJAccountVC.h"
#import "AppDelegate.h"
#import "CJLoginVC.h"
@interface CJAccountVC ()
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;
@property (weak, nonatomic) IBOutlet UIView *headView;
@property (weak, nonatomic) IBOutlet UIImageView *avtarImg;

@end

@implementation CJAccountVC
- (IBAction)logout:(id)sender {
    // 登出
    NSUserDefaults *userD = [NSUserDefaults standardUserDefaults];
    [userD removeObjectForKey:@"nickname"];
    [userD removeObjectForKey:@"password"];
    [userD synchronize];
    
    AppDelegate *d = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    d.window.rootViewController = [[CJLoginVC alloc]init];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    CJUser *user = [CJUser sharedUser];
    self.navigationItem.title = user.nickname;
    self.tableView.tableFooterView = [[UIView alloc]init];
    self.nicknameLabel.text = user.email;
    self.nicknameLabel.textColor = [UIColor whiteColor];
    self.headView.backgroundColor = BlueBg;
    self.avtarImg.backgroundColor = [UIColor whiteColor];
    if (user.avtar_url.length){
        NSLog(@"%@",IMG_URL(user.avtar_url));
        
        self.avtarImg.yy_imageURL = IMG_URL(user.avtar_url);
    }else{
        self.avtarImg.image = [UIImage imageNamed:@"avtar.png"];
    }
    CJCornerRadius(self.avtarImg)=self.avtarImg.cj_height/2;

    
}




@end
