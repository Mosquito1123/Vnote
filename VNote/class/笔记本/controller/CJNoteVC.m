//
//  CJNotebookVC.m
//  VNote
//
//  Created by ccj on 2018/6/3.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import "CJNoteVC.h"
#import "CJNote.h"
#import "CJContentVC.h"
#import "CJBook.h"
#import "CJNoteSearchVC.h"
#import "CJMoveNoteVC.h"
#import "CJAddNoteVC.h"
#import "CJNoteCell.h"
@interface CJNoteVC ()<UITableViewDelegate,UITableViewDataSource,DZNEmptyDataSetDelegate,DZNEmptyDataSetSource>

@property (strong, nonatomic) UIBarButtonItem *deleteBtn;
@property (strong, nonatomic) UIBarButtonItem *moveBtn;
@property (weak, nonatomic) IBOutlet CJTableView *tableView;
@property(nonatomic,strong) NSMutableArray<CJNote *> *noteArrM;
@property (nonatomic,strong) UIBarButtonItem *backItem;
@property(nonatomic,assign,getter=isEdit) BOOL edit;

@property(nonatomic,strong) NSMutableArray<NSIndexPath *> *selectIndexPaths;
@property(nonatomic,strong) UIBarButtonItem *editItem;

@end

@implementation CJNoteVC
-(UIBarButtonItem *)deleteBtn{
    if (!_deleteBtn){
        _deleteBtn = [[UIBarButtonItem alloc]initWithTitle:@"删除" style:UIBarButtonItemStylePlain target:self action:@selector(deleteNotes)];
        _deleteBtn.enabled = NO;
    }
    return _deleteBtn;
}

-(UIBarButtonItem *)moveBtn{
    if (!_moveBtn){
        _moveBtn = [[UIBarButtonItem alloc]initWithTitle:@"移动" style:UIBarButtonItemStylePlain target:self action:@selector(moveNotes)];
        _moveBtn.enabled = NO;
    }
    return _moveBtn;
}



-(UIBarButtonItem *)editItem{
    if (!_editItem){
        _editItem = [[UIBarButtonItem alloc]initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(edit)];
    }
    return _editItem;
}


-(NSMutableArray <NSIndexPath *>*)selectIndexPaths{
    if (!_selectIndexPaths){
        _selectIndexPaths = [NSMutableArray array];
    }
    return _selectIndexPaths;
}
- (void)deleteNotes {
    if (!self.selectIndexPaths.count) return ;
    CJUser *user = [CJUser sharedUser];
    NSMutableArray *noteUUids = [NSMutableArray array];
    NSMutableArray<CJNote *> *delNotes = [NSMutableArray array];
    for (NSIndexPath *i in self.selectIndexPaths) {
        [noteUUids addObject:self.noteArrM[i.row].uuid];
        [delNotes addObject:self.noteArrM[i.row]];
    }
    CJWeak(self)
    NSString *noteUUidsStr = [[NSString alloc]initWithData:[NSJSONSerialization dataWithJSONObject:noteUUids options:0 error:nil] encoding:NSUTF8StringEncoding];
    CJProgressHUD *hud = [CJProgressHUD cjShowInView:self.view timeOut:TIME_OUT withText:@"删除中..." withImages:nil];
    [CJAPI requestWithAPI:API_DEL_NOTES params:@{@"email":user.email,@"note_uuids":noteUUidsStr} success:^(NSDictionary *dic) {
        [hud cjShowSuccess:@"删除成功"];
        [weakself.noteArrM removeObjectsInArray:delNotes];
        [weakself.tableView deleteRowsAtIndexPaths:weakself.selectIndexPaths withRowAnimation:UITableViewRowAnimationLeft];
        weakself.edit = NO;
        [CJRlm deleteObjects:delNotes];
    } failure:^(NSDictionary *dic) {
        [hud cjShowError:dic[@"msg"]];
    } error:^(NSError *error) {
        [hud cjShowError:net101code];
    }];

}
- (void)moveNotes{
    
    if (!self.selectIndexPaths.count) return ;
    NSMutableArray *noteUUids = [NSMutableArray array];
    NSMutableArray<CJNote *> *moveNotes = [NSMutableArray array];
    for (NSIndexPath *i in self.selectIndexPaths) {
        [noteUUids addObject:self.noteArrM[i.row].uuid];
        [moveNotes addObject:self.noteArrM[i.row]];
    }
    NSString *noteUUidsStr = [[NSString alloc]initWithData:[NSJSONSerialization dataWithJSONObject:noteUUids options:0 error:nil] encoding:NSUTF8StringEncoding];
    CJMoveNoteVC *vc = [[CJMoveNoteVC alloc]init];
    CJMainNaVC *nav = [[CJMainNaVC alloc]initWithRootViewController:vc];
    vc.bookTitle = self.book.name;
    CJWeak(self)
    vc.selectIndexPath = ^(NSString *book_uuid){
        CJUser *user = [CJUser sharedUser];
        CJProgressHUD *hud = [CJProgressHUD cjShowInView:weakself.view timeOut:TIME_OUT withText:@"移动中..." withImages:nil];
        [CJAPI requestWithAPI:API_MOVE_NOTES params:@{@"note_uuids":noteUUidsStr,@"book_uuid":book_uuid,@"email":user.email} success:^(NSDictionary *dic) {
            [hud cjShowSuccess:@"移动成功"];
            [weakself.noteArrM removeObjectsInArray:moveNotes];
            [weakself.tableView deleteRowsAtIndexPaths:weakself.selectIndexPaths withRowAnimation:UITableViewRowAnimationLeft];
            weakself.edit = NO;
            RLMRealm *rlm = [CJRlm shareRlm];
            [rlm transactionWithBlock:^{
                for (CJNote *n in moveNotes) {
                    n.book_uuid = book_uuid;
                }
                
            }];
        } failure:^(NSDictionary *dic) {
            [hud cjShowError:dic[@"msg"]];
        } error:^(NSError *error) {
            [hud cjShowError:net101code];
        }];
    };
    nav.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:nav animated:YES completion:nil];
    
}

