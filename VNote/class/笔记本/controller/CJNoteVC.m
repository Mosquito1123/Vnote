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
@interface CJNoteVC ()<UITableViewDelegate,UITableViewDataSource,DZNEmptyDataSetDelegate,DZNEmptyDataSetSource,UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet CJTableView *tableView;
@property(nonatomic,strong) NSMutableArray<CJNote *> *noteArrM;
@property (nonatomic,strong) UIBarButtonItem *backItem;
@property(nonatomic,assign,getter=isEdit) BOOL edit;
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;
@property(nonatomic,strong) NSMutableArray<NSIndexPath *> *selectIndexPaths;

@end

@implementation CJNoteVC
-(NSMutableArray <NSIndexPath *>*)selectIndexPaths{
    if (!_selectIndexPaths){
        _selectIndexPaths = [NSMutableArray array];
    }
    return _selectIndexPaths;
}
- (IBAction)deleteNotes:(id)sender {
    AFHTTPSessionManager *manger = [AFHTTPSessionManager manager];
    CJUser *user = [CJUser sharedUser];
    NSMutableArray *noteUUids = [NSMutableArray array];
    NSMutableArray<CJNote *> *delNotes = [NSMutableArray array];
    for (NSIndexPath *i in self.selectIndexPaths) {
        [noteUUids addObject:self.noteArrM[i.row].uuid];
        [delNotes addObject:self.noteArrM[i.row]];
    }
    CJWeak(self)
    NSString *noteUUidsStr = [[NSString alloc]initWithData:[NSJSONSerialization dataWithJSONObject:noteUUids options:0 error:nil] encoding:NSUTF8StringEncoding];
    CJProgressHUD *hud = [CJProgressHUD cjShowWithPosition:CJProgressHUDPositionNavigationBar timeOut:0 withText:@"删除中..." withImages:nil];
    [manger POST:API_DEL_NOTES parameters:@{@"email":user.email,@"note_uuids":noteUUidsStr} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [hud cjShowSuccess:@"删除成功"];
        [weakself.noteArrM removeObjectsInArray:delNotes];
        [weakself.tableView deleteRowsAtIndexPaths:self.selectIndexPaths withRowAnimation:UITableViewRowAnimationLeft];
        weakself.edit = NO;
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [hud cjShowError:@"删除失败!"];
    }];
}
- (IBAction)moveNotes:(id)sender {
    
    NSMutableArray *noteUUids = [NSMutableArray array];
    NSMutableArray<CJNote *> *moveNotes = [NSMutableArray array];
    for (NSIndexPath *i in self.selectIndexPaths) {
        [noteUUids addObject:self.noteArrM[i.row].uuid];
        [moveNotes addObject:self.noteArrM[i.row]];
    }
    NSString *noteUUidsStr = [[NSString alloc]initWithData:[NSJSONSerialization dataWithJSONObject:noteUUids options:0 error:nil] encoding:NSUTF8StringEncoding];
    CJMoveNoteVC *vc = [[CJMoveNoteVC alloc]init];
    vc.bookTitle = self.book.name;
    CJWeak(self)
    vc.selectIndexPath = ^(NSString *book_uuid){
        CJUser *user = [CJUser sharedUser];
        AFHTTPSessionManager *manger = [AFHTTPSessionManager manager];
        CJProgressHUD *hud = [CJProgressHUD cjShowWithPosition:CJProgressHUDPositionNavigationBar timeOut:0 withText:@"移动中..." withImages:nil];
        [manger POST:API_MOVE_NOTES parameters:@{@"note_uuids":noteUUidsStr,@"book_uuid":book_uuid,@"email":user.email} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [hud cjShowSuccess:@"移动成功"];
            [weakself.noteArrM removeObjectsInArray:moveNotes];
            [weakself.tableView deleteRowsAtIndexPaths:self.selectIndexPaths withRowAnimation:UITableViewRowAnimationLeft];
            weakself.edit = NO;
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [hud cjShowError:@"移动失败!"];
        }];
    };
    [self presentViewController:vc animated:YES completion:nil];
    
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
        self.navigationItem.rightBarButtonItem = nil;
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
    }
    return _noteArrM;
}

