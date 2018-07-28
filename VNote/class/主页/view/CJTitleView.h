//
//  CJTitleView.h
//  VNote
//
//  Created by ccj on 2018/7/28.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CJTitleView : UIView

-(instancetype)initWithTitle:(NSString *)title click:(void (^)(void))block;
@property (nonatomic,strong) NSString *title;
@end
