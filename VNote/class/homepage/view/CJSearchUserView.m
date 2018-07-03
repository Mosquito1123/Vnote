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
    view.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        CJUser *user = [CJUser sharedUser];
        [CJFetchData fetchDataWithAPI:API_SEARCH_USERS postData:@{@"email":user.email,@"user_name":view.search.text} completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            [view.userM removeAllObjects];
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            if ([dict[@"status"] intValue] == 0){
                for (NSDictionary *d in dict[@"search_users"]) {
                    CJPenFriend *pen = [CJPenFriend penFriendWithDict:d];
                    [view.userM addObject:pen];
                }
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    [view.tableView.mj_header endRefreshing];
                    [view.tableView reloadData];
                }];
            }
            
            
        }];
    }];
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
    [CJFetchData fetchDataWithAPI:API_FOCUS_USER postData:@{@"email":user.email,@"user_id":pen.v_user_id} completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if ([dict[@"status"] intValue] == 0){
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [btn setTitle:@"已关注" forState:UIControlStateNormal];
            }];
            
        }
    }];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
}




@end
