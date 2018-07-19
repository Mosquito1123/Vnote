//
//  CJTabBar.m
//  百思不得姐
//
//  Created by ccj on 2017/5/3.
//  Copyright © 2017年 ccj. All rights reserved.
//

#import "CJTabBar.h"

@interface  CJTabBar()


@end


@implementation CJTabBar



#pragma mark -懒加载
-(UIButton *)publishBtn
{
    if(_publishBtn==nil)
    {
        UIButton *btn=[[UIButton alloc]init];
        _publishBtn=btn;
    
        [_publishBtn setImage:[UIImage imageNamed:@"加蓝"] forState:UIControlStateNormal];
//        [_publishBtn setImage:[UIImage imageNamed:@"tabBar_publish_click_icon"] forState:UIControlStateHighlighted];

        
        [self addSubview:_publishBtn];
        
    }
    return _publishBtn;
}


#pragma mark -初始化

-(void)layoutSubviews
{
    //父类先进行布局，子类再覆盖父类的布局样式
    [super layoutSubviews];
    //遍历tabar下面的子控件
    CGFloat btnW=self.frame.size.width/5;
    CGFloat btnH=self.frame.size.height;
    CGFloat btnY=0;
    
    int index=0;
    for(UIView *subview in self.subviews)
    {
        if([subview isKindOfClass:NSClassFromString(@"UITabBarButton")])
        {
            CGFloat btnX=index*btnW;
            if(index>=2)
            {
                btnX+=btnW;
            }
            //设置item的frame
            subview.frame=CGRectMake(btnX, btnY, btnW, btnH);
            index++;
            
        }
    }
    self.publishBtn.frame=CGRectMake(self.frame.size.width/5*2, btnY, self.frame.size.width/5, self.frame.size.height);
    
}



@end
