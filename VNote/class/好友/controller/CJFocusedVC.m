//
//  CJFocusedVC.m
//  VNote
//
//  Created by ccj on 2018/8/28.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import "CJFocusedVC.h"
#import "CJPenFriendCell.h"

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
    [CJAPI requestWithAPI:API_PEN_FRIENDS params:@{@"email":self.penF.email} success:^(NSDictionary *dic) {
        [weakself.penFs removeAllObjects];
        for (NSDictionary *d in dic[@"pen_friends"]) {
            
            CJPenFriend * penF = [CJPenFriend penFriendWithDict:d];
            [weakself.penFs addObject:penF];
        }
        
        [weakself.tableView.mj_header endRefreshing];
        [weakself.tableView reloadData];
    } failure:^(NSDictionary *dic) {
        
    } error:^(NSError *error) {
        [weakself.tableView.mj_header endRefreshing];
        ERRORMSG
    }];
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"关注";
    CJWeak(self)
    self.tableView.mj_header = [MJRefreshGifHeader cjRefreshWithPullType:CJPullTypeNormal header:^{
        [weakself getData];
    }];
    [self.tableView.mj_header beginRefreshing];
    self.tableView.tableFooterView = [[UIView alloc]init];
    [self.tableView registerNib:[UINib nibWithNibName:@"CJPenFriendCell" bundle:nil] forCellReuseIdentifier:@"CJPenFriendCell"];
    self.tableView.rowHeight = cellH;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellID = @"CJPenFriendCell";
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CJPenFriendCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    
    CJPenFriend *pen = self.penFs[indexPath.row];
    [cell setUI:pen];
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.penFs.count;
}

@end
