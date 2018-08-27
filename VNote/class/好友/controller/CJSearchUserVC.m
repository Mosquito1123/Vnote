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
@property (weak, nonatomic) IBOutlet CJSearchBar *searchBar;
@end

@implementation CJSearchUserVC
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
    [CJAPI searchUserWithParams:@{@"email":user.email,@"user_name":self.searchBar.text} success:^(NSDictionary *dic) {
        [weakself.userM removeAllObjects];
        if ([dic[@"status"] intValue] == 0){
            for (NSDictionary *d in dic[@"search_users"]) {
                CJPenFriend *pen = [CJPenFriend penFriendWithDict:d];
                [weakself.userM addObject:pen];
            }
            [weakself.tableView endLoadingData];
            weakself.tableView.emtyHide = NO;
            [weakself.tableView.mj_header endRefreshing];
            [weakself.tableView reloadData];

        }
    } failure:^(NSError *error) {
        [weakself.tableView.mj_header endRefreshing];
        [weakself.tableView endLoadingData];
    }];
    
}
-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.searchBar.barTintColor = BlueBg;
    self.searchBar.layer.borderWidth = 0;
    [self.searchBar becomeFirstResponder];
    [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UISearchBar class]]].title = @"取消";
    [[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UISearchBar class]]] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,nil] forState:UIControlStateNormal];
    self.searchBar.delegate = self;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc]init];
    [self.tableView registerNib:[UINib nibWithNibName:@"CJSearchUserCell" bundle:nil] forCellReuseIdentifier:@"searchUserCell"];
    CJWeak(self)
    self.tableView.mj_header = [MJRefreshGifHeader cjRefreshHeader:^{
        [weakself getData];
    }];
    [self.tableView initDataWithTitle:@"无结果" descriptionText:@"没有搜索到任何笔友..." didTapButton:^{
        [weakself getData];
    }];
    self.tableView.emtyHide = YES;
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
    if (user.avtar_url.length){
        cell.avtar.yy_imageURL = IMG_URL(user.avtar_url);
    }else{
        cell.avtar.image = [UIImage imageNamed:@"avtar.png"];
    }
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
        CJProgressHUD *hud = [CJProgressHUD cjShowWithPosition:CJProgressHUDPositionBothExist timeOut:0 withText:@"取消中..." withImages:nil];
        [CJAPI cancelFocusWithParams:@{@"email":user.email,@"pen_friend_id":pen.user_id} success:^(NSDictionary *dic) {
            [hud cjHideProgressHUD];
            [btn setTitle:@"关注" forState:UIControlStateNormal];
        } failure:^(NSError *error) {
            [hud cjShowError:@"取消失败!"];
        }];
        return;
    }
    
    CJProgressHUD *hud = [CJProgressHUD cjShowWithPosition:CJProgressHUDPositionBothExist timeOut:0 withText:@"加载中..." withImages:nil];
    [CJAPI focusWithParams:@{@"email":user.email,@"user_id":pen.user_id} success:^(NSDictionary *dic) {
        [hud cjHideProgressHUD];
        if ([dic[@"status"] intValue] == 0){
            [btn setTitle:@"取消关注" forState:UIControlStateNormal];
        }
    } failure:^(NSError *error) {
        [hud cjShowError:@"关注失败..."];
    }];
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
}



@end
