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
@interface CJAccountMangerVC ()
@property(nonatomic,strong) NSMutableArray<NSDictionary *> *accounts;
@end

@implementation CJAccountMangerVC
- (IBAction)edit:(UIBarButtonItem *)sender {
    if ([sender.title isEqualToString:@"编辑"]){
        sender.title = @"完成";
        [self.tableView setEditing:YES animated:YES];
        
    }else
    {
        sender.title = @"编辑";
        self.tableView.editing = NO;
        
    }
    [self.tableView reloadData];
    
    
}

-(NSMutableArray *)accounts{
    if (!_accounts){
        NSUserDefaults *userD = [NSUserDefaults standardUserDefaults];
        _accounts = [NSMutableArray arrayWithArray:[userD objectForKey:@"AllAccount"]];
    }
    return _accounts;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc]init];
    [self.tableView registerNib:[UINib nibWithNibName:@"CJPenFriendCell" bundle:nil] forCellReuseIdentifier:@"accountCell"];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView.editing) return self.accounts.count;
    return self.accounts.count + 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == self.accounts.count){
        UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell1"];
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeContactAdd];
        btn.frame = CGRectMake(0, 0, 30, 30);
        btn.cj_centerY = cell.cj_height / 2;
        btn.cj_x = 20;
        UILabel *l = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 150, 30)];
        l.text = @"添加或注册账号";
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
    }
    else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    if ([dict[@"avtar_url"] length]){
        cell.avtar.yy_imageURL = IMG_URL(dict[@"avtar_url"]);

    }else{
        cell.avtar.image = [UIImage imageNamed:@"avtar.png"];
    }
    cell.nicknameL.text = dict[@"nickname"];
    cell.emailL.text = dict[@"email"];
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    if (row == self.accounts.count){
        // 点击的添加账号
        CJLoginVC *vc = [[CJLoginVC alloc]init];
        vc.action = YES;
        [self presentViewController:vc animated:YES completion:nil];
    }else{
        CJProgressHUD *hud = [CJProgressHUD cjShowWithPosition:CJProgressHUDPositionNavigationBar timeOut:0 withText:@"加载中..." withImages:nil];
        NSDictionary *dict = self.accounts[row];
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        [manager POST:API_LOGIN parameters:@{@"email":dict[@"email"],@"passwd":dict[@"passwd"]} progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            //注册账号切换通知
            NSDictionary *dict = responseObject;
            [CJUser userWithDict:dict];
            [hud cjShowSuccess:@"切换成功!"];
            [self.tableView reloadData];
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

    
    UITableViewRowAction *setting = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }];
    return @[setting];
    
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
