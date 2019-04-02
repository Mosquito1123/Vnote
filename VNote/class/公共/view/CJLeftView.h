//
//  CJLeftView.h
//  VNote
//
//  Created by ccj on 2018/8/1.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CJLeftView : UIView
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *userInfoBtnHeightMargin;
@property (weak, nonatomic) IBOutlet UILabel *emailL;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
+(instancetype)xibLeftView;
@property (weak, nonatomic) IBOutlet UIButton *addAccountBtn;
@property (weak, nonatomic) IBOutlet UIButton *userInfoBtn;
@property (weak, nonatomic) IBOutlet UITableView *accountTableView;


-(void)hideUserInfoBtn:(BOOL)b;
@end
