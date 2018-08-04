//
//  CJDropView.h
//  dd
//
//  Created by ccj on 2016/12/27.
//  Copyright © 2016年 ccj. All rights reserved.
//

#import <UIKit/UIKit.h>


//动画的样式
typedef NS_ENUM(NSInteger,CJDropViewAnimationType)
{
    CJDropViewAnimationTypeFadeInFadeOut,//淡入淡出
    CJDropViewAnimationTypeFlexible,//伸缩动画  默认
};


//三角形的位置
typedef NS_ENUM(NSInteger,CJTranglePositionType)
{
    CJTranglePositionLeft, //在左
    CJTranglePositionRight,//在右   默认
    CJTranglePositionMiddle,//在中间
};


@interface CJDropView : UIView

NS_ASSUME_NONNULL_BEGIN
/**function:背景色*/
@property(nonatomic,strong)UIColor *cjDropViewBgColor;

/**function:三角形上Y点坐标 */
@property(nonatomic,assign)CGFloat cjTrangleY;

/**function:三角形左或者是右边距*/
@property(nonatomic,assign)CGFloat cjTrangleMargin;


/**function:三角形的大小 */
@property(nonatomic,assign)CGSize cjTrangleSize;

/**function:下拉视图左或者是右边距 */
@property(nonatomic,assign)CGFloat cjDropViewMargin;

/**function:下拉视图的宽度 */
@property(nonatomic,assign)CGFloat cjDropViewWidth;

/**function:下拉视图里面cell的高度 */
@property(nonatomic,assign)CGFloat cjDropViewCellHeight;


/**function:下拉视图显示的动画*/
@property(nonatomic,assign)CJDropViewAnimationType cjAnimationType;

/**function:三角形的位置 */
@property(nonatomic,assign)CJTranglePositionType cjTranglePosition;

/**function:下拉视图里面的模型数组*/
@property(nonatomic,strong,nonnull)NSArray *cjDropViewCellModelArray;

//外部接口点击cell时拿到的数据
@property(nonatomic,copy)void (^ _Nonnull cjDidselectRowAtIndex)(NSInteger index);


//当外部重新设置了参数默认值，我们一定需要重新调用该方法
-(void)cjResetDropView;
//显示下拉视图
-(void)cjShowDropView;

//隐藏下拉视图
-(void)cjHideDropView;


+(instancetype)cjShowDropVieWAnimationWithOption:(CJDropViewAnimationType) cjAnimationType tranglePosition:(CJTranglePositionType) cjTranglePosition cellModelArray:(NSArray  * _Nonnull )modelArray detailAttributes:(NSDictionary *__nullable)attributes cjDidSelectRowAtIndex:(void (^ _Nonnull)(NSInteger index))didSelectRowAtIndex;

NS_ASSUME_NONNULL_END
@end
