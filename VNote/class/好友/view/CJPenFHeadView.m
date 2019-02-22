//
//  CJPenFHeadView.m
//  VNote
//
//  Created by ccj on 2018/7/22.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import "CJPenFHeadView.h"
@interface CJPenFHeadView()

@end
@implementation CJPenFHeadView

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+(instancetype)xibPenFHeadView{
    CJPenFHeadView *view = [[[NSBundle mainBundle] loadNibNamed:@"CJPenFHeadView" owner:nil options:nil]lastObject];
    view.focusBtn.layer.borderWidth = 1;
    view.focusBtn.layer.borderColor = BlueBg.CGColor;
    CJCornerRadius(view.focusBtn) = 5;
    CJCornerRadius(view.avtar) = view.avtar.cj_width / 2;
    
    return view;
}

@end
