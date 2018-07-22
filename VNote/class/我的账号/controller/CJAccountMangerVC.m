//
//  CJAccountMangerVC.m
//  VNote
//
//  Created by ccj on 2018/7/22.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import "CJAccountMangerVC.h"
#import "CJLoginVC.h"
@interface CJAccountMangerVC ()
@property(nonatomic,strong) NSMutableArray<NSDictionary *> *accounts;
@end

@implementation CJAccountMangerVC
- (IBAction)edit:(UIBarButtonItem *)sender {
    if ([sender.title isEqualToString:@"编辑"]){
        sender.title = @"完成";
        self.tableView.editing = YES;
        
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
    static NSString *cellID = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
        CJCornerRadius(cell.imageView) = 20;
    }
    NSDictionary *dict = self.accounts[indexPath.row];
    // Configure the cell...
    CJUser *user = [CJUser sharedUser];
    if ([user.email isEqualToString:dict[@"email"]]){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    if ([dict[@"avtar_url"] length]){
        cell.imageView.yy_imageURL = IMG_URL(dict[@"avtar_url"]);

    }else{
        cell.imageView.image = [UIImage imageNamed:@"avtar.png"];
    }
    CGSize itemSize = CGSizeMake(40, 40);
    UIGraphicsBeginImageContextWithOptions(itemSize, NO, 0.0);//*1
    CGRect imageRect = CGRectMake(0, 0, itemSize.width, itemSize.height);
    [cell.imageView.image drawInRect:imageRect];
    cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();//*2
    
    UIGraphicsEndImageContext();//*3
    cell.textLabel.text = dict[@"nickname"];
    cell.detailTextLabel.text = dict[@"email"];
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if (row == self.accounts.count){
        // 点击的添加账号
        CJLoginVC *vc = [[CJLoginVC alloc]init];
        vc.action = YES;
        [self presentViewController:vc animated:YES completion:nil];
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
