//
//  CJAccountCell.m
//  VNote
//
//  Created by ccj on 2018/8/2.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import "CJAccountCell.h"

@implementation CJAccountCell
+(instancetype)xibAccountCell{
    CJAccountCell *cell = [[[NSBundle mainBundle]loadNibNamed:@"CJAccountCell" owner:nil options:nil]lastObject];
    return cell;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    CJCornerRadius(self.avtar) = self.avtar.cj_width / 2;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
