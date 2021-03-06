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
    [CJAPI requestWithAPI:API_GET_TRASH_NOTES params:@{@"email":user.email} success:^(NSDictionary *dic) {
        NSMutableArray *arrayM = [NSMutableArray array];
        for (NSDictionary *d in dic[@"trash_notes"]) {
            CJNote *note = [CJNote noteWithDict:d];
            [arrayM addObject:note];
        }
        weakself.notes = arrayM;
        [weakself.tableView reloadData];
        [weakself.tableView endLoadingData];
        [weakself.tableView.mj_header endRefreshing];
    } failure:^(NSDictionary *dic) {
        
    } error:^(NSError *error) {
        [weakself.tableView endLoadingData];
        [weakself.tableView.mj_header endRefreshing];
        ERRORMSG
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"回收站";
    self.tableView.backgroundColor = MainBg;
    self.tableView.tableFooterView = [[UIView alloc]init];
    CJWeak(self)
    self.tableView.mj_header = [MJRefreshGifHeader cjRefreshWithPullType:CJPullTypeNormal header:^{
        [weakself getData];
    }];
    
    [self.tableView initDataWithTitle:@"无笔记" descriptionText:@"空空如也..." didTapButton:^{
        [weakself getData];
    }];
    
    [self.tableView.mj_header beginRefreshing];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"垃圾侧"] style:UIBarButtonItemStylePlain target:self action:@selector(clearBtnClick)];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeAccount:) name:LOGIN_ACCOUT_NOTI object:nil];
    [self.tableView registerNib:[UINib nibWithNibName:@"CJNoteCell" bundle:nil] forCellReuseIdentifier:@"cell"];
    
    self.tableView.rowHeight = [CJNoteCell height];
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
    [CJAPI requestWithAPI:API_CLEAR_TRASH params:@{@"email":user.email} success:^(NSDictionary *dic) {
        [weakself.notes removeAllObjects];
        [weakself.tableView reloadData];
        [hud cjShowSuccess:@"已清空"];
    } failure:^(NSDictionary *dic) {
        [hud cjShowError:dic[@"msg"]];
    } error:^(NSError *error) {
        [hud cjShowError:net101code];
    }];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.notes.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CJWeak(self)
    static NSString *cellId = @"cell";
    CJNoteCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell){
        cell = [CJNoteCell xibWithNoteCell];
    }
    CJNote *note = self.notes[indexPath.row];
    if ([note isInvalidated])return cell;
    [cell setUI:note];
    
    cell.accessoryView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"more"]];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithCjGestureRecognizer:^(UIGestureRecognizer *gesture) {
        [cell showSwipe:MGSwipeDirectionRightToLeft animated:YES];
        return;
    }];
    cell.accessoryView.userInteractionEnabled = YES;
    [cell.accessoryView addGestureRecognizer:tap];
    
    MGSwipeButton *del = [MGSwipeButton buttonWithTitle:@"删除" backgroundColor:[UIColor redColor] callback:^BOOL(MGSwipeTableCell * _Nonnull cell) {
        CJNote *note = self.notes[indexPath.row];
        CJProgressHUD *hud = [CJProgressHUD cjShowInView:weakself.view timeOut:TIME_OUT withText:@"删除中..." withImages:nil];
        
        [CJAPI requestWithAPI:API_DEL_NOTE_4ERVER params:@{@"note_uuid":note.uuid} success:^(NSDictionary *dic) {
            [weakself.notes removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
            [hud cjShowSuccess:@"删除成功"];
            [weakself.tableView reloadData];
        } failure:^(NSDictionary *dic) {
            [hud cjShowError:dic[@"msg"]];
        } error:^(NSError *error) {
            [hud cjShowError:net101code];
        }];
        return YES;
    }];
    MGSwipeButton *move = [MGSwipeButton buttonWithTitle:@"移动" backgroundColor:BlueBg callback:^BOOL(MGSwipeTableCell * _Nonnull cell) {
        CJMoveNoteVC *vc = [[CJMoveNoteVC alloc]init];
        CJMainNaVC *nav = [[CJMainNaVC alloc]initWithRootViewController:vc];
        CJNote *note = self.notes[indexPath.row];
        vc.selectIndexPath = ^(NSString *book_uuid){
            CJProgressHUD *hud = [CJProgressHUD cjShowInView:weakself.view timeOut:TIME_OUT withText:@"移动中..." withImages:nil];
            [CJAPI requestWithAPI:API_MOVE_NOTE params:@{@"note_uuid":note.uuid,@"book_uuid":book_uuid} success:^(NSDictionary *dic) {
                [weakself.notes removeObjectAtIndex:indexPath.row];
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
                [hud cjShowSuccess:@"移动成功"];
                [weakself.tableView reloadData];
                note.book_uuid = book_uuid;
                [CJRlm addObject:note];
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTE_CHANGE_NOTI object:nil];
            } failure:^(NSDictionary *dic) {
                [hud cjShowError:dic[@"msg"]];
            } error:^(NSError *error) {
                [hud cjShowError:net101code];
            }];
            
        };
        nav.modalPresentationStyle = UIModalPresentationOverFullScreen;
        [weakself presentViewController:nav animated:YES completion:nil];
        return YES;
    }];
    MGSwipeButton *link = [MGSwipeButton buttonWithTitle:@"复制链接" backgroundColor:CopyColor callback:^BOOL(MGSwipeTableCell * _Nonnull cell) {
        UIPasteboard *pasteB = [UIPasteboard generalPasteboard];
        CJNote *n = weakself.notes[indexPath.row];
        pasteB.string = NOTE_DETAIL_WEB_LINK(n.uuid);
        [CJProgressHUD cjShowSuccessWithPosition:CJProgressHUDPositionNavigationBar withText:@"复制成功"];
        return YES;
    }];
    cell.rightButtons = @[del,move,link];
    
    return cell;
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
