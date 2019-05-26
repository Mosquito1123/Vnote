//
//  CJTableView.h
//  VNote
//
//  Created by ccj on 2018/7/13.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CJTableView : UITableView

-(void)initDataWithTitle:(NSString *)title descriptionText:(NSString *)descriptionText didTapButton:(void (^)(void))block;
-(void)beginLoadingData;
-(void)endLoadingData;
@property(nonatomic,assign,getter=isEmptyHidden)BOOL emtyHide;
@property(nonatomic,strong) UIColor *headerColor;
@end
