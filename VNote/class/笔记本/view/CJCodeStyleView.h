//
//  CJCodeStyleView.h
//  VNote
//
//  Created by ccj on 2019/3/5.
//  Copyright © 2019 ccj. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CJCodeStyleView : UIView
+(instancetype)xibWithCodeStyleView;
-(void)selectItem:(void (^)(NSString *,NSIndexPath *))select confirm:(void(^)(NSString *))confirm selectIndexPath:(NSIndexPath *)indexPath competion:(void (^)(void))competion;

-(void)addInView:(UIView *)view;
-(void)hide;
-(void)show;
@end

NS_ASSUME_NONNULL_END
