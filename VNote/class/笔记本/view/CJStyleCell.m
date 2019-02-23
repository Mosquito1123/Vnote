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
    self.alpha = 0.7;
    CJCornerRadius(self.codeStyleImgView) = 5.0;

}

@end
