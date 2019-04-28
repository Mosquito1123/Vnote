//
//  CJStyleCell.h
//  VNote
//
//  Created by ccj on 2018/8/22.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CJStyleCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *codeStyleImgView;
-(void)showCheckmark:(BOOL)t;

@end
