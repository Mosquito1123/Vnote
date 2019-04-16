//
//  CJRightDropMenuVC.h
//  VNote
//
//  Created by ccj on 2019/4/16.
//  Copyright © 2019 ccj. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CJRightDropMenuVC : UIViewController
@property(nonatomic,copy) void (^didSelectIndex)(NSInteger index);
@end

NS_ASSUME_NONNULL_END
