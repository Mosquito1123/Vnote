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
@property (weak, nonatomic) IBOutlet UIView *headView;
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;

@end

@implementation CJAccountVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSUserDefaults *userD = [NSUserDefaults standardUserDefaults];
    self.navigationItem.title = [userD valueForKey:@"nickname"];
//    self.navigationController.navigationBar.barTintColor = MainBg;
//    self.headView.backgroundColor = BlueBg;
    self.tableView.tableFooterView = [[UIView alloc]init];
    self.tableView.backgroundColor = MainBg;
    self.nicknameLabel.text = [userD valueForKey:@"email"];
//    self.nicknameLabel.textColor = HeadFontColor;
//    self.navigationItem.rightBarButtonItem.tintColor = HeadFontColor;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0 && indexPath.row == 1){
        // 登出
        NSUserDefaults *userD = [NSUserDefaults standardUserDefaults];
        [userD removeObjectForKey:@"nickname"];
        [userD removeObjectForKey:@"passwd"];
        [userD synchronize];
        
        AppDelegate *d = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        d.window.rootViewController = [[CJLoginVC alloc]init];
    }
}


@end
