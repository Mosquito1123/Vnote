//
//  CJAssessView.m
//  VNote
//
//  Created by ccj on 2019/3/9.
//  Copyright © 2019 ccj. All rights reserved.
//

#import "CJAssessView.h"

@interface CJAssessView ()
@property (weak, nonatomic) IBOutlet UIButton *assessBtn;
@property (nonatomic,copy) void (^didClick)(void);
@end
@implementation CJAssessView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

+(instancetype)xibAssessViewWithClick:(void (^)(void))click{
    CJAssessView *v = [[[NSBundle mainBundle]loadNibNamed:@"CJAssessView" owner:nil options:nil]lastObject];
    v.assessBtn.contentEdgeInsets = UIEdgeInsetsMake(15, 10, 15, 10);
    CJCornerRadius(v.assessBtn) = 5;
    v.assessBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    v.assessBtn.layer.borderWidth = 1;
    v.didClick = click;
    return v;
}
- (IBAction)assessBtnClick:(id)sender {
    // 跳转到apple store下评价
    if (!self.didClick) return;
    self.didClick();
    
    
}


@end
