//
//  UIBarButtonItem+CJBarButtonItemCategory.h
//  百思不得姐
//
//  Created by ccj on 2017/5/4.
//  Copyright © 2017年 ccj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBarButtonItem (CJBarButtonItemCategory)
//普通的UIBarButtonItem
+(instancetype)itemWithNormalImage:(NSString *)normalImage highImage:(NSString *)highImage showsTouchWhenHighlighted:(BOOL)highlight didClick:(void (^)(UIControl *control))didClickBlock;

//返回UIBarButtonItem

+(instancetype)backItemWithNormalImage:(NSString *)normalImage highImage:(NSString *)highImage backTitle:(NSString *)backTitle  backTitleNormalColor:(UIColor *)normalColor backTitleHighColor:(UIColor *)highColor  didClick:(void (^)(UIControl *control))didClickBlock;



@end
