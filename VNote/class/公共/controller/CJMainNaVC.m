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
@interface CJMainNaVC ()<UIGestureRecognizerDelegate>

@end

@implementation CJMainNaVC

- (void)viewDidLoad {
    [super viewDidLoad];

    
    UINavigationBar *navBar = [UINavigationBar appearance];
    navBar.barTintColor = BlueBg;
    navBar.translucent = NO;
    navBar.tintColor = [UIColor whiteColor];
    [navBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    self.interactivePopGestureRecognizer.delegate = self;
}

-(void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated{
    if (self.childViewControllers.count) {
        viewController.hidesBottomBarWhenPushed = YES;
        viewController.navigationItem.backBarButtonItem = [UIBarButtonItem backItemWithNormalImage:@"back" highImage:nil backTitle:@"返回" backTitleNormalColor:[UIColor whiteColor] backTitleHighColor:nil didClick:nil];

    }
    
    
    [super pushViewController:viewController animated:animated];
    
    
}

//监听代理方法，侧滑手势
-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    //说明是导航控制器的根控制器，根控制器不会再有pop手势了
    if(self.childViewControllers.count == 1)
    {
        return NO;
    }
    return YES;
}


-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}





@end
