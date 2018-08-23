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
        weakself.tableView.emtyHide = NO;
        [weakself.tableView endLoadingData];
        [weakself.tableView.mj_header endRefreshing];
    } failure:^(NSError *error) {
        [weakself.tableView endLoadingData];
        [weakself.tableView.mj_header endRefreshing];
    }];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"回收站";
    
    self.rt_navigationController.tabBarItem.title = @"回收站";
    self.rt_navigationController.tabBarItem.image = [UIImage imageNamed:@"垃圾灰"];
    self.rt_navigationController.tabBarItem.selectedImage = [UIImage imageNamed:@"垃圾蓝"];
    self.tableView.tableFooterView = [[UIView alloc]init];
    self.tableView.mj_header = [MJRefreshGifHeader cjRefreshHeader:^{
        [self getData];
    }];
    [self.tableView initDataWithTitle:@"无笔记..." descriptionText:@"空空如也..." didTapButton:^{
        [self getData];
    }];
    self.tableView.emtyHide = YES;
    [self.tableView.mj_header beginRefreshing];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"垃圾侧"] style:UIBarButtonItemStylePlain target:self action:@selector(clearBtnClick)];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeAccount:) name:LOGIN_ACCOUT_NOTI object:nil];
    
    
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
    CJProgressHUD *hud = [CJProgressHUD cjShowWithPosition:CJProgressHUDPositionBothExist timeOut:0 withText:@"删除中..." withImages:nil];
    CJUser *user = [CJUser sharedUser];
    [CJAPI clearTrashWithParams:@{@"email":user.email} success:^(NSDictionary *dic) {
        [weakself.notes removeAllObjects];
        
        [weakself.tableView reloadData];
        [hud cjShowSuccess:@"已清空"];
    } failure:^(NSError *error) {
        [hud cjShowError:@"清空失败!"];

    }];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.notes.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellId = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    cell.textLabel.text = self.notes[indexPath.row].title;
    cell.imageView.image = [UIImage imageNamed:@"笔记灰"];
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
        CJProgressHUD *hud = [CJProgressHUD cjShowWithPosition:CJProgressHUDPositionNavigationBar timeOut:0 withText:@"删除中..." withImages:nil];
        [CJAPI deleteNote4EverWithParams:@{@"note_uuid":note.uuid} success:^(NSDictionary *dic) {
            [weakself.notes removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
            [hud cjShowSuccess:@"删除成功"];
        } failure:^(NSError *error) {
            [hud cjShowError:@"删除失败!"];
        }];
    }];
    UITableViewRowAction *move = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"移动" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        CJMoveNoteVC *vc = [[CJMoveNoteVC alloc]init];
        vc.bookTitle = @"";
        CJNote *note = self.notes[indexPath.row];
        vc.selectIndexPath = ^(NSString *book_uuid){
            CJProgressHUD *hud = [CJProgressHUD cjShowWithPosition:CJProgressHUDPositionNavigationBar timeOut:0 withText:@"移动中..." withImages:nil];
            [CJAPI moveNoteWithParams:@{@"note_uuid":note.uuid,@"book_uuid":book_uuid} success:^(NSDictionary *dic) {
                [weakself.notes removeObjectAtIndex:indexPath.row];
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
                [hud cjShowSuccess:@"移动成功"];
            } failure:^(NSError *error) {
                [hud cjShowError:@"移动失败!"];
            }];
        };
        vc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        [weakself presentViewController:vc animated:YES completion:nil];
        
    }];
    move.backgroundColor = BlueBg;
    return @[del,move];
    
    
}



@end
