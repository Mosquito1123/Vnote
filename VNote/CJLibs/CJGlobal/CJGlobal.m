//
//  CJGlobal.m
//  尺寸的掌握
//
//  Created by ccj on 2016/12/13.
//  Copyright © 2016年 ccj. All rights reserved.
//

#import <objc/runtime.h>
#import "CJGlobal.h"

const CGFloat CJStatusBarHeight = 20;
const CGFloat CJNavigationBarHeight = 44;
const CGFloat CJTabBarHeight = 49;





/***********************自动生成模型代码*****************************/
@implementation NSObject (autoCreateProperty)
+(void)cjCreatePropertyWithDict:(NSDictionary *)dict
{
    NSMutableString *strM=[NSMutableString string];
    [dict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSString *code;
        if([obj isKindOfClass:NSClassFromString(@"__NSCFBoolean")])
        {
            code=[NSMutableString stringWithFormat:@"@property(nonatomic,assign)BOOL %@;",key];
        }
        else if ([obj isKindOfClass:NSClassFromString(@"__NSCFNumber")])
        {
            code=[NSMutableString stringWithFormat:@"@property(nonatomic,strong)NSNumber *%@;",key];
        }
        else if ([obj isKindOfClass:NSClassFromString(@"__NSCFArray")])
        {
            code=[NSMutableString stringWithFormat:@"@property(nonatomic,strong)NSArray *%@;",key];
            
        }
        else if ([obj isKindOfClass:NSClassFromString(@"__NSTaggedDate")])
        {
            code=[NSMutableString stringWithFormat:@"@property(nonatomic,strong)NSDate *%@;",key];
        }
        else if([obj isKindOfClass:NSClassFromString(@"NSTaggedPointerString")])
        {
            code=[NSMutableString stringWithFormat:@"@property(nonatomic,strong)NSString *%@;",key];
        }
        else if ([obj isKindOfClass:NSClassFromString(@"__NSCFDictionary")])
        {
            code=[NSMutableString stringWithFormat:@"@property(nonatomic,strong)NSDictionary *%@;",key];
        }
        
        [strM appendFormat:@"\n%@\n",code];
        
    }];
    NSLog(@"\n%@\n",strM);
    
}
@end







/***********************字典转模型实现部分********************************/
@implementation NSObject (dictToModel)

+(instancetype)cjModelWithDict:(NSDictionary *)dict
{
    
    id obj=[[self alloc]init];
    
    //使用runtime得到一个类里面的所有属性
    unsigned int count;
    //获取所有的成员属性列表，存在ivarList所指向的Ivar数组中
    Ivar *ivarList=class_copyIvarList(self, &count);
    
    int i;
    for (i=0; i<count; i++){
        
        //通过ivar变量获取ivar变量属性的名称
        const char *ivarName=ivar_getName(ivarList[i]);
        //通过ivar变量获取ivar变量属性的类型
        const char *ivarType=ivar_getTypeEncoding(ivarList[i]);
        NSString *propertyName=[NSString stringWithUTF8String:ivarName];
        NSString *propertyType=[NSString stringWithUTF8String:ivarType];
        /*
         注意：属性名称取出来是带下划线的_name;所以需要去掉下划线
         */
        NSString *key=[propertyName substringFromIndex:1];
        
        id value=dict[key];
        /*
         注意：属性的类型是这样的\"NSDictionary\"
         */
        //下面是:字典中有字典（而这个字典是模型）
        if([value isKindOfClass:[NSDictionary class]] && ![propertyType isEqualToString:@"\"NSDictionary\""])
        {
            //说明模型里面又有其他模型
            //拿到的模型是@\"modeltype\"
            NSString *modelType=[propertyType substringWithRange:NSMakeRange(2, propertyType.length-3)];
            Class modelClass=NSClassFromString(modelType);
            if(modelClass)
            {
                value=[modelClass cjModelWithDict:value];
            }
        }
        //下面是:数组中有字典（而这个字典是模型）
        if([value isKindOfClass:[NSArray class]])
        {
            //注意：这个数组里面只能都是字典，不能有其他的内容，而且每个字典的内容要保持一致
            //判断该类有没有实现协议里面的方法,为什么要写在协议里面，因为只有协议里面的方法可以有@optional和@required
            if([self respondsToSelector:@selector(cjModelContainModelInArray)])
            {
                //通过字典返回出来的信息，拿到数组里面的模型类型{@"key":@"modelType"},key是该数组的名称
                id idSelf=self;
                NSString *modelType=[idSelf cjModelContainModelInArray][key];
                Class modelClass=NSClassFromString(modelType);
                if(modelClass)
                {
                    
                    NSMutableArray *arrM=[NSMutableArray array];
                    for (NSDictionary *dict in value)
                    {
                        id model=[modelClass cjModelWithDict:dict];
                        [arrM addObject:model];
                    }
                    
                    value=arrM;
                    
                }
                
            }
            
        }
        if(value)
        {
            [obj setValue:value forKey:key];
        }
    }
    return obj;
}
@end





/*****************作用:UIView分类frameExtension声明部分****************
 一、用法:
 view.x----view.y-----view.width-----view.height----view.size---view.origin
 view.centerX---view.centerY
 *******************************************************************/
@interface UIView (frameExtension)
@property (assign, nonatomic) CGFloat x;
@property (assign, nonatomic) CGFloat y;
@property (assign, nonatomic) CGFloat width;
@property (assign, nonatomic) CGFloat height;
@property (assign, nonatomic) CGSize size;
@property (assign, nonatomic) CGPoint origin;
@property (assign, nonatomic) CGFloat centerX;
@property (assign, nonatomic) CGFloat centerY;
@end





