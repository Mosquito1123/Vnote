//
//  CJStyleCell.m
//  VNote
//
//  Created by ccj on 2018/8/22.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import "CJStyleCell.h"
@interface CJStyleCell ()
@property(nonatomic,strong) UIImageView *checkImageView;
@end

#define selectColor CJColorFromHex(0x1296db)
@implementation CJStyleCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.alpha = 0.7;
    self.checkImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"checkmark"]];
    CJCornerRadius(self.checkImageView) = 6.0f;
    [self.codeStyleImgView addSubview:self.checkImageView];
    CJWeak(_codeStyleImgView)
    self.checkImageView.backgroundColor = selectColor;
    [self.checkImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(weak_codeStyleImgView).mas_offset(-3);
        make.bottom.mas_equalTo(weak_codeStyleImgView).mas_offset(-3);
        make.width.height.mas_equalTo(12.0f);
    }];
    CJCornerRadius(self.codeStyleImgView) = 5.0;
}

-(void)showCheckmark:(BOOL)t
{
    self.checkImageView.hidden = !t;
}

@end
