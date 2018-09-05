//
//  UIView+CJViewExtension.h
//  sliderViewcontroller
//
//  Created by ccj on 2017/1/7.
//  Copyright © 2017年 ccj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (CJViewExtension)

/*****************作用:UIView分类frameExtension声明部分**************/
@property (assign, nonatomic) CGFloat cj_x;
@property (assign, nonatomic) CGFloat cj_y;
@property (assign, nonatomic) CGFloat cj_width;
@property (assign, nonatomic) CGFloat cj_height;
@property (assign, nonatomic) CGSize cj_size;
@property (assign, nonatomic) CGPoint cj_origin;
@property (assign, nonatomic) CGFloat cj_centerX;
@property (assign, nonatomic) CGFloat cj_centerY;
@property (assign, nonatomic) CGPoint cj_center;

@property (assign, nonatomic) CGFloat cj_maxX;
@property (assign, nonatomic) CGFloat cj_maxY;




@end

