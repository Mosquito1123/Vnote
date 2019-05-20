//
//  CJRenameBookView.h
//  VNote
//
//  Created by ccj on 2019/5/19.
//  Copyright © 2019 ccj. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^Click)(NSString *);
@interface CJRenameBookView : UIView
+(instancetype)xibWithView;
-(void)showInView:(UIView *)view title:(NSString *)title confirm:(Click)click;
-(void)hide;
@property (nonatomic,copy) Click click;
@property (nonatomic,copy) NSString *title;

@end

NS_ASSUME_NONNULL_END
