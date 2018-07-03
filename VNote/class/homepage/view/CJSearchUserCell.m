//
//  CJSearchUserCell.m
//  VNote
//
//  Created by ccj on 2018/7/1.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import "CJSearchUserCell.h"

@implementation CJSearchUserCell

+(instancetype)xibSearchUserCell{
    CJSearchUserCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"CJSearchUserCell" owner:nil options:nil] lastObject];
    
    return cell;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    CJCornerRadius(self.focusBtn) = 5;
    CJCornerRadius(self.avtar) = self.avtar.cj_height/2;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
