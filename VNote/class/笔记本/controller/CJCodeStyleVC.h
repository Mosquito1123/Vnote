//
//  CJCodeStyleVC.h
//  VNote
//
//  Created by ccj on 2018/8/22.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CJCodeStyleVC : CJBaseVC
@property(weak,nonatomic) UIView *coverView;

-(void)selectItem:(void (^)(NSString *,NSIndexPath *))select confirm:(void(^)(NSString *))confirm selectIndexPath:(NSIndexPath *)indexPath competion:(void (^)(void))competion;
@end
