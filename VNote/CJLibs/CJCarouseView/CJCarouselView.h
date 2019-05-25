//
//  CJCarouselView.h
//  sliderViewcontroller
//
//  Created by ccj on 2017/1/20.
//  Copyright © 2017年 ccj. All rights reserved.
//

#import <UIKit/UIKit.h>


//scrollView移动的方向
typedef NS_ENUM(NSUInteger,CJCarouselViewMoveDirection)
{
    CJCarouselViewMoveDirectionNone,//不移动
    CJCarouselViewMoveDirectionLeft,//左移
    CJCarouselViewMoveDirectionRight,//右移
};

typedef NS_ENUM(NSUInteger,CJPageControlPosition)
{
    CJPageControlPositionLeft,
    CJPageControlPositionCenter,
    CJPageControlPositionRight,
};

@interface CJCarouselView : UIView

/**function:显示的图片*/
@property(nonatomic,strong)NSMutableArray *cjImages;

/**function:pageControl显示的位置 */
@property(nonatomic,assign)CJPageControlPosition cjPageControlPosition;

/**牛叉的方法*/
+(instancetype)cjCarouseViewAddToView:(UIView *)superView withFrame:(CGRect)frame withImagess:(NSMutableArray *)images pageControlPosition:(CJPageControlPosition)pageControlPosition didClickBlock:(void (^)(NSInteger index))block;
+(instancetype)cjCarouseViewWithFrame:(CGRect)frame withImagess:(NSMutableArray *)images pageControlPosition:(CJPageControlPosition)pageControlPosition didClickBlock:(void (^)(NSInteger index))block;
@end
