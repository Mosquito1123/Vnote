//
//  CJTitleView.m
//  VNote
//
//  Created by ccj on 2018/7/28.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import "CJTitleView.h"
@interface CJTitleView()
@property(nonatomic,strong) UILabel *l;
@property(nonatomic,strong) UIImageView *imageView;
@end

@implementation CJTitleView

-(instancetype)initWithTitle:(NSString *)title click:(void (^)(void))block{
    self = [super init];
    if (self){
        UILabel *l = [[UILabel alloc]init];
        self.l = l;
        l.text = title;
        l.textColor = [UIColor whiteColor];
        [l sizeToFit];
        
        l.font = [UIFont systemFontOfSize:17];
        l.cj_x = l.cj_y = 0;
        [self addSubview:l];
        UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"arrow-down"]];
        self.imageView = imageView;
        [imageView sizeToFit];
        
        imageView.cj_x = l.cj_maxX;
        imageView.cj_centerY = l.cj_height / 2;
        [self addSubview:imageView];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithCjGestureRecognizer:^(UIGestureRecognizer *gesture) {
            block();
        }];
        self.userInteractionEnabled = YES;
        [self addGestureRecognizer:tap];
        self.bounds = CGRectMake(0, 0, l.cj_width+imageView.cj_width, l.cj_height);
        self.title = title;
    }
    return self;
}


-(void)setFrame{
    [self.l sizeToFit];
    if (self.l.cj_width > CJScreenWidth/4){
        self.l.cj_width = CJScreenWidth/4;
    }
    self.imageView.cj_x = self.l.cj_maxX;
    
    self.bounds = CGRectMake(0, 0, self.l.cj_width+self.imageView.cj_width, self.l.cj_height);
    self.imageView.cj_centerY = self.cj_height / 2;
}
-(void)layoutSubviews{
    [self setFrame];
}

-(void)setTitle:(NSString *)title{
    _title = title;
    self.l.text = title;
    [self setFrame];
}
@end
