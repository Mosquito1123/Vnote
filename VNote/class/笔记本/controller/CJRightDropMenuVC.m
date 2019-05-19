//
//  CJRightDropMenuVC.m
//  VNote
//
//  Created by ccj on 2019/4/16.
//  Copyright © 2019 ccj. All rights reserved.
//

#import "CJRightDropMenuVC.h"

@interface CJRightDropMenuVC ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation CJRightDropMenuVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.bounces = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = 40.0;
    
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (cell == nil){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    NSString *imageName = nil;
    NSString *text = nil;
    NSInteger row = indexPath.row;
    switch (row) {
        case 0:
            imageName = @"加笔记本蓝";
            text = @"添加笔记本";
            break;
        case 1:
            imageName = @"加笔记蓝";
            text = @"添加笔记";
            break;
        case 2:
            imageName = @"加好友蓝";
            text = @"添加好友";
            break;
        default:
            break;
    }
    cell.imageView.image = [UIImage imageNamed:imageName];
    cell.textLabel.text = text;
    cell.textLabel.textColor = BlueBg;
    cell.textLabel.font = [UIFont boldSystemFontOfSize:14.0];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
    if (self.didSelectIndex){
        self.didSelectIndex(indexPath.row);
    }
}


@end
