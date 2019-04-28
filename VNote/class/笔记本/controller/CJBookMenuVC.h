//
//  CJBookMenuVC.h
//  VNote
//
//  Created by ccj on 2018/9/13.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CJBookMenuVC : UIViewController
@property(nonatomic,strong) NSArray<CJBook *> *books;
@property(nonatomic,strong) NSIndexPath *indexPath;
@property(nonatomic,copy) void (^selectIndexPath)(NSIndexPath *indexPath);
@end