/**********************UIView分类frameExtension实现部分**********************/
@implementation UIView (frameExtension)
- (void)setX:(CGFloat)x
{
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (CGFloat)x
{
    return self.frame.origin.x;
}

- (void)setY:(CGFloat)y
{
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (CGFloat)y
{
    return self.frame.origin.y;
}

- (void)setWidth:(CGFloat)width
{
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (CGFloat)width
{
    return self.frame.size.width;
}

- (void)setHeight:(CGFloat)height
{
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (CGFloat)height
{
    return self.frame.size.height;
}

- (void)setSize:(CGSize)size
{
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

- (CGSize)size
{
    return self.frame.size;
}

- (void)setOrigin:(CGPoint)origin
{
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}

- (CGPoint)origin
{
    return self.frame.origin;
}

-(void)setCenterX:(CGFloat)centerX
{
    CGPoint center=self.center;
    center.x=centerX;
    self.center=center;
}

-(CGFloat)centerX
{
    return self.center.x;
}


-(void)setCenterY:(CGFloat)centerY
{
    CGPoint center=self.center;
    center.y=centerY;
    self.center=center;
}

-(CGFloat)centerY
{
    return  self.center.y;
}

@end







/***************UIView分类didAddSubviewsExtension实现部分******************/
@implementation UIView (didAddSubviewsExtension)

//将代码块设置为属性成员
static char *didAddSubviewsKey="didAddSubviewsKey";

-(void)setCjDidAddSubviews:(void (^)(void))cjDidAddSubviews
{

    objc_setAssociatedObject(self, didAddSubviewsKey, cjDidAddSubviews, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

-(void (^)(void))cjDidAddSubviews
{
    return objc_getAssociatedObject(self, didAddSubviewsKey);
}

//交换addSubviews和cjDidAddSubviews的实现
+(void)load
{
    static dispatch_once_t one_token;
    dispatch_once(&one_token, ^{
       
        Method addSubviewMethod=class_getInstanceMethod(self,@selector(addSubview:));
        Method cjAddSubviewMethod=class_getInstanceMethod(self, @selector(cjAddSubview:));
        method_exchangeImplementations(addSubviewMethod, cjAddSubviewMethod);
        
    });
}


-(void)cjAddSubview:(UIView *)view
{

    [self cjAddSubview:view];
    if(self.cjDidAddSubviews)
    {
        self.cjDidAddSubviews();
    }

}

@end








/********************CJProgressView导航栏下面的进度条*************************/

@implementation CJProgressView

-(instancetype)initWithFrame:(CGRect)frame
{
    if(self=[super initWithFrame:frame])
    {
        self.backgroundColor=[UIColor clearColor];
        self.foregroundView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 0, 3)];
        self.foregroundView.backgroundColor=[UIColor yellowColor];
        [self addSubview:self.foregroundView];
        
    }
    return self;
}
-(void)setCjProgressViewColor:(UIColor *)cjProgressViewColor
{
    self.foregroundView.backgroundColor=cjProgressViewColor;
}

-(UIColor *)cjProgressViewColor
{
    return self.foregroundView.backgroundColor;
}
//开始进度条
-(void)cjStartLoading
{
    
    //防止被其他的view覆盖掉
    __weak typeof(self) weakSelf=self;
    __weak typeof(self.superview) weakSuperview=self.superview;
    self.superview.cjDidAddSubviews=^(){
        [weakSuperview bringSubviewToFront:weakSelf];
    };
    
    self.foregroundView.width=0;
    self.hidden=NO;

    [UIView animateWithDuration:10 delay:0 usingSpringWithDamping:1.0f initialSpringVelocity:1.0f options:UIViewAnimationOptionLayoutSubviews animations:^{
        weakSelf.foregroundView.width=0.8*CJScreenWidth;
    } completion:nil];
    
}

//结束进度条
-(void)cjEndLoading
{
    [UIView animateWithDuration:0.5 animations:^{
        self.foregroundView.width=CJScreenWidth;
    }completion:^(BOOL finished) {
        self.hidden=YES;
    }];
    
}
@end







/*********************CALayer分类实现部分***************************/
@implementation CALayer (CornerRadius)

-(instancetype)CJSetLayerMasksToBoundsToYES
{
    
    self.masksToBounds=YES;
    return self;
}
@end








/**********************监听手势的响应UIGestureRecognizer实现部分****************/

@implementation UIGestureRecognizer (gesBlock)

static const char *gesBlockKey="gesBlockKey";
+(instancetype)cjGestureRecognizer:(void (^)(UIGestureRecognizer *))gesBlock
{
    return [[self alloc]initWithCjGestureRecognizer:gesBlock];
}
-(instancetype)initWithCjGestureRecognizer:(void (^)(UIGestureRecognizer *))gesBlock
{
    
    self=[self init];
    self.block=gesBlock;
    [self addTarget:self action:@selector(gestureFunc:)];
    return self;
}

-(void)gestureFunc:(UIGestureRecognizer *)gesture
{
    
    self.block(gesture);
    
}

-(void)setBlock:(void (^)(UIGestureRecognizer *))block
{
    objc_setAssociatedObject(self, gesBlockKey, block, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
-(void (^)(UIGestureRecognizer *))block
{

    return objc_getAssociatedObject(self, gesBlockKey);
}
@end






