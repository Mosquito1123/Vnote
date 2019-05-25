//
//  CJBtnCell.h
//  VNote
//
//  Created by ccj on 2019/5/25.
//  Copyright © 2019 ccj. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CJBtnCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *img;
@property (weak, nonatomic) IBOutlet UILabel *label;
+(instancetype)xibWithView;
@end

NS_ASSUME_NONNULL_END
