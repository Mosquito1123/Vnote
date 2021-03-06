//
//  CJPenFHeadView.h
//  VNote
//
//  Created by ccj on 2018/7/22.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CJPenFHeadView : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nicknameL;
@property (weak, nonatomic) IBOutlet UIButton *focusBtn;
@property (weak, nonatomic) IBOutlet UILabel *introL;
@property (weak, nonatomic) IBOutlet UIButton *focusedCountBtn;
@property (weak, nonatomic) IBOutlet UIButton *followsBtn;
@property (weak, nonatomic) IBOutlet UIImageView *avtar;
@property (weak, nonatomic) IBOutlet UIImageView *sexImg;
+(instancetype)xibPenFHeadView;
@end
