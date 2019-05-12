//
//  CJBookMenuVC.m
//  VNote
//
//  Created by ccj on 2018/9/13.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import "CJBookMenuVC.h"

@interface CJBookMenuVC ()<UITableViewDelegate,UITableViewDataSource>

@property(strong,nonatomic) UITableView *tableView;
@end
static NSString *cellId = @"cell";
@implementation CJBookMenuVC

-(void)reloadData{
    [self.tableView reloadData];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView = [[UITableView alloc]init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    CJWeak(self)
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakself.view).mas_offset(10);
        make.width.mas_equalTo(weakself.view);
        make.bottom.mas_equalTo(weakself).mas_offset(-10);
        make.left.mas_equalTo(weakself.view);
        
    }];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellId];
    self.tableView.rowHeight = 40.f;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

-(void)viewDidAppear:(BOOL)animated{
    [self.tableView scrollToRowAtIndexPath:self.indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.books.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    cell.imageView.image = [UIImage imageNamed:@"笔记本灰"];
    CJBook *book = self.books[indexPath.row];
    
    if ([book isInvalidated]) return cell;
    cell.textLabel.text = book.name;
    if (indexPath.row == self.indexPath.row){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.indexPath = indexPath;
    if (self.selectIndexPath) {
        self.selectIndexPath(indexPath);
    }
    [tableView reloadData];
    [self dismissViewControllerAnimated:YES completion:nil];
}



@end
