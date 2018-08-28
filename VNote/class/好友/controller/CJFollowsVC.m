//
//  CJFollowsVC.m
//  VNote
//
//  Created by ccj on 2018/8/28.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import "CJFollowsVC.h"

@interface CJFollowsVC ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet CJTableView *tableView;
@property(nonatomic,strong) NSMutableArray *follows;
@end

@implementation CJFollowsVC
-(NSMutableArray *)follows{
    if (!_follows){
        _follows = [NSMutableArray array];
    }
    return _follows;
}
-(void)getData{
    
    CJWeak(self)
    [CJAPI getFollowsWithParams:@{@"email":self.penF.email} success:^(NSDictionary *dic) {
        for (NSDictionary *d in dic[@"follows"]) {
            
            CJPenFriend * penF = [CJPenFriend penFriendWithDict:d];
            [weakself.follows addObject:penF];
        }
        
        [weakself.tableView.mj_header endRefreshing];
        [weakself.tableView reloadData];
    } failure:^(NSError *error) {
        
    }];
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"粉丝";
    CJWeak(self)
    self.tableView.mj_header = [MJRefreshGifHeader cjRefreshHeader:^{
        [weakself getData];
    }];
    [self.tableView.mj_header beginRefreshing];
    self.tableView.tableFooterView = [[UIView alloc]init];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellID = @"cell";
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    CJPenFriend *pen = self.follows[indexPath.row];
    cell.textLabel.text = pen.nickname;
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.follows.count;
}


@end
