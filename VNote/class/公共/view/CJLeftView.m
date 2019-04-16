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
    [view accountChange];
    [[NSNotificationCenter defaultCenter]addObserver:view selector:@selector(accountChange) name:LOGIN_ACCOUT_NOTI object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:view selector:@selector(changeClosePenFriendsFunc) name:CHANGE_CLOSE_PEN_FRIENDS_FUNC_NOTI object:nil];
    return view;
}
-(void)accountChange{
    CJUser *user = [CJUser sharedUser];
    self.emailL.text = user.email;
    self.userInfoBtn.showsTouchWhenHighlighted = YES;
    self.addAccountBtn.showsTouchWhenHighlighted = YES;
    [self hideUserInfoBtn:[CJTool getClosePenFriendFunc]];
}

-(void)changeClosePenFriendsFunc{
    
    [self hideUserInfoBtn:[CJTool getClosePenFriendFunc]];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
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
    b = YES;
    
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
