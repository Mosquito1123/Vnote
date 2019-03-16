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
#import "CJNoteSearchView.h"
#import "CJMoveNoteVC.h"
#import "CJAddNoteVC.h"
@interface CJNoteVC ()<UITableViewDelegate,UITableViewDataSource,DZNEmptyDataSetDelegate,DZNEmptyDataSetSource,UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet CJTableView *tableView;
@property(nonatomic,strong) NSMutableArray<CJNote *> *noteArrM;
@property (nonatomic,strong) UIBarButtonItem *backItem;
@property(nonatomic,assign,getter=isEdit) BOOL edit;
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;
@property(nonatomic,strong) NSMutableArray<NSIndexPath *> *selectIndexPaths;
@property(nonatomic,strong) UIBarButtonItem *addNoteItem;
@end

@implementation CJNoteVC
-(UIBarButtonItem *)addNoteItem{
    if (!_addNoteItem){
        _addNoteItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"加笔记本"] style:UIBarButtonItemStylePlain target:self action:@selector(addNote)];
    }
    return _addNoteItem;
}
-(void)addNote{
    
    CJAddNoteVC *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"addNoteVC"];
    vc.bookTitle = self.book.name;
    CJMainNaVC *navc = [[CJMainNaVC alloc]initWithRootViewController:vc];
    navc.modalPresentationStyle = UIModalPresentationOverFullScreen;
    
    [self presentViewController:navc animated:YES completion:nil];
}
-(NSMutableArray <NSIndexPath *>*)selectIndexPaths{
    if (!_selectIndexPaths){
        _selectIndexPaths = [NSMutableArray array];
    }
    return _selectIndexPaths;
}
- (IBAction)deleteNotes:(id)sender {
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
    [CJAPI deleteNotesWithParams:@{@"email":user.email,@"note_uuids":noteUUidsStr} success:^(NSDictionary *dic) {
        [hud cjShowSuccess:@"删除成功"];
        [weakself.noteArrM removeObjectsInArray:delNotes];
        [weakself.tableView deleteRowsAtIndexPaths:weakself.selectIndexPaths withRowAnimation:UITableViewRowAnimationLeft];
        weakself.edit = NO;
        [CJRlm deleteObjects:delNotes];
    } failure:^(NSError *error) {
        [hud cjShowError:net101code];
    }];
    
}
- (IBAction)moveNotes:(id)sender {
    
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
        CJProgressHUD *hud = [CJProgressHUD cjShowInView:self.view timeOut:TIME_OUT withText:@"移动中..." withImages:nil];
        [CJAPI moveNotesWithParams:@{@"note_uuids":noteUUidsStr,@"book_uuid":book_uuid,@"email":user.email} success:^(NSDictionary *dic) {
            [hud cjShowSuccess:@"移动成功"];
            [weakself.noteArrM removeObjectsInArray:moveNotes];
            [weakself.tableView deleteRowsAtIndexPaths:weakself.selectIndexPaths withRowAnimation:UITableViewRowAnimationLeft];
            weakself.edit = NO;
            RLMRealm *rlm = [CJRlm cjRlmWithName:user.email];
            [rlm transactionWithBlock:^{
                for (CJNote *n in moveNotes) {
                    n.book_uuid = book_uuid;
                }
                
            }];
        } failure:^(NSError *error) {
            [hud cjShowError:net101code];
        }];
        
    };
    nav.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:nav animated:YES completion:nil];
    
}

-(void)setEdit:(BOOL)edit{
    
    self.tableView.editing = edit;
    self.tableView.allowsMultipleSelection = edit;
    self.toolBar.hidden = !edit;
    if(edit){
        UIImpactFeedbackGenerator*impactLight = [[UIImpactFeedbackGenerator alloc]initWithStyle:UIImpactFeedbackStyleMedium];
        [impactLight impactOccurred];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"全选" style:UIBarButtonItemStylePlain target:self action:@selector(selectAll:)];
        [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(-self.toolBar.cj_height);
        }];
        
    }
    else
    {
        [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(0);

        }];
        self.navigationItem.leftBarButtonItem = self.backItem;
        self.navigationItem.rightBarButtonItem = self.addNoteItem;
    }
    _edit = edit;
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    CJNoteSearchView *view = [CJNoteSearchView xibNoteSearchView];
    [self.navigationController.view addSubview:view];
    view.frame = self.navigationController.view.bounds;
    view.noteArrM = self.noteArrM;
    return NO;
}


