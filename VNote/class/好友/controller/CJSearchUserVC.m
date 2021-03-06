//
//  CJSearchUserVC.m
//  VNote
//
//  Created by ccj on 2018/8/11.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import "CJSearchUserVC.h"
#import "CJSearchUserCell.h"

@interface CJSearchUserVC ()<UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource,DZNEmptyDataSetDelegate,DZNEmptyDataSetSource>
@property(nonatomic,strong)NSMutableArray<CJPenFriend *>* userM;
@property (weak, nonatomic) IBOutlet CJTableView *tableView;
@property (strong, nonatomic) CJSearchBar *searchBar;
@end

@implementation CJSearchUserVC
-(UISearchBar *)searchBar{
    if (!_searchBar){
        _searchBar = [[CJSearchBar alloc]init];
        _searchBar.barTintColor = BlueBg;
        _searchBar.tintColor = BlueBg;
        _searchBar.delegate = self;
        _searchBar.showsCancelButton = YES;
        _searchBar.placeholder = @"笔友名称";
        _searchBar.barStyle = UISearchBarStyleMinimal;
        [_searchBar.heightAnchor constraintEqualToConstant:44].active = YES;
    }
    return _searchBar;
}

-(NSMutableArray<CJPenFriend *> *)userM{
    if(!_userM){
        _userM = [NSMutableArray array];
    }
    return _userM;
}
-(void)getData{
    CJUser *user = [CJUser sharedUser];
    if (!self.searchBar.text.length){
        [self.tableView endLoadingData];
        return;
    }
    CJWeak(self)
    [CJAPI requestWithAPI:API_SEARCH_USERS params:@{@"email":user.email,@"user_name":weakself.searchBar.text} success:^(NSDictionary *dic) {
        [weakself.userM removeAllObjects];
        if ([dic[@"status"] intValue] == 0){
            for (NSDictionary *d in dic[@"search_users"]) {
                CJPenFriend *pen = [CJPenFriend penFriendWithDict:d];
                [weakself.userM addObject:pen];
            }
            [weakself.tableView endLoadingData];
            [weakself.tableView.mj_header endRefreshing];
            [weakself.tableView reloadData];
            
        }
    } failure:^(NSDictionary *dic) {
        
    } error:^(NSError *error) {
        [weakself.tableView.mj_header endRefreshing];
        [weakself.tableView endLoadingData];
        ERRORMSG
    }];
    
    
}
-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.navigationItem.titleView = self.searchBar;
    
    [self.searchBar becomeFirstResponder];
    self.searchBar.delegate = self;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc]init];
    [self.tableView registerNib:[UINib nibWithNibName:@"CJSearchUserCell" bundle:nil] forCellReuseIdentifier:@"searchUserCell"];
    CJWeak(self)
    self.tableView.mj_header = [MJRefreshGifHeader cjRefreshWithPullType:CJPullTypeNormal header:^{
        [weakself getData];
    }];
    [self.tableView initDataWithTitle:@"无结果" descriptionText:@"没有搜索到任何笔友..." didTapButton:^{
        [weakself getData];
    }];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    if (!searchBar.text.length){
        return;
    }
    [self.tableView.mj_header beginRefreshing];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:NO completion:nil];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.userM.count;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    static NSString *cellId = @"searchUserCell";
    CJSearchUserCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    if (!cell){
        
        cell = [CJSearchUserCell xibSearchUserCell];
    }
    CJPenFriend *user = self.userM[indexPath.row];
    [cell.avtar yy_setImageWithURL:IMG_URL(user.avtar_url) placeholder:[UIImage imageNamed:@"avtar"]];
    cell.nicknameL.text = user.nickname;
    
    [cell.focusBtn addTarget:self action:@selector(focusBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
    
}

-(void)focusBtnClick:(UIButton *)btn{
    CJSearchUserCell *cell = (CJSearchUserCell *)btn.superview;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    CJPenFriend *pen = self.userM[indexPath.row];
    CJUser *user = [CJUser sharedUser];
    if ([btn.titleLabel.text isEqualToString:@"取消关注"]){
        CJProgressHUD *hud = [CJProgressHUD cjShowInView:self.view timeOut:TIME_OUT withText:@"取消中..." withImages:nil];
        
        [CJAPI requestWithAPI:API_CANCEL_FOCUSED params:@{@"email":user.email,@"pen_friend_id":pen.user_id} success:^(NSDictionary *dic) {
            [hud cjHideProgressHUD];
            [CJRlm deleteObject:pen];
            [[NSNotificationCenter defaultCenter] postNotificationName:PEN_FRIEND_CHANGE_NOTI object:nil];
            [btn setTitle:@"关注" forState:UIControlStateNormal];
        } failure:^(NSDictionary *dic) {
            [hud cjShowError:dic[@"msg"]];
        } error:^(NSError *error) {
            [hud cjShowError:net101code];
        }];
        return;
    }
    
    CJProgressHUD *hud = [CJProgressHUD cjShowInView:self.view timeOut:TIME_OUT withText:@"加载中..." withImages:nil];
    [CJAPI requestWithAPI:API_FOCUS_USER params:@{@"email":user.email,@"user_id":pen.user_id} success:^(NSDictionary *dic) {
        [hud cjHideProgressHUD];
        [CJRlm addObject:pen];
        [btn setTitle:@"取消关注" forState:UIControlStateNormal];
        [[NSNotificationCenter defaultCenter] postNotificationName:PEN_FRIEND_CHANGE_NOTI object:nil];
    } failure:^(NSDictionary *dic) {
        [hud cjShowError:dic[@"msg"]];
    } error:^(NSError *error) {
        [hud cjShowError:net101code];
    }];
    
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 55;
}

@end
