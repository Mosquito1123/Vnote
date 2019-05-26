//
//  CJUpdatesVC.m
//  VNote
//
//  Created by ccj on 2019/5/26.
//  Copyright © 2019 ccj. All rights reserved.
//

#import "CJUpdatesVC.h"
#import "CJNoteCell.h"
#import "CJContentVC.h"
@interface CJUpdatesVC ()
@property (weak, nonatomic) IBOutlet CJTableView *tableView;

@property(nonatomic,strong) NSMutableArray <CJNotice *> *notes;
@end

@implementation CJUpdatesVC


-(NSMutableArray<CJNotice *> *)notes{
    if (!_notes){
        _notes = [NSMutableArray array];
    }
    return _notes;
}

-(void)getData{
    
    CJWeak(self)
    [CJAPI requestWithAPI:API_GET_UPDATES params:nil success:^(NSDictionary *dic) {
        NSMutableArray <CJNotice *>*arrayM = [NSMutableArray array];
        
        for (NSDictionary *d in dic[@"notices"]) {
            CJNotice *note = [CJNotice noticeWithDict:d];
            [arrayM addObject:note];
        }
        weakself.notes = arrayM;
        NSLog(@"%@",weakself.notes);
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

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"更新日志";
    
    self.view.backgroundColor = MainBg;
    CJWeak(self)
    [self.tableView initDataWithTitle:@"无更新" descriptionText:@"暂时没有系统更新..." didTapButton:^{
        [weakself getData];
    }];
    self.tableView.mj_header = [MJRefreshGifHeader cjRefreshWithPullType:CJPullTypeNormal header:^{
        [weakself getData];
    }];
    [self.tableView.mj_header beginRefreshing];
    self.tableView.emtyHide = NO;
    self.tableView.rowHeight = [CJNoteCell height];
    [self.tableView registerNib:[UINib nibWithNibName:@"CJNoteCell" bundle:nil] forCellReuseIdentifier:@"cell"];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger row = indexPath.row;
    static NSString *cellID = @"cell";
    CJNoteCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    if (!cell){
        cell = [CJNoteCell xibWithNoteCell];
    }
    CJNotice *note = self.notes[row];
    if ([note isInvalidated]) return cell;
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

