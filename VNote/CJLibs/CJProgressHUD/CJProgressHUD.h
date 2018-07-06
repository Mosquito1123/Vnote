//
//  CJProgressHUD.h
//  尺寸的掌握
//
//  Created by ccj on 2017/1/2.
//  Copyright © 2017年 ccj. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,CJProgressHUDPosition)
{
    CJProgressHUDPositionNavigationBar,//有导航栏
    CJProgressHUDPositionTabBar,//有标签栏
    CJProgressHUDPositionBothExist,//两者都存在

};

@interface CJProgressHUD : UIView


-(instancetype)initWithFrame:(CGRect)frame withImages:(NSArray <NSString *>*)images;
/**基本的创建方式*/
+(instancetype)cjShowWithPosition:(CJProgressHUDPosition)position timeOut:(dispatch_time_t) seconds withText:(NSString *)text withImages:(NSArray <UIImage *>*)images;


/**隐藏*/
-(void)cjHideProgressHUD;

/**显示成功*/
-(void)cjShowSuccess:(NSString *)text;

/**显示错误*/
-(void)cjShowError:(NSString *)text;

/**显示自定义图片*/
-(void)cjShowCustomImage:(NSString *)imageName  withText:(NSString *)text;



@end
