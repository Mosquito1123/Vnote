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
@interface CJPenFriendVC ()<DZNEmptyDataSetSource,DZNEmptyDataSetDelegate>
@property(nonatomic,strong)NSMutableArray *penFrinedArrM;
@property(nonatomic,assign,getter=isLoading)BOOL loading;
@property(nonatomic,strong)UIActivityIndicatorView *activityView;
@end

@implementation CJPenFriendVC
- (void)setLoading:(BOOL)loading
{
    if (self.isLoading == loading) {
        return;
    }
    
    _loading = loading;
    // 每次 loading 状态被修改，就刷新空白页面。
    [self.tableView reloadEmptyDataSet];
}
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
                self.loading = NO;
                [self.tableView.mj_header endRefreshing];
                [self.tableView reloadData];
                [self.tableView reloadEmptyDataSet];
            }];
            
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerNib:[UINib nibWithNibName:@"CJPenFriendCell" bundle:nil] forCellReuseIdentifier:@"penFriendCell"];
    
    self.tableView.emptyDataSetSource = self;
    self.tableView.emptyDataSetDelegate = self;
    self.tableView.tableFooterView = [[UIView alloc]init];
   
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
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
                [self.tableView reloadData];
            }];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
        }];
        
        
    }];
    return @[setting];
    
}


- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSString *title = @"无关注";
    NSDictionary *attributes = @{
                                 NSFontAttributeName:[UIFont boldSystemFontOfSize:25.0f],
                                 NSForegroundColorAttributeName:[UIColor darkGrayColor]
                                 };
    return [[NSAttributedString alloc] initWithString:title attributes:attributes];
}

- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView {
    NSString *text = @"你没有关注任何人...";
    
    NSMutableParagraphStyle *paragraph = [NSMutableParagraphStyle new];
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    paragraph.alignment = NSTextAlignmentCenter;
    
    NSDictionary *attributes = @{
                                 NSFontAttributeName:[UIFont systemFontOfSize:14.0f],
                                 NSForegroundColorAttributeName:[UIColor lightGrayColor],
                                 NSParagraphStyleAttributeName:paragraph
                                 };
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (UIView *)customViewForEmptyDataSet:(UIScrollView *)scrollView {
    if (!self.isLoading) return nil;
    UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityView.color = BlueBg;
    [activityView startAnimating];
    self.activityView = activityView;
    [self getData];
    return activityView;
}


-(void)emptyDataSet:(UIScrollView *)scrollView didTapButton:(UIButton *)button{
    self.loading = YES;
    
}

- (NSAttributedString *)buttonTitleForEmptyDataSet:(UIScrollView *)scrollView forState:(UIControlState)state {
    NSMutableDictionary *attribute = [[NSMutableDictionary alloc] init];
    attribute[NSFontAttributeName] = [UIFont systemFontOfSize:15];
    attribute[NSForegroundColorAttributeName] = BlueBg;
    return [[NSAttributedString alloc] initWithString:@"点击刷新..." attributes:attribute];
}

@end
