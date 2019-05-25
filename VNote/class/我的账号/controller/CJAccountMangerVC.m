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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeAccount:) name:ACCOUNT_NUM_CHANGE_NOTI object:nil];
    self.tableView.rowHeight = 50;
    
}

-(void)changeAccount:(NSNotification *)noti{
    self.accounts = nil;
    [self.tableView reloadData];
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
    vc.modalPresentationStyle = UIModalPresentationOverFullScreen;
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
        [cell.contentView addSubview:btn];
        [cell.contentView addSubview:l];
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
    CJPenFriend *p = [CJPenFriend penFriendWithDict:dict];
    
    [cell setUI:p];
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger row = indexPath.row;
    
    if (row == self.accounts.count){
        [self addAccount];
    }else{
        if (self.accountIndex == row) return ;
        CJProgressHUD *hud = [CJProgressHUD cjShowInView:self.view timeOut:TIME_OUT withText:@"切换中..." withImages:nil];

        NSDictionary *dict = self.accounts[row];
        CJWeak(self)
        [CJAPI requestWithAPI:API_LOGIN params:@{@"email":dict[@"email"],@"passwd":dict[@"password"]} success:^(NSDictionary *dic) {
            [hud cjShowSuccess:@"切换成功"];
            weakself.accounts = nil;
            [tableView reloadData];
        } failure:^(NSDictionary *dic) {
            [hud cjShowError:dic[@"msg"]];
        } error:^(NSError *error) {
            [hud cjShowError:net101code];
        }];
    }
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}



- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CJWeak(self)
    UITableViewRowAction *setting = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        
        [weakself.accounts removeObjectAtIndex:indexPath.row];
        NSUserDefaults *userD = [NSUserDefaults standardUserDefaults];
        [userD setValue:self.accounts forKey:ALL_ACCOUNT];
        [userD synchronize];
        NSNotification *noti = [NSNotification notificationWithName:ACCOUNT_NUM_CHANGE_NOTI object:nil];
        [[NSNotificationCenter defaultCenter] postNotification:noti];
        
        if (weakself.accountIndex == indexPath.row && weakself.accounts.count){
            // 触发登陆accounts的第一个账号
            CJProgressHUD *hud = [CJProgressHUD cjShowInView:weakself.view timeOut:TIME_OUT withText:@"加载中..." withImages:nil];
            NSDictionary *dict = weakself.accounts[0];
            [CJAPI requestWithAPI:API_LOGIN params:@{@"email":dict[@"email"],@"passwd":dict[@"password"]} success:^(NSDictionary *dic) {
                [hud cjShowSuccess:@"切换成功"];
                weakself.accounts = nil;
                [tableView reloadData];
            } failure:^(NSDictionary *dic) {
                [hud cjShowError:dic[@"msg"]];
            } error:^(NSError *error) {
                [hud cjShowError:net101code];
            }];
            
            
        }else if(weakself.accountIndex == indexPath.row && !weakself.accounts.count)
        {
            [CJTool deleteAccountInfoFromPrefrence:[CJUser sharedUser]];
            // 登出
            UIWindow *w = [UIApplication sharedApplication].keyWindow;
            CJLoginVC *vc = [[CJLoginVC alloc]init];
            w.rootViewController = vc;
            NSUserDefaults *userD = [NSUserDefaults standardUserDefaults];
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
