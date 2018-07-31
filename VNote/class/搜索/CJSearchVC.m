//
//  CJSearchVC.m
//  VNote
//
//  Created by ccj on 2018/7/31.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import "CJSearchVC.h"

@interface CJSearchVC ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet CJTableView *tableView;

@end

@implementation CJSearchVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc]init];
}


- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    static NSString *cellId = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    cell.textLabel.text = @"1";
    return cell;
    
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

@end
