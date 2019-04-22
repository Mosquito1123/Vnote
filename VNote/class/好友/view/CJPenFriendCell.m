//
//  CJPenFriendCell.m
//  VNote
//
//  Created by ccj on 2018/6/30.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import "CJPenFriendCell.h"
@interface CJPenFriendCell()
@property (weak, nonatomic) IBOutlet UIImageView *avtar;
@property (weak, nonatomic) IBOutlet UILabel *nicknameL;
@property (weak, nonatomic) IBOutlet UILabel *intro;
@end
@implementation CJPenFriendCell
+(instancetype)xibPenFriendCell{
    CJPenFriendCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"CJPenFriendCell" owner:nil options:nil] lastObject];
    
    CJCornerRadius(cell.avtar) = cell.avtar.cj_height/2;
    cell.intro.textColor = [UIColor grayColor];
    return cell;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    //在registerNib调用
    CJCornerRadius(self.avtar) = self.avtar.cj_height/2;
    self.intro.textColor = [UIColor grayColor];
}

-(void)setUI:(CJPenFriend *)penf{
    [self.avtar yy_setImageWithURL:IMG_URL(penf.avtar_url) placeholder:[UIImage imageNamed:@"avtar"]];
    self.nicknameL.text = penf.nickname;
    self.intro.text = penf.introduction;
}
@end
