//
//  CJProgressHUD.m
//  尺寸的掌握
//
//  Created by ccj on 2017/1/2.
//  Copyright © 2017年 ccj. All rights reserved.
//
#import "CJGlobal.h"
#import "CJProgressHUD.h"
@interface CJProgressHUD()

@property(nonatomic,strong)UIVisualEffectView *hudBackView;
@property(nonatomic,strong)UIActivityIndicatorView *indicatorView;
@property(nonatomic,strong)UILabel *label;
@property(nonatomic,strong)UIImageView *imageView;
@property(nonatomic,strong)NSArray <UIImage *>*images;
@property(nonatomic,strong)UIImageView *gifImageView;
@end

@implementation CJProgressHUD

+(instancetype)cjShowWithPosition:(CJProgressHUDPosition)position timeOut:(dispatch_time_t)seconds withText:(NSString *)text withImages:(NSArray<UIImage *> *)images
{
    CGRect bounds=[UIScreen mainScreen].bounds;
    //根据位置确定自身的大小
    CGRect frame;
    switch (position)
    {
        case CJProgressHUDPositionNavigationBar:
            frame=CGRectMake(0, 64,bounds.size.width, bounds.size.height-64);
            break;
        case CJProgressHUDPositionTabBar:
            frame=CGRectMake(0, 0, bounds.size.width, bounds.size.height-49);
            break;
        case CJProgressHUDPositionBothExist:
            frame=CGRectMake(0, 64, bounds.size.width, bounds.size.height-49-64);
            break;
        
    }
    CJProgressHUD *hud=[[self alloc]initWithFrame:frame withImages:images];
    hud.backgroundColor=[UIColor clearColor];
    UIWindow *keyWindow=[UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:hud];
    hud.label.text=text;
    __weak typeof(hud) weakHud=hud;
    if (seconds){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(seconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            //来到这说明加载失败
            
            [weakHud.gifImageView removeFromSuperview];
            if(images!=nil)
            {
                [weakHud.hudBackView.contentView addSubview:weakHud.label];
            }
            [weakHud cjShowError:@"超时失败!!!"];
        });
    }
    
    
    return hud;
}





-(void)cjShowSuccess:(NSString *)text
{
    __weak typeof(self) weakSelf=self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf.gifImageView removeFromSuperview];
        [weakSelf.indicatorView removeFromSuperview];
        if(_images!=nil)
        {
            [weakSelf.hudBackView.contentView addSubview:weakSelf.label];
        }
        weakSelf.label.text=text;
        NSString *strBundle=[[NSBundle mainBundle]pathForResource:@"CJProgressHUD.bundle" ofType:nil];
        NSString *imageName=[[NSBundle bundleWithPath:strBundle]pathForResource:@"success.png" ofType:nil inDirectory:@"images"];
        UIImageView *successImageView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:imageName]];
        successImageView.frame=CGRectMake(CGRectGetMidX(self.label.frame)-12.5,CGRectGetMinY(self.label.frame)-43,25, 25);
        successImageView.contentMode=UIViewContentModeScaleAspectFit;
        [weakSelf.hudBackView.contentView addSubview:successImageView];
        
        //
        [weakSelf cjHideProgressHUD];
    });

    
    
}


-(void)cjShowError:(NSString *)text
{
    __weak typeof(self) weakSelf=self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf.indicatorView removeFromSuperview];
        [weakSelf.gifImageView removeFromSuperview];
        if(_images!=nil)
        {
            [weakSelf.hudBackView.contentView addSubview:weakSelf.label];
        }
        weakSelf.label.text=text;
        NSString *strBundle=[[NSBundle mainBundle]pathForResource:@"CJProgressHUD.bundle" ofType:nil];
        NSString *imageName=[[NSBundle bundleWithPath:strBundle]pathForResource:@"error.png" ofType:nil inDirectory:@"images"];
        UIImageView *errorImageView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:imageName]];
        errorImageView.frame=CGRectMake(CGRectGetMidX(self.label.frame)-12.5,CGRectGetMinY(self.label.frame)-43,25, 25);
        errorImageView.contentMode=UIViewContentModeScaleAspectFit;
        [weakSelf.hudBackView.contentView addSubview:errorImageView];
        
        //
        [weakSelf cjHideProgressHUD];
    });

}

