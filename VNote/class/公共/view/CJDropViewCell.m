//
//  CJDropViewCell.m
//  VNote
//
//  Created by ccj on 2018/8/4.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import "CJDropViewCell.h"

@implementation CJDropViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    CJCornerRadius(self.avtar) = self.avtar.cj_width / 2;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
