//
//  CJStyleCell.m
//  VNote
//
//  Created by ccj on 2018/8/22.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import "CJStyleCell.h"

@implementation CJStyleCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    CJCornerRadius(self) = 4.0;
    self.backgroundColor = BlueBg;
    self.alpha = 0.7;
    self.cssL.textColor = [UIColor whiteColor];
}

@end
