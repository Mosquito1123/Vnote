//
//  CJBookCell.m
//  VNote
//
//  Created by ccj on 2018/7/21.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import "CJBookCell.h"

@implementation CJBookCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self){
        UIView *view = [[UIView alloc]init];
        view.cj_width = CJScreenWidth * 0.9;
        view.cj_height =  44;
        view.cj_centerX = CJScreenWidth * 0.5;
        view.backgroundColor = [UIColor whiteColor];
        CJCornerRadius(view) = 5;
        [self addSubview:view];
        
        UILabel *l = [[UILabel alloc]init];
        [view addSubview:l];
        l.cj_size = CGSizeMake(view.cj_width * 0.5,20);
        l.cj_y = view.cj_height * 0.5 -l.cj_height * 0.5;
        l.cj_x = 10;
        self.tLabel = l;
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

@end