-(void)cjShowCustomImage:(NSString *)imageName withText:(NSString *)text
{
    __weak typeof(self) weakSelf=self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf.gifImageView removeFromSuperview];
        [weakSelf.indicatorView removeFromSuperview];
        if(_images!=nil)
        {
            [weakSelf.hudBackView.contentView addSubview:weakSelf.label];
        }
        weakSelf.label.text=text;
        
        UIImageView *customImageView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:imageName]];
        if(customImageView==nil)
        {
            NSLog(@"照片为nil");
            return ;
        }
        customImageView.frame=CGRectMake(CGRectGetMidX(self.label.frame)-12.5,CGRectGetMinY(self.label.frame)-43,25, 25);
        customImageView.contentMode=UIViewContentModeScaleAspectFit;
        [weakSelf.hudBackView.contentView addSubview:customImageView];
        
        //
        [weakSelf cjHideProgressHUD];
    });
    
}





-(void)cjHideProgressHUD
{
    if(self==nil)
    {
        return;
    }
    __weak typeof(self) weakSelf=self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf removeFromSuperview];
    });
}



-(instancetype)initWithFrame:(CGRect)frame withImages:(NSArray <UIImage *>*)images
{
    if(self=[super initWithFrame:frame])
    {
        _images=images;
        if(images==nil)
        {
            //普通的方式
            [self addSubview:self.hudBackView];
            [self.hudBackView.contentView addSubview:self.indicatorView];
            [self.hudBackView.contentView addSubview:self.label];
            [self.indicatorView startAnimating];//开始转悠菊花
        }
        else
        {
            //Gif
            [self addSubview:self.hudBackView];
            [self.hudBackView.contentView addSubview:self.gifImageView];
            self.gifImageView.animationImages=images;//开始转悠图片
            self.gifImageView.animationDuration=images.count*0.1;
            [self.gifImageView startAnimating];
            
        }
        
        
    }
    return self;
    
}

-(UIVisualEffectView *)hudBackView
{
    if(_hudBackView==nil)
    {

        _hudBackView=[[UIVisualEffectView alloc]initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
        _hudBackView.layer.cornerRadius=10.0;
        _hudBackView.layer.masksToBounds=YES;
        CGFloat width=120;
        CGFloat height=120;
        _hudBackView.frame=CGRectMake(self.center.x-width/2, self.cj_height/2-height/2, width, height);
        _hudBackView.contentView.backgroundColor=[UIColor whiteColor];
        _hudBackView.contentView.alpha=0.5;
        
    }
    return _hudBackView;
    
}

-(UIActivityIndicatorView *)indicatorView
{
    if(_indicatorView==nil)
    {
        _indicatorView=[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _indicatorView.frame=CGRectMake(10, 10, self.hudBackView.bounds.size.width-20, self.hudBackView.bounds.size.height-50);
        _indicatorView.color=[UIColor colorWithRed:0.26 green:0.26 blue:0.27 alpha:1.0];
    }
    return _indicatorView;
}


-(UILabel *)label
{
    if(_label==nil)
    {
        _label=[[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.indicatorView.frame), self.hudBackView.bounds.size.width, 20)];
        _label.text=@"加载中...";
        _label.textColor=[UIColor colorWithRed:0.26 green:0.26 blue:0.27 alpha:1.0];
        _label.textAlignment=NSTextAlignmentCenter;
        _label.font=[UIFont boldSystemFontOfSize:[UIFont systemFontSize]];
        
    }
    return _label;
}




-(UIImageView *)imageView
{
    
    if(_imageView==nil)
    {
        NSString *strBundle=[[NSBundle mainBundle]pathForResource:@"CJProgressHUD.bundle" ofType:nil];
        NSString *imageName=[[NSBundle bundleWithPath:strBundle]pathForResource:@"error.png" ofType:nil inDirectory:@"images"];
        _imageView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:imageName]];
        _imageView.frame=CGRectMake(CGRectGetMidX(self.label.frame)-12.5,CGRectGetMinY(self.label.frame)-40,25, 25);
        _imageView.contentMode=UIViewContentModeScaleAspectFit;
    }
    return _imageView;
}

-(UIImageView *)gifImageView
{
    if(_gifImageView==nil)
    {
        _gifImageView=[[UIImageView alloc]initWithFrame:CGRectMake(30, 30, 60, 60)];
        _gifImageView.contentMode=UIViewContentModeCenter;
    }
    return _gifImageView;
}




@end
