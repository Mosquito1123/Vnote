//
//  CJFavouriteVC.m
//  VNote
//
//  Created by ccj on 2018/8/25.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import "CJFavouriteVC.h"

@interface CJFavouriteVC ()

@end

@implementation CJFavouriteVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"收藏";
    self.rt_navigationController.tabBarItem.title = @"收藏";
    self.rt_navigationController.tabBarItem.image = [UIImage imageNamed:@"收藏灰"];
    self.rt_navigationController.tabBarItem.selectedImage = [UIImage imageNamed:@"收藏蓝"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
