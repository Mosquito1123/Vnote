//
//  CJGlobalDefine.h
//  尺寸的掌握
//
//  Created by ccj on 2016/12/9.
//  Copyright © 2016年 ccj. All rights reserved.
//


#import<UIKit/UIKit.h>

/********************************const部分**********************************/

#pragma -mark  获取statusBar、navigationBar、tabBar的高度
UIKIT_EXTERN const CGFloat CJStatusBarHeight;
UIKIT_EXTERN const CGFloat CJNavigationBarHeight;
UIKIT_EXTERN const CGFloat CJTabBarHeight;




/**********************作用:自动生成模型属性代码************************
 一、用法:[NSObject cjCreatePropertyWithDict:dict],然后复制控制台上输出的语句.
 
 二、注意:中文还没解决
 *******************************************************************/
@interface NSObject (autoCreateProperty)
+(void)cjCreatePropertyWithDict:(NSDictionary *)dict;
@end






/**********************作用:自动转模型声明部分**************************
 一、适用范围:
 1>字典里面可以是字典(这个字典要转换成模型),可以是数组,基本对象类型
 2>字典里面字典(模型)里面还有字典(这个字典要转换成模型)
 3>字典里面可以是数组(这个数组是一个模型数组,只能是一种模型,并且数组里面只能是同种键的字典)
 
 二、用法:
 1>如果是上面1和2的情况，[modelClass cjModelWithDict:dict],此处的modelClass是最外层的字典
 2>如果是上面3的情况,需要在对应的model下面实现cjModelContainModelInArray,这个协议方法
 *******************************************************************/
@protocol cjModelDelegate <NSObject>
@optional
+(NSDictionary *)cjModelContainModelInArray;
@end

@interface NSObject (dictToModel)<cjModelDelegate>
+(instancetype)cjModelWithDict:(NSDictionary *)dict;
@end





/**************作用:UIView分类didAddSubviewsExtension声明部分**********
 一、用法:
 想要监听子view添加的的事件就需要实现该block的动作,如
 self.veiw=^(){
    NSLog(@"当view有子view添加就会响应该方法");
 }
 *******************************************************************/
@interface UIView (didAddSubviewsExtension)
/**function:监听UIView中addSubviews事件*/
@property(nonatomic,copy)void (^cjDidAddSubviews)(void);
@end







/**************作用:CJProgressView导航栏下面的进度条********************
 一、用法步骤:
 1>创建progressView对象
 2>设置frame
 3>设置进度条的颜色
 4>进度开始[progressView cjStartLoading]
 5>进度结束[progressView cjEndLoading]
 
 二、注意:
 1>我们一般情况在有导航栏的时候使用比较好
 2>设置frame是CGRectMake(0, 64, 0, 3),注意高度
 *******************************************************************/
@interface CJProgressView : UIView
//进度条内部的前景色
@property(nonatomic,strong)UIView * foregroundView;
/**function:进度条的颜色*/
@property(nonatomic,strong)UIColor *cjProgressViewColor;
//进度条开始
-(void)cjStartLoading;
//结束进度条
-(void)cjEndLoading;
@end








/*******************作用:CALayer分类声明部分***************************
 用法:为宏CJCornerRadius(view)提供
 *******************************************************************/
@interface CALayer(CornerRadius)
-(instancetype)CJSetLayerMasksToBoundsToYES;
@end






/******************作用:监听手势的响应UIGestureRecognizer分类***********
 用法:
 1>UITapGestureRecognizer *tapGes=[UITapGestureRecognizer cjGestureRecognizer:^(UIGestureRecognizer *gesture) {
    NSLog(@"我被点击了");
 }];
 
 2>[[UITapGestureRecognizer alloc]initWithCjGestureRecognizer:^(UIGestureRecognizer *) {
 NSLog(@"我被点击了");
 }];
 *******************************************************************/
@interface UIGestureRecognizer (gesBlock)
@property(nonatomic,copy)void (^block)(UIGestureRecognizer *gesture);
-(instancetype)initWithCjGestureRecognizer:(void (^)(UIGestureRecognizer *gesture))gesBlock;
+(instancetype)cjGestureRecognizer:(void (^)(UIGestureRecognizer *gesture))gesBlock;
@end







/*****************************define部分************************************/

#ifndef CJGlobal_h
#define CJGlobal_h


#pragma -mark  获取当前屏幕的尺寸
#define CJScreenWidth [UIScreen mainScreen].bounds.size.width
#define CJScreenHeight [UIScreen mainScreen].bounds.size.height


#pragma -mark  获取当前的AppDeletegate单例
#define CJAppDelegate  (AppDelegate *)[UIApplication sharedApplication].delegate;


#pragma -mark 获取沙盒路径
#define CJDocumentPath  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0]
#define CJLibraryPath  [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES)firstObject]
#define CJCachePath [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)firstObject]
#define CJTempPath NSTemporaryDirectory()

//利用偏好设置快速存储数据
#define CJSetUserDefaults(keyArray,valueArray)\
do{\
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];\
    for(int i=0;i<keyArray.count;i++)\
    {\
        [userDefaults setObject:valueArray[i] forKey:keyArray[i]];\
    }\
    [userDefaults synchronize];\
}while(0)

//利用偏好设置快速读取数据
#define CJGetUserDefaults(keyArray)\
({\
    NSMutableArray *valueArray=[NSMutableArray array];\
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];\
    for(NSString *key in keyArray)\
    {\
        [valueArray addObject:[userDefaults objectForKey:key]];\
    }\
    valueArray;\
})


#pragma -mark 定义weakSelf和strongSelf变量
#define CJWeak(object) __weak __typeof(&*object) weak##object = object;
#define CJStrong(object) __strong __typeof(&*object) strong##object = object;


#pragma -mark 生成颜色
//随机颜色
#define CJRandomColor [UIColor colorWithRed:arc4random_uniform(256)/255.0 green:arc4random_uniform(256)/255.0 blue:arc4random_uniform(256)/255.0 alpha:1.0];
//设置RGBA颜色
#define CJRGBAColor(r, g, b,a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:a];
//设置RGB颜色
#define CJRGBColor(r, g, b)  CJRGBAColor(r, g, b,1.0)

// 十六进制转UIColor
//使用sip工具取颜色
#define CJColorFromHex(hexValue) [UIColor \
colorWithRed:((float)((hexValue & 0xFF0000) >> 16))/255.0 \
green:((float)((hexValue & 0xFF00) >> 8))/255.0 \
blue:((float)(hexValue & 0xFF))/255.0 alpha:1.0]


#pragma -mark 自定义NSLog
#if DEBUG
#define CJLog(formater,...)  NSLog(formater,##__VA_ARGS__)

#define CJLogFrame(view)  do{\
CGRect frame=view.frame;\
NSLog(@"{x=%f,y=%f,w=%f,h=%f}",frame.origin.x,frame.origin.y,frame.size.width,frame.size.height);\
}while(0)

#else

#define CJLog(formater,...)
#define CJLogFrame(view)
#endif




#pragma -mark   设置圆角
#define CJCornerRadius(view)\
[view.layer CJSetLayerMasksToBoundsToYES].cornerRadius


#pragma -mark 获取图片名称
#define CJGetImage(formater,...)   [UIImage imageNamed:[NSString stringWithFormat:formater,##__VA_ARGS__]]



#endif /* CJGlobalDefine_h */







