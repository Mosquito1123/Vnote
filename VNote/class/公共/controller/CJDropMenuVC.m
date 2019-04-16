//
//  CJDropMenuVC.m
//  VNote
//
//  Created by ccj on 2018/9/1.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import "CJDropMenuVC.h"
#import "CJDropViewCell.h"
@interface CJDropMenuVC ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;


@end

@implementation CJDropMenuVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.tableView.tableFooterView = [[UIView alloc]init];
    self.tableView.rowHeight = 40.0;
    self.tableView.bounces = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerNib:[UINib nibWithNibName:@"CJDropViewCell" bundle:nil] forCellReuseIdentifier:@"cell"];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == self.accounts.count){
        UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell1"];
        cell.textLabel.text = @"添加账号";
        cell.textLabel.textColor = BlueBg;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    static NSString *cellID = @"cell";
    CJDropViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    NSDictionary *dict = self.accounts[indexPath.row];
    [cell.avtar yy_setImageWithURL:IMG_URL(dict[@"avtar_url"]) placeholder:[UIImage imageNamed:@"avtar"]];
    cell.nicknameL.text = dict[@"nickname"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
    
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.accounts.count + 1;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self dismissViewControllerAnimated:YES completion:nil];
    if (self.didSelectIndex){
        self.didSelectIndex(indexPath.row);
    }
    
}
@end
