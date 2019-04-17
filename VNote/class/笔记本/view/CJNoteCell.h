//
//  CJNoteCell.h
//  VNote
//
//  Created by ccj on 2019/3/19.
//  Copyright © 2019 ccj. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CJNoteCell : UITableViewCell

+(CGFloat)height;
-(void)setUI:(CJNote *)n;

+(instancetype)xibWithNoteCell;

@end

NS_ASSUME_NONNULL_END
