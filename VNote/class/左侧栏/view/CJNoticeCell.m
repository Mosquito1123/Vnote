//
//  CJNoticeCell.m
//  VNote
//
//  Created by ccj on 2019/3/13.
//  Copyright © 2019 ccj. All rights reserved.
//

#import "CJNoticeCell.h"

@implementation CJNoticeCell


+(instancetype)xibWithNoticeCell{
    CJNoticeCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"CJNoticeCell" owner:nil options:nil]lastObject];
    return cell;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

@end
