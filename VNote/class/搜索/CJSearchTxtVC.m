//
//  CJSearchTxtVC.m
//  VNote
//
//  Created by ccj on 2018/8/12.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import "CJSearchTxtVC.h"

@interface CJSearchTxtVC ()<UITableViewDelegate,UITableViewDataSource,DZNEmptyDataSetSource,DZNEmptyDataSetDelegate,UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet CJTableView *tableView;
@property (weak, nonatomic) IBOutlet CJSearchBar *searchBar;

@end

@implementation CJSearchTxtVC

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UISearchBar class]]].title = @"取消";
    [[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UISearchBar class]]] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,nil] forState:UIControlStateNormal];
    [self.searchBar becomeFirstResponder];
    self.tableView.tableFooterView = [[UIView alloc]init];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellId = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    cell.textLabel.text = self.searchRecords[indexPath.row];
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (!self.searchBar.text.length){
        return self.searchRecords.count;
    }else{
        return 0;
    }
    
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [self dismissViewControllerAnimated:NO completion:nil];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    NSString *text = self.searchBar.text;
    if (!text.length) return;
    // 保存搜索记录
    if (![self.searchRecords containsObject:text]){
        [self.searchRecords addObject:text];
    }
    NSUserDefaults *userD = [NSUserDefaults standardUserDefaults];
    [userD setObject:self.searchRecords forKey:SEARCH_RECORD];
    [userD synchronize];
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:UPDATE_SEARCH_RECORD_NOTI object:nil]];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    CJUser *user = [CJUser sharedUser];
    CJProgressHUD *hud = [CJProgressHUD cjShowWithPosition:CJProgressHUDPositionNavigationBar timeOut:0 withText:@"加载中..." withImages:nil];
    [manager POST:API_SEARCH_NOTE parameters:@{@"email":user.email,@"key":text} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [hud cjHideProgressHUD];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [hud cjShowError:@"加载失败!"];
    }];
    
}


@end
