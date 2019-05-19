//
//  CJNoticeVC.m
//  VNote
//
//  Created by ccj on 2019/3/13.
//  Copyright © 2019 ccj. All rights reserved.
//

#import "CJNoticeVC.h"
#import "CJContentVC.h"
#import "CJNoteCell.h"
@interface CJNoticeVC ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet CJTableView *tableView;
@property(nonatomic,strong) NSMutableArray <CJNotice *> *notes;
@end

@implementation CJNoticeVC
-(NSMutableArray *)reGetRlmNotes{
    RLMRealm *rlm = [CJRlm shareRlm];
    return [CJNotice cjAllObjectsInRlm:rlm];
}


-(NSMutableArray<CJNotice *> *)notes{
    if (!_notes){
        _notes = [CJNotice cjAllObjectsInRlm:[CJRlm shareRlm]];
    }
    return _notes;
}

-(void)getData{
    
    CJWeak(self)
    [CJAPI requestWithAPI:API_GET_NOTICES params:nil success:^(NSDictionary *dic) {
        NSMutableArray <CJNotice *>*arrayM = [NSMutableArray array];
        
        for (NSDictionary *d in dic[@"notices"]) {
            CJNotice *note = [CJNotice noticeWithDict:d];
            [arrayM addObject:note];
        }
        
        [CJRlm deleteObjects:weakself.notes];
        [CJRlm addObjects:arrayM];
        weakself.notes = arrayM;
        [weakself.tableView reloadData];
        [weakself.tableView endLoadingData];
        [weakself.tableView.mj_header endRefreshing];
    } failure:^(NSDictionary *dic) {
        [weakself.tableView endLoadingData];
        [weakself.tableView.mj_header endRefreshing];
    } error:^(NSError *error) {
        [weakself.tableView endLoadingData];
        [weakself.tableView.mj_header endRefreshing];
        ERRORMSG
    }];
    
}
-(void)changeAcountNoti:(NSNotification *)noti{
    
    self.notes = [self reGetRlmNotes];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSNotificationCenter *defaulCenter = [NSNotificationCenter defaultCenter];
    [defaulCenter addObserver:self selector:@selector(changeAcountNoti:) name:LOGIN_ACCOUT_NOTI object:nil];
    self.view.backgroundColor = MainBg;
    self.navigationItem.title = @"公告";
    self.rt_navigationController.tabBarItem.title = @"公告";
    self.rt_navigationController.tabBarItem.image = [UIImage imageNamed:@"公告灰"];
    self.rt_navigationController.tabBarItem.selectedImage = [UIImage imageNamed:@"公告蓝"];
    [self addAvtar];
    CJWeak(self)
    [self.tableView initDataWithTitle:@"无公告" descriptionText:@"暂时没有系统公告..." didTapButton:^{
        [weakself getData];
    }];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.mj_header = [MJRefreshGifHeader cjRefreshWithPullType:CJPullTypeNormal header:^{
        [weakself getData];
    }];
//    [self.tableView.mj_header beginRefreshing];
    [self.tableView registerNib:[UINib nibWithNibName:@"CJNoteCell" bundle:nil] forCellReuseIdentifier:@"cell"];
    self.tableView.rowHeight = [CJNoteCell height];
    self.tableView.emtyHide = NO;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellID = @"cell";
    CJNoteCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    if (!cell){
        cell = [CJNoteCell xibWithNoteCell];
    }
    CJNotice *note = self.notes[indexPath.row];
    [cell setUI:note];
    return cell;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.notes.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CJNotice *n = self.notes[indexPath.row];
    if ([n isInvalidated]) return;
    CJContentVC *vc = [[CJContentVC alloc]init];
    vc.isMe = NO;
    vc.note = n;
    vc.isNotice = 1;
    [self.navigationController pushViewController:vc animated:YES];
}





@end
