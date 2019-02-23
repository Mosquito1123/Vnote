//
//  CJContentVC.h
//  VNote
//
//  Created by ccj on 2018/6/3.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CJContentVC : CJBaseVC
@property(strong,nonatomic)NSString *uuid;
@property(strong,nonatomic)NSString *noteTitle;
@property(nonatomic,assign) BOOL isMe;
@end
