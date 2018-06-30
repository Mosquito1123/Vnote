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

@end

@implementation CJAccountVC
- (IBAction)logout:(id)sender {
    // 登出
    NSUserDefaults *userD = [NSUserDefaults standardUserDefaults];
    [userD removeObjectForKey:@"nickname"];
    [userD removeObjectForKey:@"passwd"];
    [userD synchronize];
    
    AppDelegate *d = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    d.window.rootViewController = [[CJLoginVC alloc]init];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSUserDefaults *userD = [NSUserDefaults standardUserDefaults];
    self.navigationItem.title = [userD valueForKey:@"nickname"];
    self.tableView.tableFooterView = [[UIView alloc]init];
    self.nicknameLabel.text = [userD valueForKey:@"email"];
    self.nicknameLabel.textColor = [UIColor whiteColor];
    self.headView.backgroundColor = BlueBg;

    
}




@end
