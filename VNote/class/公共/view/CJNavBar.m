//
//  CJNavBar.m
//  VNote
//
//  Created by ccj on 2018/6/30.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import "CJNavBar.h"

@implementation CJNavBar

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)layoutSubviews{
    [super layoutSubviews];
    for (UIView  *subView in self.subviews) {
        if ([NSStringFromClass([subView class]) isEqual:@"_UIBarBackground"]){
            for (UIView *view in subView.subviews){
                if ([NSStringFromClass([view class]) isEqual:@"UIImageView"]){
                    
                    view.backgroundColor = BlueBg;
                    
                }
                    
            }
            
        }
    }
}

@end
