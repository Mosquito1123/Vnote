//
//  CJRecycleBinVC.m
//  VNote
//
//  Created by ccj on 2018/8/3.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import "CJRecycleBinVC.h"
#import "CJMoveNoteVC.h"
#import "CJContentVC.h"
#import "CJNoteCell.h"
@interface CJRecycleBinVC ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet CJTableView *tableView;
@property(nonatomic,strong) NSMutableArray <CJNote *> *notes;
@end

@implementation CJRecycleBinVC
-(NSMutableArray<CJNote *> *)notes{
    if (!_notes){
        _notes = [NSMutableArray array];
    }
    return _notes;
}

-(void)getData{
    CJUser *user = [CJUser sharedUser];
    CJWeak(self)
    [CJAPI getTrashNotesWithParams:@{@"email":user.email} success:^(NSDictionary *dic) {
        NSMutableArray <CJNote *>*arrayM = [NSMutableArray array];
        if ([dic[@"status"] integerValue] == 0){
            for (NSDictionary *d in dic[@"trash_notes"]) {
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
    [self addAvtar];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"回收站";
    self.tableView.backgroundColor = MainBg;
    self.rt_navigationController.tabBarItem.title = @"回收站";
    self.rt_navigationController.tabBarItem.image = [UIImage imageNamed:@"垃圾灰"];
    self.rt_navigationController.tabBarItem.selectedImage = [UIImage imageNamed:@"垃圾蓝"];
    self.tableView.tableFooterView = [[UIView alloc]init];
    self.tableView.mj_header = [MJRefreshGifHeader cjRefreshWithPullType:CJPullTypeNormal header:^{
        [self getData];
    }];
    CJWeak(self)
    [self.tableView initDataWithTitle:@"无笔记..." descriptionText:@"空空如也..." didTapButton:^{
        [weakself getData];
    }];
    
    [self.tableView.mj_header beginRefreshing];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"垃圾侧"] style:UIBarButtonItemStylePlain target:self action:@selector(clearBtnClick)];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeAccount:) name:LOGIN_ACCOUT_NOTI object:nil];
    [self.tableView registerNib:[UINib nibWithNibName:@"CJNoteCell" bundle:nil] forCellReuseIdentifier:@"cell"];
    
    
}

-(void)changeAccount:(NSNotification *)noti{
    
    self.tableView.emtyHide = YES;
    [self.tableView.mj_header beginRefreshing];
    
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)clearBtnClick{
    
    CJWeak(self)
    CJProgressHUD *hud = [CJProgressHUD cjShowInView:self.view timeOut:TIME_OUT withText:@"加载中..." withImages:nil];
    CJUser *user = [CJUser sharedUser];
    [CJAPI clearTrashWithParams:@{@"email":user.email} success:^(NSDictionary *dic) {
        [weakself.notes removeAllObjects];
        
        [weakself.tableView reloadData];
        [hud cjShowSuccess:@"已清空"];
    } failure:^(NSError *error) {
        [hud cjShowError:net101code];
    }];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.notes.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellId = @"cell";
    CJNoteCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell){
        cell = [CJNoteCell xibWithNoteCell];
    }
    cell.titleL.text = self.notes[indexPath.row].title;
    cell.updateTimeL.text = [NSDate cjDateSince1970WithSecs:self.notes[indexPath.row].updated_at formatter:@"YYYY/MM/dd"];
    return cell;
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

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
    
}

-(NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    CJWeak(self)
    UITableViewRowAction *del = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        CJNote *note = self.notes[indexPath.row];
        CJProgressHUD *hud = [CJProgressHUD cjShowInView:self.view timeOut:TIME_OUT withText:@"删除中..." withImages:nil];

        [CJAPI deleteNote4EverWithParams:@{@"note_uuid":note.uuid} success:^(NSDictionary *dic) {
            [weakself.notes removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
            [hud cjShowSuccess:@"删除成功"];
            [weakself.tableView reloadData];
        } failure:^(NSError *error) {
            [hud cjShowError:net101code];
        }];
    }];
    UITableViewRowAction *move = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"移动" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        CJMoveNoteVC *vc = [[CJMoveNoteVC alloc]init];
        CJMainNaVC *nav = [[CJMainNaVC alloc]initWithRootViewController:vc];
        CJNote *note = self.notes[indexPath.row];
        vc.selectIndexPath = ^(NSString *book_uuid){
            CJProgressHUD *hud = [CJProgressHUD cjShowInView:self.view timeOut:TIME_OUT withText:@"移动中..." withImages:nil];

            [CJAPI moveNoteWithParams:@{@"note_uuid":note.uuid,@"book_uuid":book_uuid} success:^(NSDictionary *dic) {
                [weakself.notes removeObjectAtIndex:indexPath.row];
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
                [hud cjShowSuccess:@"移动成功"];
                [weakself.tableView reloadData];
                note.book_uuid = book_uuid;
                [CJRlm addObject:note];
                
                
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTE_CHANGE_NOTI object:nil];
            } failure:^(NSError *error) {
                [hud cjShowError:net101code];
            }];
        };
        nav.modalPresentationStyle = UIModalPresentationOverFullScreen;
        [weakself presentViewController:nav animated:YES completion:nil];
        
    }];
    move.backgroundColor = BlueBg;
    return @[del,move];
    
    
}



@end
