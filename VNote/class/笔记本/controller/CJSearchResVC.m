//
//  CJSearchResVC.m
//  VNote
//
//  Created by ccj on 2018/8/12.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import "CJSearchResVC.h"
#import "CJContentVC.h"
@interface CJSearchResVC ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet CJTableView *tableView;
@property(nonatomic,assign) BOOL searchStatus;

@end

@implementation CJSearchResVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"搜索结果";
    self.tableView.tableFooterView = [[UIView alloc]init];
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellId = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = self.notes[indexPath.row].title;
    cell.imageView.image = [UIImage imageNamed:@"笔记灰"];
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.notes.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CJContentVC *contentVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"contentVC"];
    CJNote *note = self.notes[indexPath.row];
    contentVC.note = note;
    contentVC.isMe = YES;
    
    [self.navigationController pushViewController:contentVC animated:YES];
}


@end
