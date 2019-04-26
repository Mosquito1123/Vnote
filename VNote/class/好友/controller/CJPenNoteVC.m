//
//  CJPenNoteVC.m
//  VNote
//
//  Created by ccj on 2018/7/22.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import "CJPenNoteVC.h"
#import "CJNote.h"
#import "CJContentVC.h"
#import "CJNoteCell.h"
@interface CJPenNoteVC ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet CJTableView *tableView;

@end

@implementation CJPenNoteVC



- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = self.bookTitle;
    CJWeak(self)
    self.tableView.mj_header = [MJRefreshGifHeader cjRefreshWithPullType:CJPullTypeNormal header:^{
        [CJAPI requestWithAPI:API_BOOK_DETAIL params:@{@"email":self.email,@"book_uuid":self.book_uuid} success:^(NSDictionary *dic) {
            NSArray *res = dic[@"notes"];
            [weakself.notes removeAllObjects];
            for (NSDictionary *dic in res){
                CJNote *note = [CJNote noteWithDict:dic];
                [weakself.notes addObject:note];
            }
            [weakself.tableView reloadData];
            [weakself.tableView.mj_header endRefreshing];
            [weakself.tableView endLoadingData];
        } failure:^(NSDictionary *dic) {
            [CJProgressHUD cjShowErrorWithPosition:CJProgressHUDPositionNavigationBar withText:dic[@"msg"]];
            [weakself.tableView.mj_header endRefreshing];
            [weakself.tableView endLoadingData];
        } error:^(NSError *error) {
            ERRORMSG
        }];
        
    }];
    [self.tableView initDataWithTitle:@"无笔记" descriptionText:@"该笔记本下无笔记..." didTapButton:^{
        
    }];
    [self.tableView registerNib:[UINib nibWithNibName:@"CJNoteCell" bundle:nil] forCellReuseIdentifier:@"cell"];
    self.tableView.rowHeight = [CJNoteCell height];
    self.tableView.emtyHide = NO;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CJNoteCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (!cell){
        cell = [CJNoteCell xibWithNoteCell];
    }
    NSInteger row = indexPath.row;
    CJNote *note = self.notes[row];
    [cell setUI:note];
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSLog(@"%ld",self.notes.count);
    return self.notes.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CJContentVC *contentVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"contentVC"];
    CJNote *note = self.notes[indexPath.row];
    contentVC.uuid = note.uuid;
    contentVC.noteTitle = note.title;
    contentVC.isMe = NO;
    
    [self.navigationController pushViewController:contentVC animated:YES];
    
}

@end
