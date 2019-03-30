//
//  CJPenFriendVC.m
//  VNote
//
//  Created by ccj on 2018/6/30.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import "CJPenFriendVC.h"
#import "CJPenFriendCell.h"
#import "CJPenFriend.h"
#import "CJTableView.h"
#import "CJPenFBookVC.h"
#import "CJSearchUserVC.h"
@interface CJPenFriendVC ()<DZNEmptyDataSetSource,DZNEmptyDataSetDelegate,UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,strong)NSMutableArray<CJPenFriend *> *penFrinedArrM;
@property (weak, nonatomic) IBOutlet CJTableView *tableView;



@end

@implementation CJPenFriendVC
// 重新获取pen
-(NSMutableArray *)reGetRlmPenFriends{
    NSMutableArray *array = [NSMutableArray array];
    
    RLMResults <CJPenFriend *>*pens = [CJPenFriend allObjectsInRealm:[CJRlm shareRlm]];
    for (CJPenFriend *p in pens) {
        [array addObject:p];
    }
    return array;
}

-(NSMutableArray *)penFrinedArrM{
    if (!_penFrinedArrM){
        _penFrinedArrM = [self reGetRlmPenFriends];
    }
    return _penFrinedArrM;
}
- (void)searchUser {
    CJSearchUserVC *vc = [[CJSearchUserVC alloc]init];
    CJMainNaVC *nav = [[CJMainNaVC alloc]initWithRootViewController:vc];
    
    nav.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:nav animated:NO completion:nil];
}

-(void)getData{
    CJUser *user = [CJUser sharedUser];
    CJWeak(self)
    [CJAPI getPenFriendsWithParams:@{@"email":user.email} success:^(NSDictionary *dic) {
        NSMutableArray *penFriendArrM = [NSMutableArray array];
        if ([dic[@"status"] intValue] == 0){
            for (NSDictionary *d in dic[@"pen_friends"]) {
                CJPenFriend *pen = [CJPenFriend penFriendWithDict:d];
                [penFriendArrM addObject:pen];
            }
            
            RLMRealm *realm = [CJRlm cjRlmWithName:user.email];
            [realm beginWriteTransaction];
            [realm deleteObjects:self.penFrinedArrM];
            weakself.penFrinedArrM = penFriendArrM;
            [realm addObjects:penFriendArrM];
            [realm commitWriteTransaction];
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [weakself.tableView endLoadingData];
                [weakself.tableView.mj_header endRefreshing];
                [weakself.tableView reloadData];
                
            }];
            
        }
    } failure:^(NSError *error) {
        [weakself.tableView endLoadingData];
        [weakself.tableView.mj_header endRefreshing];
    }];
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self addAvtar];
    self.navigationItem.title = @"关注";
    self.rt_navigationController.tabBarItem.title = @"关注";
    self.rt_navigationController.tabBarItem.image = [UIImage imageNamed:@"关注灰"];
    self.rt_navigationController.tabBarItem.selectedImage = [UIImage imageNamed:@"关注蓝"];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"加好友"] style:UIBarButtonItemStylePlain target:self action:@selector(searchUser)];
    [self.tableView registerNib:[UINib nibWithNibName:@"CJPenFriendCell" bundle:nil] forCellReuseIdentifier:@"penFriendCell"];
    self.tableView.tableFooterView = [[UIView alloc]init];
    [self.tableView initDataWithTitle:@"无关注" descriptionText:@"你还没有关注好友..." didTapButton:^{
        
        [self getData];
    }];
    self.tableView.mj_header = [MJRefreshGifHeader cjRefreshWithPullType:CJPullTypeNormal header:^{
        [self getData];
    }];
    [self.tableView.mj_header beginRefreshing];
    // 监听切换账号通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeAcountNoti:) name:LOGIN_ACCOUT_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeAcountNoti:) name:PEN_FRIEND_CHANGE_NOTI object:nil];
}

-(void)changeAcountNoti:(NSNotification *)noti{
    self.penFrinedArrM = [self reGetRlmPenFriends];
    [self.tableView reloadData];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.penFrinedArrM.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CJPenFBookVC *vc = [[CJPenFBookVC alloc]init];
    vc.penF = self.penFrinedArrM[indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"penFriendCell";
    CJPenFriendCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    
    if (cell == nil){
        cell = [CJPenFriendCell xibPenFriendCell];
    }
    CJPenFriend *penf = self.penFrinedArrM[indexPath.row];
    [cell.avtar yy_setImageWithURL:IMG_URL(penf.avtar_url) placeholder:[UIImage imageNamed:@"avtar"]];
    cell.nicknameL.text = penf.nickname;
    cell.intro.text = penf.introduction;
    
    return cell;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CJPenFriend *pen = self.penFrinedArrM[indexPath.row];
    CJUser *user = [CJUser sharedUser];
    
    UITableViewRowAction *setting = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"取消关注" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        CJProgressHUD *hud = [CJProgressHUD cjShowInView:self.view timeOut:TIME_OUT withText:@"取消中..." withImages:nil];
        [CJAPI cancelFocusWithParams:@{@"email":user.email,@"pen_friend_id":pen.user_id} success:^(NSDictionary *dic) {
            [hud cjHideProgressHUD];
            [CJRlm deleteObject:pen];
            [[NSNotificationCenter defaultCenter] postNotificationName:PEN_FRIEND_CHANGE_NOTI object:nil];
            
        } failure:^(NSError *error) {
            [hud cjShowError:net101code];
        }];
        
    }];
    return @[setting];
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return cellH;
}


@end
