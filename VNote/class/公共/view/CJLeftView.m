//
//  CJLeftView.m
//  VNote
//
//  Created by ccj on 2018/8/1.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import "CJLeftView.h"

@implementation CJLeftView

+(instancetype)xibLeftView{
    CJLeftView *view = [[[NSBundle mainBundle]loadNibNamed:@"CJLeftView" owner:nil options:nil] lastObject];
    CJUser *user = [CJUser sharedUser];
    view.emailL.text = user.email;
    view.userInfoBtn.showsTouchWhenHighlighted = YES;
    view.addAccountBtn.showsTouchWhenHighlighted = YES;
    [view hideUserInfoBtn:[CJTool getClosePenFriendFunc]];
    return view;
}
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    if (!view) {
        CGPoint newPoint = [self.tableView convertPoint:point fromView:self];
        if (CGRectContainsPoint(self.tableView.bounds, newPoint)) {
            view = self.tableView;
        }else if (CGRectContainsPoint(self.addAccountBtn.bounds, newPoint)){
            view = self.addAccountBtn;
        }else if (CGRectContainsPoint(self.userInfoBtn.bounds, newPoint)){
            view = self.userInfoBtn;
        }
        
    }
    return view;
}

-(void)hideUserInfoBtn:(BOOL)b{
    if (b){
      self.userInfoBtnHeightMargin.constant = 0;
    }else{
        self.userInfoBtnHeightMargin.constant = 40;
    }
    [UIView animateWithDuration:0.3 animations:^{
        [self layoutIfNeeded];
    }];
    
    
}

@end
