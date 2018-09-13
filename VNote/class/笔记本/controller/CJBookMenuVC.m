//
//  CJBookMenuVC.m
//  VNote
//
//  Created by ccj on 2018/9/13.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import "CJBookMenuVC.h"

@interface CJBookMenuVC ()

@end
static NSString *cellId = @"cell";
@implementation CJBookMenuVC
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellId];
}

-(void)viewDidAppear:(BOOL)animated{
    [self.tableView scrollToRowAtIndexPath:self.indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.books.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    
    cell.textLabel.text = self.books[indexPath.row].name;
    if (indexPath.row == self.indexPath.row){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.indexPath = indexPath;
    if (self.selectIndexPath) {
        self.selectIndexPath(indexPath);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}



@end
