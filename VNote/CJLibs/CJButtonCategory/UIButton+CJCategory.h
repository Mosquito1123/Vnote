//
//  UIButton+CJButtonCategory.h
//  sliderViewcontroller
//
//  Created by ccj on 2017/1/11.
//  Copyright © 2017年 ccj. All rights reserved.
//

#import <UIKit/UIKit.h>


/*******************作用:UIButton分类positionStyle声明部分*************
 一、用法:
 1>按照ios原来的方法创建自定义button
 2>设置button的cjPositionStyle(图片和标题的位置)
 3>设置图片和标题的位置的之间的间隙
 
 二、注意:
 注:如果需要微调，可以设置contentEdgeInsets属性（button内置属性）
 UIEdgeInsetsMake(top,left,bottom,right)
 top:+下移  -上移
 bottom:+上移  -下移
 left:+右移 -左移
 right:+左移  -右移
 *******************************************************************/
typedef NS_ENUM(NSInteger,CJButtonPositionStyle)
{
    CJButtonPositionLeftImageRightTitle=0,
    CJButtonPositionLeftTitleRightImage,
    CJButtonPositionTopImageBottomTitle,
    CJButtonPositionTopTitleBottomImage,
    CJButtonPositionCenter,
};
@interface UIButton (positionStyle)
//设置button图片和文本框的属性
@property(nonatomic,assign)CJButtonPositionStyle cjPositionStyle;

//设置button图片和文本之间的间距
@property(nonatomic,assign)CGFloat cjSpace;


@end