-(void)getData{
    self.edit = NO;
    CJUser *user = [CJUser sharedUser];
    if (!user.nickname){
        return ;
    }
    AFHTTPSessionManager *manger = [AFHTTPSessionManager manager];
    [manger POST:API_BOOK_DETAIL parameters:@{@"email":user.email,@"book_uuid":self.book.uuid} progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary *dic = responseObject;
        NSArray *res = dic[@"res"];
        NSMutableArray *notes = [NSMutableArray array];
        for (NSDictionary *dic in res){
            CJNote *note = [CJNote noteWithDict:dic];
            [notes addObject:note];
        }
        RLMRealm *realm = [CJRlm cjRlmWithName:user.email];
        [realm beginWriteTransaction];
        [realm deleteObjects:self.noteArrM];
        self.noteArrM = notes;
        [realm addObjects:notes];
        [realm commitWriteTransaction];
        
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [self.tableView.mj_header endRefreshing];
            [self.tableView reloadData];
            [self.tableView endLoadingData];
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self.tableView.mj_header endRefreshing];
        [self.tableView endLoadingData];
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = self.book.name;
    // Do any additional setup after loading the view.
    self.tableView.emptyDataSetSource = self;
    self.tableView.emptyDataSetDelegate = self;
    self.tableView.mj_header = [MJRefreshGifHeader cjRefreshHeader:^{
        [self getData];
        
    }];
    
    self.tableView.tableFooterView = [[UIView alloc]init];
    [self.tableView initDataWithTitle:@"无笔记" descriptionText:@"当前笔记本下无笔记..." didTapButton:^{
        [self getData];
    }];
    self.backItem = self.navigationItem.leftBarButtonItem;
    self.edit = NO;
    
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
}



-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellId = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (!cell){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    NSInteger row = indexPath.row;
    CJNote *note = self.noteArrM[row];
    cell.textLabel.text = note.title;
    UILongPressGestureRecognizer *ges = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressCell)];
    cell.contentView.userInteractionEnabled = YES;
    [cell.contentView addGestureRecognizer:ges];
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

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView.editing) {
        if ([self.selectIndexPaths containsObject:indexPath]){
            [self.selectIndexPaths removeObject:indexPath];
        }else{
            [self.selectIndexPaths addObject:indexPath];
        }
        CJLog(@"%@",self.selectIndexPaths);
        return;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CJContentVC *contentVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"contentVC"];
    CJNote *note = self.noteArrM[indexPath.row];
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
        AFHTTPSessionManager *manger = [AFHTTPSessionManager manager];
        CJUser *user = [CJUser sharedUser];
        CJNote *note = self.noteArrM[indexPath.row];
        CJProgressHUD *hud = [CJProgressHUD cjShowWithPosition:CJProgressHUDPositionNavigationBar timeOut:0 withText:@"删除中..." withImages:nil];
        [manger POST:API_DEL_NOTE parameters:@{@"email":user.email,@"note_uuid":note.uuid} progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [weakself.noteArrM removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
            [hud cjShowSuccess:@"删除成功"];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [hud cjShowError:@"删除失败!"];

        }];
    }];

    UITableViewRowAction *move = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"移动" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        CJMoveNoteVC *vc = [[CJMoveNoteVC alloc]init];
        vc.bookTitle = weakself.book.name;
        vc.selectIndexPath = ^(NSString *book_uuid){
            AFHTTPSessionManager *manger = [AFHTTPSessionManager manager];
            CJNote *note = self.noteArrM[indexPath.row];
            CJProgressHUD *hud = [CJProgressHUD cjShowWithPosition:CJProgressHUDPositionNavigationBar timeOut:0 withText:@"移动中..." withImages:nil];
            [manger POST:API_MOVE_NOTE parameters:@{@"note_uuid":note.uuid,@"book_uuid":book_uuid} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                [weakself.noteArrM removeObjectAtIndex:indexPath.row];
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
                [hud cjShowSuccess:@"移动成功"];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                [hud cjShowError:@"移动失败!"];
                
            }];
        };
        [weakself presentViewController:vc animated:YES completion:nil];
        
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
