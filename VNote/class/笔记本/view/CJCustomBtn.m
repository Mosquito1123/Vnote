//
//  CJCustomBtn.m
//  VNote
//
//  Created by ccj on 2018/7/21.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import "CJCustomBtn.h"

@implementation CJCustomBtn

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
+(instancetype)xibCustomBtnWithTapClick:(void(^)(void))block{
    CJCustomBtn *view = [[[NSBundle mainBundle]loadNibNamed:@"CJCustomBtn" owner:nil options:nil] lastObject];
    view.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc]initWithCjGestureRecognizer:^(UIGestureRecognizer *gesture) {
        block();
    }];
    view.backgroundColor = [UIColor clearColor];
    [view addGestureRecognizer:tapGes];
    return view;
}


@end
