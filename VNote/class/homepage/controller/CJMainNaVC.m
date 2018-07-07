//
//  CJMainNaVC.m
//  VNote
//
//  Created by ccj on 2018/6/1.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import "CJMainNaVC.h"
#import "CJMainVC.h"
//#include "CJConfig.h"
@interface CJMainNaVC ()

@end

@implementation CJMainNaVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UITabBarItem *item = [UITabBarItem appearance];
    NSMutableDictionary *normalAttrs = [NSMutableDictionary dictionary];
    normalAttrs[NSFontAttributeName] = [UIFont systemFontOfSize:14];
    normalAttrs[NSForegroundColorAttributeName] = HeadFontColor;
    [item setTitleTextAttributes:normalAttrs forState:UIControlStateNormal];
    
    NSMutableDictionary *selectedAttrs = [NSMutableDictionary dictionary];
    selectedAttrs[NSForegroundColorAttributeName] = BlueBg;
    [item setTitleTextAttributes:selectedAttrs forState:UIControlStateSelected];
    
    UINavigationBar *navBar = [UINavigationBar appearance];
    navBar.barTintColor = BlueBg;
    navBar.translucent = NO;
    navBar.tintColor = [UIColor whiteColor];
    [navBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];

    
}

-(void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated{
    if (self.childViewControllers.count) {
        viewController.hidesBottomBarWhenPushed = YES;
        CJWeak(self)
        viewController.navigationItem.leftBarButtonItem = [UIBarButtonItem backItemWithNormalImage:@"back" highImage:nil backTitle:nil backTitleNormalColor:nil backTitleHighColor:nil didClick:^(UIControl *control) {
            [weakself popViewControllerAnimated:YES];
        }];
    }
    
    [super pushViewController:viewController animated:YES];
    
}



-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}



@end
