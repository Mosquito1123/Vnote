//
//  AppDelegate+CJAppDelegateCategory.m
//  sliderViewcontroller
//
//  Created by ccj on 2017/1/16.
//  Copyright © 2017年 ccj. All rights reserved.
//

#import "AppDelegate+CJAppDelegateCategory.h"

#define CJScreenWidth [UIScreen mainScreen].bounds.size.width
#define CJScreenHeight [UIScreen mainScreen].bounds.size.height
@implementation AppDelegate (CJAutoSize)

/*
 这边拿6作参考375—667
 5/5s/5c/SE:320---568
 6/6s/7:375—667
 6p/6sp/7p:414–736
*/

//水平的比例
static CGFloat horizonScale;

//垂直的比例
static CGFloat verticalScale;

-(CGFloat)autoRealHorizonSize:(CGFloat)estimateHorizonSize
{
    return estimateHorizonSize*horizonScale;

}

-(CGFloat)autoRealVerticalSize:(CGFloat)estimateVerticalSize
{
    return estimateVerticalSize*verticalScale;
}

-(CGFloat)autoRealSize:(CGFloat)estimateSize
{
    return estimateSize*(horizonScale+verticalScale)/2.0;
}

//得到一个比例
+(void)load
{
    horizonScale=CJScreenWidth/375;
    verticalScale=CJScreenHeight/667;

}




@end
