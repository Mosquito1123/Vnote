//
//  CJLeftViewController.h
//  left
//
//  Created by ccj on 2018/8/14.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CJLeftSliderVC : UIViewController
-(void)hiddenLeftViewAnimation;
-(void)showLeftViewAnimation;
-(instancetype)initWithMainViewController:(UIViewController *)mainVc leftVC:(UIViewController *)leftVc;
-(void)panGes:(UIPanGestureRecognizer *)ges;

@end
