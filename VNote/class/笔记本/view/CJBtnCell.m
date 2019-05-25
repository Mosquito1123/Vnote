//
//  CJBtnCell.m
//  VNote
//
//  Created by ccj on 2019/5/25.
//  Copyright © 2019 ccj. All rights reserved.
//

#import "CJBtnCell.h"

@implementation CJBtnCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
+(instancetype)xibWithView{
    CJBtnCell *v = [[[NSBundle mainBundle]loadNibNamed:@"CJBtnCell" owner:nil options:nil]lastObject];
    return v;
}

@end
