//
//  CJRenameBookView.h
//  VNote
//
//  Created by ccj on 2019/5/19.
//  Copyright © 2019 ccj. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CJRenameBookView;
NS_ASSUME_NONNULL_BEGIN
typedef void(^Click)(NSString *text,__weak CJRenameBookView *view);
@interface CJRenameBookView : UIView
+(instancetype)showWithTitle:(NSString *)title bookname:(NSString *)name confirm:(Click)click;
-(void)hide;

@end

NS_ASSUME_NONNULL_END