-(void)setEdit:(BOOL)edit{
    
    self.tableView.editing = edit;
    self.tableView.allowsMultipleSelection = edit;
    CJWeak(self)
    [UIView animateWithDuration:0.3 animations:^{
        [weakself.view layoutIfNeeded];
    }];
    
    if(edit){
        
        UIImpactFeedbackGenerator*impactLight = [[UIImpactFeedbackGenerator alloc]initWithStyle:UIImpactFeedbackStyleMedium];
        [impactLight impactOccurred];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
        UIBarButtonItem *selectAll = [[UIBarButtonItem alloc]initWithTitle:@"全选" style:UIBarButtonItemStylePlain target:self action:@selector(selectAll:)];
        self.navigationItem.rightBarButtonItems = @[selectAll];

    }
    else
    {
        self.navigationItem.leftBarButtonItem = self.backItem;
        self.navigationItem.rightBarButtonItem = self.editItem;
        self.deleteBtn.enabled = self.moveBtn.enabled = NO;
    }
    _edit = edit;
    self.navigationController.toolbarHidden = !edit;
    
}

-(NSMutableArray <CJNote *>*)noteArrM{
    if(!_noteArrM){
        _noteArrM = [NSMutableArray array];
        NSMutableArray *notes;
        RLMRealm *rlm = [CJRlm shareRlm];
        if ([self.book isInvalidated]){
            NSLog(@"----");
        };
        if ([self.book.name isEqualToString:@"All Notes"]){
            notes = [CJNote cjAllObjectsInRlm:rlm];
        }else if([self.book.name isEqualToString:@"Recents"]){
            
        }else{
            notes = [CJNote cjObjectsInRlm:rlm where:[NSString stringWithFormat:@"book_uuid = '%@'",self.book.uuid]];
        }
        _noteArrM = [CJTool orderObjects:notes withKey:@"title"];
    }
    
    return _noteArrM;
}

