//
//  CJFollowsVC.m
//  VNote
//
//  Created by ccj on 2018/8/28.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import "CJFollowsVC.h"
#import "CJSearchUserCell.h"
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
        [weakself.follows removeAllObjects];
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
    self.tableView.mj_header = [MJRefreshGifHeader cjRefreshWithPullType:CJPullTypeNormal header:^{
        [weakself getData];
    }];
    [self.tableView.mj_header beginRefreshing];
    self.tableView.tableFooterView = [[UIView alloc]init];
    [self.tableView registerNib:[UINib nibWithNibName:@"CJSearchUserCell" bundle:nil] forCellReuseIdentifier:@"UserCell"];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellID = @"UserCell";
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CJSearchUserCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    
    CJPenFriend *pen = self.follows[indexPath.row];
    [cell.avtar yy_setImageWithURL:IMG_URL(pen.avtar_url) placeholder:[UIImage imageNamed:@"avtar"]];
    cell.nicknameL.text = pen.nickname;
    
    cell.focusBtn.hidden = YES;
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.follows.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return cellH;
}



@end
