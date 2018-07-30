//
//  ViewController.h
//  sliderViewcontroller
//
//  Created by ccj on 2017/1/7.
//  Copyright © 2017年 ccj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CJSlideViewController : UIViewController


/**function:滑条的颜色和字体选中后的颜色*/
@property(nonatomic,strong)UIColor *cjLineViewColor;


+(instancetype)cjAddToViewControll:(UIViewController *)superVC withViewAddTo:(UIView *)superView withViewFrame:(CGRect)frame withSubviewControllers:(NSArray *)subviewControllers withSelectBlock:(void (^)(NSUInteger selectIndex, UIViewController *selectVC))didSelectBlock;

@end

