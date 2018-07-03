//
//  CJSearchBar.m
//  VNote
//
//  Created by ccj on 2018/7/2.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import "CJSearchBar.h"

@implementation CJSearchBar

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(void)layoutSubviews{
    [super layoutSubviews];
    
    UIView *view = self.subviews[0];
    for (UIView *v in view.subviews) {
        if ([NSStringFromClass([v class]) isEqualToString:@"UISearchBarTextField"]){
            v.cj_y += 10;
        }else if ([NSStringFromClass([v class]) isEqualToString:@"UINavigationButton"]){
            v.cj_y += 10;
        }
            
    }
    NSLog(@"%@",self.subviews);
}
@end
