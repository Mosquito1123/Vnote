//
//  CJBookMenu.h
//  VNote
//
//  Created by ccj on 2018/7/28.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CJBookMenu : UIView
@property (weak, nonatomic) IBOutlet UITableView *tableView;
+(instancetype)xibBookMenuWithBooks:(NSMutableArray<CJBook *> *)books title:(NSString *)title didClickIndexPath:(void(^)(NSIndexPath *indexPath))block;
@property(nonatomic,assign) BOOL show;
@property(nonatomic,strong) NSString *title;
@end
