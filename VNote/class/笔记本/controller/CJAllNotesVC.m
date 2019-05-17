//
//  CJAllNotesVC.m
//  VNote
//
//  Created by ccj on 2019/5/1.
//  Copyright © 2019 ccj. All rights reserved.
//

#import "CJAllNotesVC.h"
#import "CJNoteCell.h"
#import "CJContentVC.h"
@interface CJAllNotesVC ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet CJTableView *tableView;
@property(nonatomic,strong) NSMutableArray<CJNote *> *notes;
@end

@implementation CJAllNotesVC

-(NSMutableArray <CJNote *>*)notes{
    if(!_notes){
        _notes = [NSMutableArray array];
        NSMutableArray *notes;
        RLMRealm *rlm = [CJRlm shareRlm];
        notes = [CJNote cjAllObjectsInRlm:rlm];
        _notes = [CJTool orderObjects:notes withKey:@"title"];
    }
    
    return _notes;
}

-(void)getBookData{
    CJUser *user = [CJUser sharedUser];
    if (!user.nickname){
        return ;
    }
    CJWeak(self)
    [CJAPI requestWithAPI:API_GET_ALL_BOOKS_AND_NOTES params:@{@"email":user.email} success:^(NSDictionary *dic) {
        
        NSMutableArray *notesArrM = [NSMutableArray array];
        for (NSDictionary *d in dic[@"notes"]){
            CJNote *note = [CJNote noteWithDict:d];
            [notesArrM addObject:note];
        }
        self.notes = [CJTool orderObjects:notesArrM withKey:@"title"];
        [weakself.tableView.mj_header endRefreshing];
        [weakself.tableView reloadData];
        [weakself.tableView endLoadingData];
    } failure:^(NSDictionary *dic) {
        [weakself.tableView endLoadingData];
        [weakself.tableView.mj_header endRefreshing];
    } error:^(NSError *error) {
        [weakself.tableView endLoadingData];
        [weakself.tableView.mj_header endRefreshing];
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"全部笔记";
    CJWeak(self)
    self.tableView.mj_header = [MJRefreshGifHeader cjRefreshWithPullType:CJPullTypeNormal header:^{
        [weakself getBookData];
    }];
    [self.tableView initDataWithTitle:@"无笔记" descriptionText:@"你还没有创建笔记..." didTapButton:^{
        
    }];
    
    self.tableView.rowHeight = [CJNoteCell height];
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CJNoteCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (!cell){
        cell = [CJNoteCell xibWithNoteCell];
    }
    NSInteger row = indexPath.row;
    CJNote *note = self.notes[row];
    if (note.isInvalidated){
        return cell;
    }
    [cell setUI:note];
    
    return cell;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.notes.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CJContentVC *contentVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"contentVC"];
    CJNote *note = self.notes[indexPath.row];
    if ([note isInvalidated])return;
    contentVC.note = note;
    contentVC.isMe = YES;
    [self.navigationController pushViewController:contentVC animated:YES];
}


@end
