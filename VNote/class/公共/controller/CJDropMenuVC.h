//
//  CJDropMenuVC.h
//  VNote
//
//  Created by ccj on 2018/9/1.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CJDropMenuVC : UIViewController
@property(nonatomic,strong) NSMutableArray <NSDictionary *> *accounts;
@property(nonatomic,copy) void (^didSelectIndex)(NSInteger index);
@end
