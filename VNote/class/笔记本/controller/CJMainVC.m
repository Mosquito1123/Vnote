//
//  CJMainVC.m
//  VNote
//
//  Created by ccj on 2018/6/1.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import "CJMainVC.h"
#import "CJConfig.h"
#import "CJNoteVC.h"
#import "CJBook.h"
#import "CJTag.h"
#import "CJAccountVC.h"
#import "CJLoginVC.h"
#import "CJTagNoteVC.h"
#import "CJAccountVC.h"
#import "CJBookSettingVC.h"
#import "CJBookCell.h"
#import "CJAddBookVC.h"
#import "CJSearchResVC.h"
#import "PYSearch.h"
#import "CJRightDropMenuVC.h"
#import "CJAddNoteVC.h"
#import "CJSearchUserVC.h"
#import "CJRecentVC.h"
#import "CJRecycleBinVC.h"
#import "CJAllNotesVC.h"
@interface CJMainVC ()<UITableViewDelegate,UITableViewDataSource,UIPopoverPresentationControllerDelegate>
@property(strong,nonatomic) NSMutableArray *books;
@property(strong,nonatomic) NSMutableArray *notes;
@property(strong,nonatomic) IBOutlet CJTableView *bookView;

@end


@implementation CJMainVC
- (IBAction)orderClick:(id)sender {
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *up = [UIAlertAction actionWithTitle:@"标题 ↑" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [CJTool saveUserInfo2JsonWithNoteOrder:NoteOrderTypeUp closePenfriendFunc:[CJTool getClosePenFriendFunc]];
    }];
    UIAlertAction *down = [UIAlertAction actionWithTitle:@"标题 ↓" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [CJTool saveUserInfo2JsonWithNoteOrder:NoteOrderTypeDown closePenfriendFunc:[CJTool getClosePenFriendFunc]];
    }];
    [vc addAction:cancel];
    [vc addAction:up];
    [vc addAction:down];
    UIPopoverPresentationController *popover = vc.popoverPresentationController;
    
    if (popover) {
        popover.barButtonItem = sender;
        popover.permittedArrowDirections = UIPopoverArrowDirectionUp;
    }
    [self presentViewController:vc animated:YES completion:nil];
}
- (IBAction)searchBtnClick:(id)sender {
    
    PYSearchViewController *vc= [PYSearchViewController searchViewControllerWithHotSearches:nil searchBarPlaceholder:@"输入笔记名、标签名称" didSearchBlock:^(PYSearchViewController *searchViewController, UISearchBar *searchBar, NSString *searchText) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            CJProgressHUD *hud = [CJProgressHUD cjShowWithPosition:CJProgressHUDPositionNavigationBar timeOut:TIME_OUT withText:@"加载中..." withImages:nil];
            CJUser *user = [CJUser sharedUser];
            CJWeak(self)
            if (searchText.length == 0){
                return ;
            }
            [CJAPI requestWithAPI:API_SEARCH_NOTE params:@{@"email":user.email,@"key":searchText} success:^(NSDictionary *dic) {
                [weakself.notes removeAllObjects];
                for (NSDictionary *d in dic[@"key_notes"]) {
                    CJNote *note = [CJNote noteWithDict:d];
                    [weakself.notes addObject:note];
                }
                if (weakself.notes.count){
                    
                    [hud cjHideProgressHUD];
                    CJSearchResVC *vc = [[CJSearchResVC alloc]init];
                    vc.notes = weakself.notes;
                    [searchViewController.navigationController pushViewController:vc animated:YES];
                }else{
                    [hud cjShowError:@"无记录"];
                }
            } failure:^(NSDictionary *dic) {
                [hud cjShowError:@"无记录!"];
                
            } error:^(NSError *error) {
                [hud cjShowError:net101code];
            }];
        });
        
    }];
    vc.searchHistoryStyle = PYSearchHistoryStyleNormalTag;
    CJMainNaVC *navc = [[CJMainNaVC alloc]initWithRootViewController:vc];
    navc.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:navc animated:NO completion:nil];
    
}

-(void)addNote{

    RLMRealm *rlm = [CJRlm shareRlm];
    NSMutableArray *res = [CJBook cjAllObjectsInRlm:rlm];
    if (!res.count){
        [CJProgressHUD cjShowErrorWithPosition:CJProgressHUDPositionBothExist withText:@"你未创建笔记本!"];
        return;
    }
    CJLeftSliderVC *sliderVC = (CJLeftSliderVC *)[UIApplication sharedApplication].keyWindow.rootViewController;
    [sliderVC showLeftViewAnimation];
}
-(void)addFriend{
    CJUser *user = [CJUser sharedUser];
    if (user.is_tourist){
        [CJProgressHUD cjShowErrorWithPosition:CJProgressHUDPositionBothExist withText:@"请注册!"];
        return;
    }
    CJSearchUserVC *vc = [[CJSearchUserVC alloc]init];
    CJMainNaVC *nav = [[CJMainNaVC alloc]initWithRootViewController:vc];
    nav.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:nav animated:YES completion:nil];
}