-(NSMutableArray <CJNote *>*)noteArrM{
    if(!_noteArrM){
        _noteArrM = [NSMutableArray array];
        RLMResults <CJNote *>* notes;
        CJUser *user = [CJUser sharedUser];
        RLMRealm *rlm = [CJRlm cjRlmWithName:user.email];
        if ([self.book.name isEqualToString:@"All Notes"]){
            notes = [CJNote allObjectsInRealm:rlm];
        }else if([self.book.name isEqualToString:@"Recents"]){
            
        }else{
            notes = [CJNote objectsInRealm:rlm where:[NSString stringWithFormat:@"book_uuid = '%@'",self.book.uuid]];
        }
        for (CJNote *n in notes) {
            [_noteArrM addObject:n];
        }
        _noteArrM = [CJTool orderObjects:_noteArrM withKey:@"title"];
    }
    
    return _noteArrM;
}

-(void)getData{
    CJUser *user = [CJUser sharedUser];
    if (!user.nickname){
        return ;
    }
    CJWeak(self)
    [CJAPI bookDetailWithParams:@{@"email":user.email,@"book_uuid":weakself.book.uuid} success:^(NSDictionary *dic) {
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
    
    } failure:^(NSError *error) {
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
    self.navigationItem.rightBarButtonItem = self.addNoteItem;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noteChange:) name:NOTE_CHANGE_NOTI object:nil];
    self.edit = NO;
    self.tableView.emtyHide = NO;  //
}

-(void)noteChange:(NSNotification *)noti{
    self.noteArrM = nil;
    [self.tableView reloadData];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
}



-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (!cell){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    }
    NSInteger row = indexPath.row;
    CJNote *note = self.noteArrM[row];
    if (note.isInvalidated){
        self.noteArrM = nil;
        [self.tableView reloadData];
    }
    cell.textLabel.text = note.title;
    cell.detailTextLabel.text = [NSDate cjDateSince1970WithSecs:note.updated_at formatter:@"YYYY/MM/dd"];
    [cell.detailTextLabel setFont:[UIFont systemFontOfSize:10]];
    UILongPressGestureRecognizer *ges = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressCell)];
    cell.contentView.userInteractionEnabled = YES;
    [cell.contentView addGestureRecognizer:ges];
    cell.imageView.image = [UIImage imageNamed:@"笔记灰"];
    return cell;
}
-(void)longPressCell{
    if (self.isEdit) return;
    self.edit = YES;
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
        CJUser *user = [CJUser sharedUser];
        CJNote *note = weakself.noteArrM[indexPath.row];
        CJProgressHUD *hud = [CJProgressHUD cjShowInView:self.view timeOut:TIME_OUT withText:@"删除中..." withImages:nil];
        [CJAPI deleteNoteWithParams:@{@"email":user.email,@"note_uuid":note.uuid} success:^(NSDictionary *dic) {
            
            [weakself.noteArrM removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
            [hud cjShowSuccess:@"删除成功"];
            [CJRlm deleteObject:note];

        } failure:^(NSError *error) {
            
        }];
    }];
    
    UITableViewRowAction *move = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"移动" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        CJMoveNoteVC *vc = [[CJMoveNoteVC alloc]init];
        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:vc];
        
        vc.bookTitle = weakself.book.name;
        
        vc.selectIndexPath = ^(NSString *book_uuid){
            CJNote *note = weakself.noteArrM[indexPath.row];
            CJProgressHUD *hud = [CJProgressHUD cjShowInView:self.view timeOut:TIME_OUT withText:@"移动中..." withImages:nil];
            [CJAPI moveNoteWithParams:@{@"note_uuid":note.uuid,@"book_uuid":book_uuid} success:^(NSDictionary *dic) {
                [[CJRlm shareRlm] transactionWithBlock:^{
                    note.book_uuid = book_uuid;
                }];
                [weakself.noteArrM removeObjectAtIndex:indexPath.row];
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
                [hud cjShowSuccess:@"移动成功"];
                
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


- (NSArray<id<UIPreviewActionItem>> *)previewActionItems {
    
    NSMutableArray *arrItem = [NSMutableArray array];
    
    UIPreviewAction *previewAction0 = [UIPreviewAction actionWithTitle:@"取消" style:UIPreviewActionStyleDestructive handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
        NSLog(@"didClickCancel");
    }];
    
    
    [arrItem addObjectsFromArray:@[previewAction0]];
    
    return arrItem;
}
@end