-(void)getData{
    CJUser *user = [CJUser sharedUser];
    if (!user.nickname){
        return ;
    }
    CJWeak(self)
    [CJAPI requestWithAPI:API_BOOK_DETAIL params:@{@"email":user.email,@"book_uuid":weakself.book.uuid} success:^(NSDictionary *dic) {
        NSArray *res = dic[@"notes"];
        NSMutableArray *notes = [NSMutableArray array];
        for (NSDictionary *dic in res){
            CJNote *note = [CJNote noteWithDict:dic];
            [notes addObject:note];
        }
        [CJRlm deleteObjects:weakself.noteArrM];
        
        [CJRlm addObjects:notes];
        weakself.noteArrM = [CJTool orderObjects:notes withKey:@"title"];
        [weakself.tableView.mj_header endRefreshing];
        [weakself.tableView reloadData];
        [weakself.tableView endLoadingData];
    } failure:^(NSDictionary *dic) {
        [weakself.tableView.mj_header endRefreshing];
        [weakself.tableView endLoadingData];
    } error:^(NSError *error) {
        [weakself.tableView.mj_header endRefreshing];
        [weakself.tableView endLoadingData];
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = self.book.name;
    
    CJWeak(self)
    self.tableView.mj_header = [MJRefreshGifHeader cjRefreshWithPullType:CJPullTypeNormal header:^{
        [weakself getData];

    }];
    
    [self.tableView initDataWithTitle:@"无笔记" descriptionText:@"当前笔记本下无笔记..." didTapButton:^{
        [weakself getData];
    }];

    self.backItem = self.navigationItem.leftBarButtonItem;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noteChange:) name:NOTE_CHANGE_NOTI object:nil];
    self.edit = NO;
    self.tableView.emtyHide = NO;  //
    [self.tableView registerNib:[UINib nibWithNibName:@"CJNoteCell" bundle:nil] forCellReuseIdentifier:@"cell"];
    self.tableView.rowHeight = [CJNoteCell height];
    
    UIBarButtonItem *flexItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    self.toolbarItems = @[self.moveBtn,flexItem,self.deleteBtn];
    self.navigationController.toolbar.tintColor = BlueBg;
    
}

-(void)noteChange:(NSNotification *)noti{
    self.noteArrM = nil;
    [self.tableView reloadData];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
}



-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CJWeak(self)
    CJNoteCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (!cell){
        cell = [CJNoteCell xibWithNoteCell];
    }
    NSInteger row = indexPath.row;
    CJNote *note = self.noteArrM[row];
    if (note.isInvalidated){
        return cell;
    }
    [cell setUI:note];
    cell.accessoryView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"more"]];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithCjGestureRecognizer:^(UIGestureRecognizer *gesture) {
        [cell showSwipe:MGSwipeDirectionRightToLeft animated:YES];
        return;
    }];
    cell.accessoryView.userInteractionEnabled = YES;
    [cell.accessoryView addGestureRecognizer:tap];
    MGSwipeButton *del = [MGSwipeButton buttonWithTitle:@"删除" backgroundColor:[UIColor redColor] callback:^BOOL(MGSwipeTableCell * _Nonnull cell) {
        CJUser *user = [CJUser sharedUser];
        CJNote *note = weakself.noteArrM[indexPath.row];
        CJProgressHUD *hud = [CJProgressHUD cjShowInView:weakself.view timeOut:TIME_OUT withText:@"删除中..." withImages:nil];
        
        [CJAPI requestWithAPI:API_DEL_NOTE params:@{@"email":user.email,@"note_uuid":note.uuid} success:^(NSDictionary *dic) {
            [weakself.noteArrM removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
            [hud cjShowSuccess:@"删除成功"];
            [CJRlm deleteObject:note];
        } failure:^(NSDictionary *dic) {
            [hud cjShowError:dic[@"msg"]];
        } error:^(NSError *error) {
            [hud cjShowError:net101code];
        }];
        return YES;
    }];
    
    MGSwipeButton *move = [MGSwipeButton buttonWithTitle:@"移动" backgroundColor:BlueBg callback:^BOOL(MGSwipeTableCell * _Nonnull cell) {
        CJMoveNoteVC *vc = [[CJMoveNoteVC alloc]init];
        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:vc];
        
        vc.bookTitle = weakself.book.name;
        
        vc.selectIndexPath = ^(NSString *book_uuid){
            CJNote *note = weakself.noteArrM[indexPath.row];
            CJProgressHUD *hud = [CJProgressHUD cjShowInView:weakself.view timeOut:TIME_OUT withText:@"移动中..." withImages:nil];
            [CJAPI requestWithAPI:API_MOVE_NOTE params:@{@"note_uuid":note.uuid,@"book_uuid":book_uuid} success:^(NSDictionary *dic) {
                [[CJRlm shareRlm] transactionWithBlock:^{
                    note.book_uuid = book_uuid;
                }];
                [weakself.noteArrM removeObjectAtIndex:indexPath.row];
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
                [hud cjShowSuccess:@"移动成功"];
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
        CJNote *n = weakself.noteArrM[indexPath.row];
        pasteB.string = NOTE_DETAIL_WEB_LINK(n.uuid);
        [CJProgressHUD cjShowSuccessWithPosition:CJProgressHUDPositionNavigationBar withText:@"复制成功"];
        return YES;
    }];
    cell.rightButtons = @[del,move,link];
    UILongPressGestureRecognizer *ges = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressCell:)];
    
    cell.userInteractionEnabled = YES;
    [cell addGestureRecognizer:ges];
    return cell;
}

