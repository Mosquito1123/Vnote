//
//  CJSearchUserView.h
//  VNote
//
//  Created by ccj on 2018/7/1.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CJSearchUserView : UIView
@property (weak, nonatomic) IBOutlet UISearchBar *search;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
+(instancetype)xibSearchUserView;
@end
