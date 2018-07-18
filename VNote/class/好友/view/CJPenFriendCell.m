//
//  CJPenFriendCell.m
//  VNote
//
//  Created by ccj on 2018/6/30.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import "CJPenFriendCell.h"

@implementation CJPenFriendCell
+(instancetype)xibPenFriendCell{
    
    
    CJPenFriendCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"CJPenFriendCell" owner:nil options:nil] lastObject];
    CJCornerRadius(cell.avtar) = cell.avtar.cj_height/2;
    return cell;
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
