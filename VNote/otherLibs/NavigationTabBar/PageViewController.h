//
//  PageViewController.h
//  DLNavigationTabBar
//
//  Created by FT_David on 2016/12/4.
//  Copyright © 2016年 FT_David. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^TabBarDidClickAtIndex)(NSInteger buttonIndex);
@interface PageViewController : UIPageViewController
-(void)cjNavigationSliderControllerWithTitles:(NSArray *)titles titleSelectColor:(UIColor *)selectColor normalColor:(UIColor *)normalColor subviewControllers:(NSArray <UIViewController *>*)vcs didClickItem:(TabBarDidClickAtIndex)click;

@end
