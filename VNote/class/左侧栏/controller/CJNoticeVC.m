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
@property(nonatomic,strong) NSMutableArray <CJNote *> *notes;
@end

@implementation CJNoticeVC

-(NSMutableArray<CJNote *> *)notes{
    if (!_notes){
        _notes = [NSMutableArray array];
    }
    return _notes;
}

-(void)getData{
    
    CJWeak(self)
    [CJAPI getNoticesSuccess:^(NSDictionary *dic) {
        NSMutableArray <CJNote *>*arrayM = [NSMutableArray array];
        if ([dic[@"status"] integerValue] == 0){
            for (NSDictionary *d in dic[@"notices"]) {
                CJNote *note = [CJNote noteWithDict:d];
                [arrayM addObject:note];
            }
            weakself.notes = arrayM;
            [weakself.tableView reloadData];
        }
        
        [weakself.tableView endLoadingData];
        [weakself.tableView.mj_header endRefreshing];
    } failure:^(NSError *error) {
        [weakself.tableView endLoadingData];
        [weakself.tableView.mj_header endRefreshing];
    }];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = MainBg;
    self.navigationItem.title = @"公告";
    self.rt_navigationController.tabBarItem.title = @"公告";
    self.rt_navigationController.tabBarItem.image = [UIImage imageNamed:@"公告灰"];
    self.rt_navigationController.tabBarItem.selectedImage = [UIImage imageNamed:@"公告蓝"];
    [self addAvtar];
    CJWeak(self)
    [self.tableView initDataWithTitle:@"无公告" descriptionText:@"" didTapButton:^{
        [weakself getData];
    }];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.mj_header = [MJRefreshGifHeader cjRefreshWithPullType:CJPullTypeNormal header:^{
        [weakself getData];
    }];
    [self.tableView.mj_header beginRefreshing];
    [self.tableView registerNib:[UINib nibWithNibName:@"CJNoteCell" bundle:nil] forCellReuseIdentifier:@"cell"];
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellID = @"cell";
    CJNoteCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    if (!cell){
        cell = [CJNoteCell xibWithNoteCell];
    }
    CJNote *note = self.notes[indexPath.row];
    cell.titleL.text = note.title;
    cell.updateTimeL.text = [NSDate cjDateSince1970WithSecs:note.updated_at formatter:@"yyyy/MM/dd"];
    cell.leftImageView.image = [UIImage imageNamed:@"公告蓝"];
    return cell;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.notes.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CJNote *n = self.notes[indexPath.row];
    CJContentVC *vc = [[CJContentVC alloc]init];
    vc.isMe = NO;
    vc.uuid = n.uuid;
    vc.noteTitle = n.title;
    [self.navigationController pushViewController:vc animated:YES];
}





@end
