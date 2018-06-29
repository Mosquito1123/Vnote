//
//  CJTagVC.m
//  VNote
//
//  Created by ccj on 2018/6/25.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import "CJTagVC.h"
#import "CJNote.h"
#import "CJContentVC.h"
@interface CJTagVC ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation CJTagVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = self.tagTitle;
    self.tableView.tableFooterView = [[UIView alloc]init];
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellId = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        
    }
    CJNote *note = self.noteInfos[indexPath.row];
    cell.textLabel.text = note.title;
    
    return cell;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.noteInfos.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CJContentVC *contentVC = [[CJContentVC alloc]init];
    CJNote *note = self.noteInfos[indexPath.row];
    contentVC.uuid = note.uuid;
    [self.navigationController pushViewController:contentVC animated:YES];
}


@end
