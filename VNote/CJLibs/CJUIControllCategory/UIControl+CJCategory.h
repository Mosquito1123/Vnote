//
//  UIControl+CJCategory.h
//  百思不得姐
//
//  Created by ccj on 2017/5/10.
//  Copyright © 2017年 ccj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIControl (didRespondTarget)


@property(nonatomic,strong)NSMutableDictionary *dictM;

-(void)cjRespondTargetForControlEvents:(UIControlEvents)events actionBlock:(void (^)(UIControl *control))block;


@end
