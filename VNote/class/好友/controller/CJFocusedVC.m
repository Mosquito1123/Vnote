//
//  CJFocusedVC.m
//  VNote
//
//  Created by ccj on 2018/8/28.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import "CJFocusedVC.h"


@interface CJFocusedVC ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet CJTableView *tableView;
@property(nonatomic,strong) NSMutableArray *penFs;
@end

@implementation CJFocusedVC
-(NSMutableArray *)penFs{
    if (!_penFs){
        _penFs = [NSMutableArray array];
    }
    return _penFs;
}
-(void)getData{
    CJWeak(self)
    [CJAPI getPenFriendsWithParams:@{@"email":self.penF.email} success:^(NSDictionary *dic) {
        for (NSDictionary *d in dic[@"pen_friends"]) {
            
            CJPenFriend * penF = [CJPenFriend penFriendWithDict:d];
            [weakself.penFs addObject:penF];
        }
        
        [weakself.tableView.mj_header endRefreshing];
        [weakself.tableView reloadData];
    } failure:^(NSError *error) {
        
    }];
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"关注";
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
    CJPenFriend *pen = self.penFs[indexPath.row];
    cell.textLabel.text = pen.nickname;
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.penFs.count;
}

@end
