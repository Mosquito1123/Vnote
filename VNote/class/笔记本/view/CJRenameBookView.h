//
//  CJRenameBookView.h
//  VNote
//
//  Created by ccj on 2019/5/19.
//  Copyright © 2019 ccj. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CJRenameBookView : UIView
+(instancetype)xibWithView;
-(void)showInView:(UIView *)view;
-(void)hide;
typedef void(^Click)(NSString *);
@property (nonatomic,copy) Click click;
@property (nonatomic,copy) NSString *title;

@end

NS_ASSUME_NONNULL_END
