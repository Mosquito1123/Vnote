//
//  CJRightDropMenuVC.h
//  VNote
//
//  Created by ccj on 2019/4/16.
//  Copyright © 2019 ccj. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^DidSelectIndex)(NSInteger index);

@interface CJRightDropMenuVC : UIViewController
+(instancetype)dropMenuWithImages:(NSArray<NSString *> *)images titles:(NSArray <NSString *>*)titles itemHeight:(CGFloat)height width:(CGFloat)width didclick:(DidSelectIndex)click;
@end

NS_ASSUME_NONNULL_END
