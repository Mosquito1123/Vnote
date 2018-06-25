//
//  AppDelegate+CJAppDelegateCategory.h
//  sliderViewcontroller
//
//  Created by ccj on 2017/1/16.
//  Copyright © 2017年 ccj. All rights reserved.
//

#import "AppDelegate.h"


/**********************作用:适配屏幕********************************
 用法:
 cjW(width)
 cjH(height)
 cjX(x)
 cjY(y)
 cjSize(size)
 *******************************************************************/

@interface AppDelegate (CJAutoSize)

-(CGFloat)autoRealHorizonSize:(CGFloat)estimateHorizonSize;
-(CGFloat)autoRealVerticalSize:(CGFloat)estimateVerticalSize;
-(CGFloat)autoRealSize:(CGFloat)estimateSize;

#define cjW(width) [(AppDelegate *)[UIApplication sharedApplication].delegate autoRealHorizonSize:width]
#define cjH(height) [(AppDelegate *)[UIApplication sharedApplication].delegate autoRealVerticalSize:height]
#define cjX(x) [(AppDelegate *)[UIApplication sharedApplication].delegate autoRealHorizonSize:x]
#define cjY(y) [(AppDelegate *)[UIApplication sharedApplication].delegate autoRealVerticalSize:y]
#define cjSize(size) [(AppDelegate *)[UIApplication sharedApplication].delegate autoRealSize:size]

@end