-(void)addBook{
    UINavigationController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"addBookNav"];
    vc.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:vc animated:YES completion:nil];
}
- (IBAction)addBook:(id)sender {
    
    CJRightDropMenuVC *vc = [[CJRightDropMenuVC alloc]init];
    vc.didSelectIndex = ^(NSInteger index){
        if (index == 0){
            [self addBook];
        }else if (index == 1){
            [self addNote];
        }else if (index == 2){
            [self addFriend];
        }
    };
    CGFloat menuH = 3 * 40.0 + 20.0;
    vc.preferredContentSize = CGSizeMake(160, menuH);
    vc.modalPresentationStyle = UIModalPresentationPopover;
    UIPopoverPresentationController *popController = vc.popoverPresentationController;
    popController.backgroundColor = [UIColor whiteColor];
    popController.delegate = self;
    popController.permittedArrowDirections = UIPopoverArrowDirectionUp;
    popController.barButtonItem = self.navigationItem.rightBarButtonItem;
    
    
    [self presentViewController:vc animated:YES completion:nil];
    
}

-(UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
    return UIModalPresentationNone;
}

-(NSMutableArray *)reGetRlmBooks{
    RLMRealm *rlm = [CJRlm shareRlm];
    NSMutableArray *array = [NSMutableArray array];
    
    NSMutableArray *books= [CJBook cjAllObjectsInRlm:rlm];
    for (CJBook *b in books) {
        if ([b.name isEqualToString:@"Trash"] || [b.name isEqualToString:@"All Notes"] || [b.name isEqualToString:@"Recents"]){
            continue;
        }
        [array addObject:b];
    }
    return [CJTool orderObjects:array withKey:@"name"];
}



-(NSMutableArray *)books{
    if (!_books){
        // 从数据库中读取
        _books = [self reGetRlmBooks];
    }
    return _books;
}

-(NSMutableArray *)reGetRlmNotes{
    RLMRealm *rlm = [CJRlm shareRlm];
    return [CJNote cjAllObjectsInRlm:rlm];
}

-(NSMutableArray *)notesArrM{
    if (!_notes){
        _notes = [self reGetRlmNotes];
    }
    return _notes;
}



-(void)getBookData{
    CJUser *user = [CJUser sharedUser];
    if (!user.nickname){
        return ;
    }
    CJWeak(self)
    [CJAPI requestWithAPI:API_GET_ALL_BOOKS_AND_NOTES params:@{@"email":user.email} success:^(NSDictionary *dic) {
        NSMutableArray *booksArrM = [NSMutableArray array];
        for (NSDictionary *d in dic[@"books"]){
            CJBook *book = [CJBook bookWithDict:d];
            [booksArrM addObject:book];
        }
        NSMutableArray *notesArrM = [NSMutableArray array];
        for (NSDictionary *d in dic[@"notes"]){
            CJNote *note = [CJNote noteWithDict:d];
            [notesArrM addObject:note];
        }
        
        [CJRlm deleteObjects:[weakself reGetRlmNotes]];
        [CJRlm deleteObjects:weakself.books];
        weakself.notes = notesArrM;
        [CJRlm addObjects:booksArrM];
        [CJRlm addObjects:notesArrM];
        
        weakself.books = [CJTool orderObjects:booksArrM withKey:@"name"];
        [weakself.bookView.mj_header endRefreshing];
        [weakself.bookView reloadData];
        [weakself.bookView endLoadingData];
    } failure:^(NSDictionary *dic) {
        [weakself.bookView endLoadingData];
        [weakself.bookView.mj_header endRefreshing];
    } error:^(NSError *error) {
        [weakself.bookView endLoadingData];
        [weakself.bookView.mj_header endRefreshing];
    }];
}

-(void)loadBookViewData{
    CJWeak(self)
    self.bookView.mj_header = [MJRefreshGifHeader cjRefreshWithPullType:CJPullTypeNormal header:^{
        [weakself getBookData];
    }];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addAvtar];
    self.bookView.backgroundColor = MainBg;

    [self loadBookViewData];
    RLMResults <CJBook *>*res = [CJBook objectsWhere:@"name = 'Trash'"];
    if (!res.count){
        [self.bookView.mj_header beginRefreshing];
    }
    CJWeak(self)
    [self.bookView initDataWithTitle:@"无笔记本" descriptionText:@"你还没有创建笔记本" didTapButton:^{
        [weakself getBookData];
    }];
    NSNotificationCenter *defaulCenter = [NSNotificationCenter defaultCenter];
    [defaulCenter addObserver:self selector:@selector(changeAcountNoti:) name:LOGIN_ACCOUT_NOTI object:nil];
    [defaulCenter addObserver:self selector:@selector(bookChange:) name:BOOK_CHANGE_NOTI object:nil];
    [defaulCenter addObserver:self selector:@selector(noteOrderChange:) name:NOTE_ORDER_CHANGE_NOTI object:nil];
    [defaulCenter addObserver:self selector:@selector(noteChange:) name:NOTE_CHANGE_NOTI object:nil];
    self.bookView.rowHeight = 50;
}

