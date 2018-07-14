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
#import "CJSearchUserView.h"
#import "CJTableView.h"
@interface CJPenFriendVC ()<DZNEmptyDataSetSource,DZNEmptyDataSetDelegate>
@property(nonatomic,strong)NSMutableArray *penFrinedArrM;
@property (strong, nonatomic) IBOutlet CJTableView *friendsTableView;

@end

@implementation CJPenFriendVC

-(NSMutableArray *)penFrinedArrM{
    if (!_penFrinedArrM){
        _penFrinedArrM = [NSMutableArray array];
        RLMResults <CJPenFriend *>*pens = [CJPenFriend allObjects];
        for (CJPenFriend *p in pens) {
            [_penFrinedArrM addObject:p];
        }
    }
    return _penFrinedArrM;
}
- (IBAction)searchBtn:(id)sender {
    CJSearchUserView *view = [CJSearchUserView xibSearchUserView];
    [self.navigationController.view addSubview:view];
}

-(void)getData{
    CJUser *user = [CJUser sharedUser];
    AFHTTPSessionManager *manger = [AFHTTPSessionManager manager];
    [manger POST:API_PEN_FRIENDS parameters:@{@"email":user.email} progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dic = responseObject;
        NSMutableArray *penFriendArrM = [NSMutableArray array];
        if ([dic[@"status"] intValue] == 0){
            for (NSDictionary *d in dic[@"pen_friends"]) {
                CJPenFriend *pen = [CJPenFriend penFriendWithDict:d];
                [penFriendArrM addObject:pen];
            }
            
            RLMRealm *realm = [RLMRealm defaultRealm];
            [realm beginWriteTransaction];
            [realm deleteObjects:self.penFrinedArrM];
            self.penFrinedArrM = penFriendArrM;
            [realm addObjects:penFriendArrM];
            [realm commitWriteTransaction];
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self.friendsTableView endLoadingData];
                [self.friendsTableView.mj_header endRefreshing];
                [self.friendsTableView reloadData];
                
            }];
            
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self.friendsTableView endLoadingData];
        [self.friendsTableView.mj_header endRefreshing];
    }];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.friendsTableView registerNib:[UINib nibWithNibName:@"CJPenFriendCell" bundle:nil] forCellReuseIdentifier:@"penFriendCell"];
    
    
    self.friendsTableView.tableFooterView = [[UIView alloc]init];
   
    
    [self.friendsTableView initDataWithTitle:@"无关注" descriptionText:@"你还没有关注好友..." didTapButton:^{
        
        [self getData];
    }];
    self.friendsTableView.mj_header = [MJRefreshGifHeader cjRefreshHeader:^{
        [self getData];
    }];
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
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"penFriendCell";
    CJPenFriendCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    
    if (cell == nil){
        cell = [CJPenFriendCell xibPenFriendCell];
    }
    CJPenFriend *penf = self.penFrinedArrM[indexPath.row];
    if (penf.avtar_url.length){
        cell.avtar.yy_imageURL = IMG_URL(penf.avtar_url);
    }else{
    
        cell.avtar.image = [UIImage imageNamed:@"avtar.png"];
    }
    cell.nicknameL.text = penf.nickname;
    cell.emailL.text = penf.email;
    
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
        AFHTTPSessionManager *manger = [AFHTTPSessionManager manager];
        [manger POST:API_CANCEL_FOCUSED parameters:@{@"email":user.email,@"pen_friend_id":pen.v_user_id} progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [self.penFrinedArrM removeObject:pen];
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self.friendsTableView reloadData];
            }];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
        }];
        
        
    }];
    return @[setting];
    
}



@end
