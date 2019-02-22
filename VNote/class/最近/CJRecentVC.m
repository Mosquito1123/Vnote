//
//  CJRecentVC.m
//  VNote
//
//  Created by ccj on 2018/7/31.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import "CJRecentVC.h"
#import "CJContentVC.h"
@interface CJRecentVC ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet CJTableView *tableView;
@property(nonatomic,strong) NSMutableArray <CJNote *> *notes;
@end

@implementation CJRecentVC

-(NSMutableArray *)recentNotes{
    NSMutableArray *notes = [NSMutableArray array];
    CJUser *user = [CJUser sharedUser];
    RLMRealm *rlm = [CJRlm cjRlmWithName:user.email];
    RLMResults *sets = [CJNote allObjectsInRealm:rlm];
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
    [CJAPI getRecentNotesWithParams:@{@"email":user.email} success:^(NSDictionary *dic) {
        NSMutableArray *array = [NSMutableArray array];
        if ([dic[@"status"] integerValue] == 0){
            for (NSDictionary *d in dic[@"recent_notes"]) {
                CJNote *note = [CJNote noteWithDict:d];
                [array addObject:note];
            }
            weakself.notes = array;
        }
        [weakself.tableView.mj_header endRefreshing];
        [weakself.tableView reloadData];
        [weakself.tableView endLoadingData];
    } failure:^(NSError *error) {
        [weakself.tableView endLoadingData];
        [weakself.tableView.mj_header endRefreshing];
    }];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.backgroundColor = MainBg;
    self.navigationItem.title = @"最近";
    self.rt_navigationController.tabBarItem.title = @"最近";
    self.rt_navigationController.tabBarItem.image = [UIImage imageNamed:@"最近灰"];
    self.rt_navigationController.tabBarItem.selectedImage = [UIImage imageNamed:@"最近蓝"];
    self.tableView.tableFooterView = [[UIView alloc]init];
    CJWeak(self)
    [self.tableView initDataWithTitle:@"无更新" descriptionText:@"最近没有更新过笔记..." didTapButton:^{
        [weakself getData];
    }];
    self.tableView.mj_header = [MJRefreshGifHeader cjRefreshWithPullType:CJPullTypeNormal header:^{
        [weakself getData];
    }];
    [self.tableView.mj_header beginRefreshing];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeAccount:) name:LOGIN_ACCOUT_NOTI object:nil];
}
-(void)changeAccount:(NSNotification *)noti{
    self.notes = [self recentNotes];
    [self.tableView reloadData];
}


- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    static NSString *cellId = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
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
    contentVC.uuid = note.uuid;
    contentVC.noteTitle = note.title;
    contentVC.isMe = YES;
    [self.navigationController pushViewController:contentVC animated:YES];
}


@end