-(void)noteChange:(NSNotification *)noti
{
    self.notes = [self reGetRlmNotes];
}

-(void)noteOrderChange:(NSNotification *)noti{
    self.books = [CJTool orderObjects:self.books withKey:@"name"];
    [self.bookView reloadData];
}

-(void)bookChange:(NSNotification *)noti{
    self.books = nil;
    [self.bookView reloadData];
}

-(void)changeAcountNoti:(NSNotification *)noti{
    self.books = [self reGetRlmBooks];
    [self.bookView reloadData];
    self.notes = [self reGetRlmNotes];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellID = @"cell";
    UITableViewCell *cell;
    
    cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    NSString *text;
    NSInteger row = indexPath.row;
    NSString *imgName;
    if (indexPath.section == 0){
        switch (row) {
            case 0:
                text = @"最近";
                imgName = @"最近灰";
                break;
            case 1:
                text = @"回收站";
                imgName = @"回收站";
                break;
            case 2:
                text = @"全部笔记";
                imgName = @"全部笔记灰";
                break;
            default:
                break;
        }
        
    }else if (indexPath.section == 1){
        CJBook *book = self.books[row];
        if (book.isInvalidated){
            self.books = [self reGetRlmBooks];
            book = self.books[row];
        }
        text = book.name;
        imgName = @"笔记本灰";
    }
    if ([self respondsToSelector:@selector(traitCollection)]) {
        
        if ([self.traitCollection respondsToSelector:@selector(forceTouchCapability)]) {
            
            if (self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) {
                
                [self registerForPreviewingWithDelegate:(id)self sourceView:cell];
                
            }
        }
    }
    cell.textLabel.text = text;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.font = [UIFont systemFontOfSize:17];
    cell.imageView.image = [UIImage imageNamed:imgName];
    return cell;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0){
        return 3;
    }
    return self.books.count;
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0){
        UIViewController *vc;
        switch (indexPath.row) {
            case 0:
                vc = [[CJRecentVC alloc]init];
                break;
            case 1:
                vc = [[CJRecycleBinVC alloc]init];
                break;
            case 2:
                vc = [[CJAllNotesVC alloc]init];
            default:
                break;
        }
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        
        NSInteger row = indexPath.row;
        CJBook *book = self.books[row];
        CJNoteVC *noteVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"noteVC"];
        noteVC.book = book;
        [self.navigationController pushViewController:noteVC animated:YES];
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 0){
        return @"图书馆";
    }else{
        return @"笔记本";
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 0) return 20.f;
    return 0.1f;
}

-(void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section{
    UITableViewHeaderFooterView *v = (UITableViewHeaderFooterView *)view;
    view.tintColor = [UIColor whiteColor];
    v.textLabel.textColor = BlueBg;
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) return NO;
    return YES;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)return nil;
    CJBook *book = self.books[indexPath.row];
    CJWeak(self)
    UITableViewRowAction *setting = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"设置" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        CJMainNaVC *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"bookSettingNav"];
        CJBookSettingVC *bookSetVC = vc.rt_viewControllers[0];
        bookSetVC.book = book;
        vc.modalPresentationStyle = UIModalPresentationOverFullScreen;
        [weakself presentViewController:vc animated:YES completion:nil];
        
    }];
    UITableViewRowAction *del = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        CJUser *user = [CJUser sharedUser];
        CJProgressHUD *hud = [CJProgressHUD cjShowInView:self.view timeOut:TIME_OUT withText:@"删除中..." withImages:nil];
        [CJAPI requestWithAPI:API_DEL_BOOK params:@{@"email":user.email,@"book_uuid":book.uuid} success:^(NSDictionary *dic) {
            NSUInteger row = indexPath.row;
            [hud cjHideProgressHUD];
            [CJRlm deleteObject:book];
            [weakself.books removeObjectAtIndex:row];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        } failure:^(NSDictionary *dic) {
            [hud cjShowError:@"删除失败!"];
        } error:^(NSError *error) {
            [hud cjShowError:net101code];
        }];
    }];
    
    
    setting.backgroundColor = BlueBg;
    return @[del,setting];
}

- (nullable UIViewController *)previewingContext:(id <UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location NS_AVAILABLE_IOS(9_0) {
    
    NSIndexPath *indexPath = [self.bookView indexPathForCell:(UITableViewCell *)[previewingContext sourceView]];
    if (indexPath.section == 0) return nil;
    //创建要预览的控制器
    CJNoteVC *presentationVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"noteVC"];
    CJBook *book = self.books[indexPath.row];
    
    presentationVC.book = book;
    
    //指定当前上下文视图Rect
    CGRect rect = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 50);
    previewingContext.sourceRect = rect;
    
    return presentationVC;
    
    
    
}

#pragma mark pop(push)
- (void)previewingContext:(id <UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit NS_AVAILABLE_IOS(9_0) {
    
    [self showViewController:viewControllerToCommit sender:self];
}


@end
