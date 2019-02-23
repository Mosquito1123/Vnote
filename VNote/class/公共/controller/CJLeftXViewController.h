//
//  CJLeftViewController.h
//  left
//
//  Created by ccj on 2018/8/14.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CJLeftXViewController : CJBaseVC
-(void)hiddenLeftViewAnimation;
-(void)showLeftViewAnimation;
-(instancetype)initWithMainViewController:(UIViewController *)mainVc;
-(void)toRootViewController;
@end