-(void)edit{
    if (self.isEdit) return;
    self.edit = YES;
}

-(void)longPressCell:(UIGestureRecognizer *)ges{
    
    if (self.isEdit) return;
    self.edit = YES;
    UITableViewCell *cell = (UITableViewCell *)ges.view;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    [self.selectIndexPaths addObject:indexPath];
    self.deleteBtn.enabled = self.moveBtn.enabled = YES;
}

-(void)cancel{
    if (!self.isEdit) return;
    self.edit = NO;
}
// 全选
-(void)selectAll:(UIBarButtonItem *)sender{
    [self.selectIndexPaths removeAllObjects];
    if ([sender.title isEqualToString:@"全选"]){
        for (NSInteger i = 0;i < self.noteArrM.count;i++) {
            NSIndexPath *indexpath = [NSIndexPath indexPathForRow:i inSection:0];
            [self.tableView selectRowAtIndexPath:indexpath animated:YES scrollPosition:UITableViewScrollPositionBottom];
            [self.selectIndexPaths addObject:indexpath];
        }
        sender.title = @"取消全选";
    }
    else{
        for (NSInteger i = 0;i < self.noteArrM.count;i++) {
            NSIndexPath *indexpath = [NSIndexPath indexPathForRow:i inSection:0];
            [self.tableView deselectRowAtIndexPath:indexpath animated:YES];
        
        }
        sender.title = @"全选";
    }

}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.noteArrM.count;
}
-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView.editing) {
        if ([self.selectIndexPaths containsObject:indexPath]){
            [self.selectIndexPaths removeObject:indexPath];
        }else{
            [self.selectIndexPaths addObject:indexPath];
        }
        NSInteger count = self.selectIndexPaths.count;
        self.moveBtn.enabled = self.deleteBtn.enabled = count;
        return;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView.editing){
        if ([self.selectIndexPaths containsObject:indexPath]){
            [self.selectIndexPaths removeObject:indexPath];
        }else{
            [self.selectIndexPaths addObject:indexPath];
        }
        //
        NSInteger count = self.selectIndexPaths.count;
        self.moveBtn.enabled = self.deleteBtn.enabled = count;
        
        return ;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CJContentVC *contentVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"contentVC"];
    CJNote *note = self.noteArrM[indexPath.row];
    if (note.isInvalidated){
        self.noteArrM = nil;
        [self.tableView reloadData];
        return;
    }
    contentVC.note = note;
    contentVC.isMe = YES;
    
    [self.navigationController pushViewController:contentVC animated:YES];
}


-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (NSArray<id<UIPreviewActionItem>> *)previewActionItems {
    
    NSMutableArray *arrItem = [NSMutableArray array];
    
    UIPreviewAction *previewAction0 = [UIPreviewAction actionWithTitle:@"取消" style:UIPreviewActionStyleDestructive handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
        NSLog(@"didClickCancel");
    }];
    
    
    [arrItem addObjectsFromArray:@[previewAction0]];
    
    return arrItem;
}
@end
