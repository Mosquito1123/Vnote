//
//  CJRecentVC.m
//  VNote
//
//  Created by ccj on 2018/7/31.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import "CJRecentVC.h"
#import "CJContentVC.h"
#import "CJNoteCell.h"
@interface CJRecentVC ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet CJTableView *tableView;
@property(nonatomic,strong) NSMutableArray <CJNote *> *notes;
@end

@implementation CJRecentVC

-(NSMutableArray *)recentNotes{
    NSMutableArray *notes = [NSMutableArray array];
    RLMRealm *rlm = [CJRlm shareRlm];
    NSMutableArray *sets = [CJNote cjAllObjectsInRlm:rlm];
    NSTimeInterval nowtime = [[NSDate date] timeIntervalSince1970];
    long long theTime = [[NSNumber numberWithDouble:nowtime] longLongValue];
    long long twoSecs = 2 * 24 * 60 * 60;
    for (CJNote *n in sets) {
        if (theTime - [n.updated_at longLongValue] <= twoSecs){
            [notes addObject:n];
        }
    }
    return notes;
}

-(void)getData{
    CJUser *user = [CJUser sharedUser];
    CJWeak(self)
    [CJAPI requestWithAPI:API_RECENT_NOTES params:@{@"email":user.email} success:^(NSDictionary *dic) {
        
        NSMutableArray *array = [NSMutableArray array];
        for (NSDictionary *d in dic[@"recent_notes"]) {
            CJNote *note = [CJNote noteWithDict:d];
            [array addObject:note];
        }
        weakself.notes = array;
        [weakself.tableView.mj_header endRefreshing];
        [weakself.tableView reloadData];
        [weakself.tableView endLoadingData];
    } failure:^(NSDictionary *dic) {
        [weakself.tableView endLoadingData];
        [weakself.tableView.mj_header endRefreshing];
        
    } error:^(NSError *error) {
        [weakself.tableView endLoadingData];
        [weakself.tableView.mj_header endRefreshing];
        ERRORMSG
    }];
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.backgroundColor = MainBg;
    self.navigationItem.title = @"最近";
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc]init];
    CJWeak(self)
    [self.tableView initDataWithTitle:@"无更新" descriptionText:@"最近没有更新过笔记..." didTapButton:^{
        [weakself getData];
    }];
    self.tableView.mj_header = [MJRefreshGifHeader cjRefreshWithPullType:CJPullTypeNormal header:^{
        [weakself getData];
    }];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeAccount:) name:LOGIN_ACCOUT_NOTI object:nil];
    
    [self.tableView endLoadingData];
    [self.tableView.mj_header beginRefreshing];
    [self.tableView registerNib:[UINib nibWithNibName:@"CJNoteCell" bundle:nil] forCellReuseIdentifier:@"cell"];

    self.tableView.rowHeight = [CJNoteCell height];
}

-(void)changeAccount:(NSNotification *)noti{
    self.notes = [self recentNotes];
    [self.tableView reloadData];
}


- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    static NSString *cellId = @"cell";
    CJNoteCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell){
        cell = [CJNoteCell xibWithNoteCell];
    }
    CJNote *note = self.notes[indexPath.row];
    if ([note isInvalidated]){
        return cell;
    }
    [cell setUI:note];
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.notes.count;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CJContentVC *contentVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"contentVC"];
    CJNote *note = self.notes[indexPath.row];
    contentVC.uuid = note.uuid;
    contentVC.noteTitle = note.title;
    contentVC.isMe = YES;
    [self.navigationController pushViewController:contentVC animated:YES];
}


@end
