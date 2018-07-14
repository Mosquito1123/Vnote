//
//  CJSearchUserView.m
//  VNote
//
//  Created by ccj on 2018/7/1.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import "CJSearchUserView.h"
#import "CJSearchUserCell.h"
#import "CJPenFriend.h"
@interface CJSearchUserView()<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UIView *hView;
@property(nonatomic,strong)NSMutableArray<CJPenFriend *>* userM;
@end

@implementation CJSearchUserView
-(NSMutableArray *)userM{
    if (!_userM){
        _userM = [NSMutableArray array];
    }
    return _userM;
}

-(void)getData{
    CJUser *user = [CJUser sharedUser];
    AFHTTPSessionManager *manger = [AFHTTPSessionManager manager];
    if (!self.search.text.length){
        [self.tableView endLoadingData];
        return;
    }
    
    [manger POST:API_SEARCH_USERS parameters:@{@"email":user.email,@"user_name":self.search.text} progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self.userM removeAllObjects];
        NSDictionary *dict = responseObject;
        if ([dict[@"status"] intValue] == 0){
            for (NSDictionary *d in dict[@"search_users"]) {
                CJPenFriend *pen = [CJPenFriend penFriendWithDict:d];
                [self.userM addObject:pen];
                
            }
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self.tableView.mj_header endRefreshing];
                [self.tableView reloadData];
                [self.tableView endLoadingData];
                self.tableView.emtyHide = NO;
            }];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self.tableView.mj_header endRefreshing];
        [self.tableView endLoadingData];
    }];
}

+(instancetype)xibSearchUserView{
    CJSearchUserView *view = [[[NSBundle mainBundle]loadNibNamed:@"CJSearchUserView" owner:nil options:nil] lastObject];
    view.search.barTintColor = BlueBg;
    view.hView.backgroundColor = BlueBg;
    view.search.layer.borderWidth = 0;
    [view.search becomeFirstResponder];
    [[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UISearchBar class]]] setTintColor:[UIColor whiteColor]];
    [[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UISearchBar class]]] setTitle:@"取消"];
    view.search.delegate = view;
    view.tableView.delegate = view;
    view.tableView.dataSource = view;
    view.tableView.tableFooterView = [[UIView alloc]init];
    [view.tableView registerNib:[UINib nibWithNibName:@"CJSearchUserCell" bundle:nil] forCellReuseIdentifier:@"searchUserCell"];
    view.tableView.mj_header = [MJRefreshGifHeader cjRefreshHeader:^{
        [view getData];
    }];
    [view.tableView initDataWithTitle:@"无结果" descriptionText:@"没有搜索到任何笔友..." didTapButton:^{
        [view getData];
    }];
    view.tableView.emtyHide = YES;
    return view;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    if (!searchBar.text.length){
        return;
    }
    CJSearchUserView *view = (CJSearchUserView *)[searchBar superview];
    [view.tableView.mj_header beginRefreshing];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    CJSearchUserView *view = (CJSearchUserView *)[searchBar superview];
    [view removeFromSuperview];
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
    AFHTTPSessionManager *manger = [AFHTTPSessionManager manager];
    CJProgressHUD *hud = [CJProgressHUD cjShowWithPosition:CJProgressHUDPositionBothExist timeOut:0 withText:@"加载中..." withImages:nil];
    [manger POST:API_FOCUS_USER parameters:@{@"email":user.email,@"user_id":pen.v_user_id} progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [hud cjHideProgressHUD];
        NSDictionary *dict = responseObject;
        if ([dict[@"status"] intValue] == 0){
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [btn setTitle:@"已关注" forState:UIControlStateNormal];
            }];
            
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [hud cjShowError:@"关注失败..."];
    }];
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
}




@end
