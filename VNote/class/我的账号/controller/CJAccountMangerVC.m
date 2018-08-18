//
//  CJAccountMangerVC.m
//  VNote
//
//  Created by ccj on 2018/7/22.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import "CJAccountMangerVC.h"
#import "CJLoginVC.h"
#import "CJPenFriendCell.h"
#import "CJTabBarVC.h"
#import "CJAddAccountVC.h"
@interface CJAccountMangerVC ()
@property(nonatomic,strong) NSMutableArray<NSDictionary *> *accounts;
@property(nonatomic,assign) NSInteger accountIndex;
@property(nonatomic,assign,getter=isEdit) BOOL edit;
@end

@implementation CJAccountMangerVC

-(void)setEdit:(BOOL)edit{
    _edit = edit;
    self.tableView.editing = edit;
    self.navigationItem.rightBarButtonItem.title = edit?@"完成":@"编辑";
    

}

- (IBAction)edit:(UIBarButtonItem *)sender {
    self.edit = !self.isEdit;
    [self.tableView reloadData];

}

-(NSMutableArray *)accounts{
    if (!_accounts){
        NSUserDefaults *userD = [NSUserDefaults standardUserDefaults];
        _accounts = [NSMutableArray arrayWithArray:[userD objectForKey:ALL_ACCOUNT]];
    }
    return _accounts;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc]init];
    [self.tableView registerNib:[UINib nibWithNibName:@"CJPenFriendCell" bundle:nil] forCellReuseIdentifier:@"accountCell"];
    self.edit = NO;
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (self.isEdit) return self.accounts.count;
    return self.accounts.count + 1;
}

-(void)addAccount{
    // 点击的添加账号
    CJAddAccountVC *vc = [[CJAddAccountVC alloc]init];
    [self presentViewController:vc animated:YES completion:nil];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == self.accounts.count){
        UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell1"];
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeContactAdd];
        btn.tintColor = BlueBg;
        [btn addTarget:self action:@selector(addAccount) forControlEvents:UIControlEventTouchUpInside];
        btn.frame = CGRectMake(0, 0, 30, 30);
        btn.cj_centerY = cell.cj_height / 2;
        btn.cj_x = 20;
        UILabel *l = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 150, 30)];
        l.text = @"添加账号";
        l.textColor = BlueBg;
        l.cj_x = btn.cj_maxX + 4;
        l.cj_centerY = btn.cj_centerY;
        [cell addSubview:btn];
        [cell addSubview:l];
        return cell;
        
    }
    static NSString *cellID = @"accountCell";
    CJPenFriendCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    
    NSDictionary *dict = self.accounts[indexPath.row];
    
    CJUser *user = [CJUser sharedUser];
    if ([user.email isEqualToString:dict[@"email"]]){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        self.accountIndex = indexPath.row;
    }
    else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    [cell.avtar yy_setImageWithURL:IMG_URL(dict[@"avtar_url"]) placeholder:[UIImage imageNamed:@"avtar"]];

    cell.nicknameL.text = dict[@"nickname"];
    cell.emailL.text = dict[@"email"];
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger row = indexPath.row;
    
    if (row == self.accounts.count){
        [self addAccount];
    }else{
        if (self.accountIndex == row) return ;
        CJProgressHUD *hud = [CJProgressHUD cjShowWithPosition:CJProgressHUDPositionNavigationBar timeOut:0 withText:@"加载中..." withImages:nil];
        NSDictionary *dict = self.accounts[row];
        AFHTTPSessionManager *manager = [AFHTTPSessionManager sharedHttpSessionManager];
        CJWeak(self)
        [manager POST:API_LOGIN parameters:@{@"email":dict[@"email"],@"passwd":dict[@"password"]} progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            //注册账号切换通知
            NSDictionary *dict = responseObject;
            [CJUser userWithDict:dict];
            [hud cjShowSuccess:@"切换成功"];
            weakself.accounts = nil;
            [tableView reloadData];
            NSNotification *noti = [NSNotification notificationWithName:CHANGE_ACCOUNT_NOTI object:nil];
            [[NSNotificationCenter defaultCenter] postNotification:noti];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [hud cjShowError:@"加载失败!"];
        }];
        
    }
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}



- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CJWeak(self)
    UITableViewRowAction *setting = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        
        [self.accounts removeObjectAtIndex:indexPath.row];
        NSUserDefaults *userD = [NSUserDefaults standardUserDefaults];
        [userD setValue:self.accounts forKey:ALL_ACCOUNT];
        [userD synchronize];
        NSNotification *noti = [NSNotification notificationWithName:ACCOUNT_NUM_CHANGE_NOTI object:nil];
        [[NSNotificationCenter defaultCenter] postNotification:noti];
        
        if (weakself.accountIndex == indexPath.row && weakself.accounts.count){
            // 触发登陆accounts的第一个账号
            CJProgressHUD *hud = [CJProgressHUD cjShowWithPosition:CJProgressHUDPositionNavigationBar timeOut:0 withText:@"加载中..." withImages:nil];
            NSDictionary *dict = self.accounts[0];
            AFHTTPSessionManager *manager = [AFHTTPSessionManager sharedHttpSessionManager];
            [manager POST:API_LOGIN parameters:@{@"email":dict[@"email"],@"passwd":dict[@"password"]} progress:^(NSProgress * _Nonnull uploadProgress) {
                
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                //注册账号切换通知wan
                NSDictionary *dict = responseObject;
                [CJUser userWithDict:dict];
                [hud cjShowSuccess:@"切换成功"];
                weakself.accounts = nil;
                [tableView reloadData];
                NSNotification *noti = [NSNotification notificationWithName:CHANGE_ACCOUNT_NOTI object:nil];
                [[NSNotificationCenter defaultCenter] postNotification:noti];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                [hud cjShowError:@"加载失败!"];
            }];
        }else if(weakself.accountIndex == indexPath.row && !weakself.accounts.count)
        {
            CJTabBarVC *tabVC = (CJTabBarVC *)self.tabBarController;
            CJLeftXViewController *vc = (CJLeftXViewController *)[tabVC parentViewController];
            [vc toRootViewController];
            NSUserDefaults *userD = [NSUserDefaults standardUserDefaults];
            [userD removeObjectForKey:@"email"];
            [userD removeObjectForKey:@"password"];
            [userD synchronize];
        }
        [[NSOperationQueue mainQueue]addOperationWithBlock:^{
            weakself.edit = NO;
            [tableView reloadData];
        }];
        
        
    }];
    return @[setting];
    
}


@end
