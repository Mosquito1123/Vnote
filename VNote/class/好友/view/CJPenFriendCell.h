//
//  CJPenFriendCell.h
//  VNote
//
//  Created by ccj on 2018/6/30.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CJPenFriendCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *avtar;
@property (weak, nonatomic) IBOutlet UILabel *nicknameL;
@property (weak, nonatomic) IBOutlet UILabel *intro;
+(instancetype)xibPenFriendCell;
@end
