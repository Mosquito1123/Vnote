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
@interface CJMainVC ()<UITableViewDelegate,UITableViewDataSource>
@property(strong,nonatomic) NSMutableArray *books;
@property(strong,nonatomic) NSMutableArray *notes;
@property(strong,nonatomic) IBOutlet CJTableView *bookView;

@end


@implementation CJMainVC
- (IBAction)addBook:(id)sender {
    UINavigationController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"addBookNav"];
    [self presentViewController:vc animated:YES completion:nil];
}

-(NSMutableArray *)reGetRlmBooks{
    RLMRealm *rlm = [CJRlm shareRlm];
    NSMutableArray *array = [NSMutableArray array];
    
    RLMResults <CJBook *>*books= [CJBook allObjectsInRealm:rlm];
    for (CJBook *b in books) {
        if ([b.name isEqualToString:@"Trash"] || [b.name isEqualToString:@"All Notes"] || [b.name isEqualToString:@"Recents"]){
            continue;
        }
        [array addObject:b];
    }
    return array;
}

-(NSMutableArray *)books{
    if (!_books){
        // 从数据库中读取
        _books = [self reGetRlmBooks];
    }
    return _books;
}

-(NSMutableArray *)reGetRlmNotes{
    NSMutableArray *array = [NSMutableArray array];
    
    RLMRealm *rlm = [CJRlm shareRlm];
    RLMResults <CJNote *>*notes = [CJNote allObjectsInRealm:rlm];
    for (CJNote *n in notes) {
        [array addObject:n];
    }
    return array;
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
    [CJAPI getBooksAndNotesWithParams:@{@"email":user.email} success:^(NSDictionary *dic) {
        NSMutableArray *booksArrM = [NSMutableArray array];
        for (NSDictionary *d in dic[@"res"][@"book_info_list"]){
            CJBook *book = [CJBook bookWithDict:d];
            [booksArrM addObject:book];
        }
        NSMutableArray *notesArrM = [NSMutableArray array];
        for (NSDictionary *d in dic[@"res"][@"notes"]){
            CJNote *note = [CJNote noteWithDict:d];
            [notesArrM addObject:note];
        }
        
        [CJRlm deleteObjects:[weakself reGetRlmNotes]];
        [CJRlm deleteObjects:weakself.books];
        weakself.books = booksArrM;
        weakself.notes = notesArrM;
        [CJRlm addObjects:booksArrM];
        [CJRlm addObjects:notesArrM];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakself.bookView.mj_header endRefreshing];
            [weakself.bookView reloadData];
        });
    } failure:^(NSError *error) {
        [weakself.bookView.mj_header endRefreshing];
        if (error.code == NSURLErrorCannotConnectToHost){
            // 无网络
        }else if (error.code == NSURLErrorTimedOut){
            // 请求超时
        }
    }];
    
}

-(void)loadBookViewData{
    NSLog(@"%@",CJDocumentPath);
    CJWeak(self)
    self.bookView.mj_header = [MJRefreshGifHeader cjRefreshHeader:^{
        [weakself getBookData];
    }];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.bookView.backgroundColor = MainBg;

    [self.bookView layoutIfNeeded];
    self.bookView.tableFooterView = [[UIView alloc]init];
    [self loadBookViewData];
    RLMResults <CJBook *>*res = [CJBook objectsWhere:@"name = 'Trash'"];
    if (!res.count){
        [self.bookView.mj_header beginRefreshing];
    }
    NSNotificationCenter *defaulCenter = [NSNotificationCenter defaultCenter];
    [defaulCenter addObserver:self selector:@selector(changeAcountNoti:) name:LOGIN_ACCOUT_NOTI object:nil];
    [defaulCenter addObserver:self selector:@selector(bookChange:) name:BOOK_CHANGE_NOTI object:nil];

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
    CJBook *book = self.books[row];
    text = book.name;
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
    cell.imageView.image = [UIImage imageNamed:@"笔记本灰"];
    return cell;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.books.count;
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger row = indexPath.row;
    CJBook *book = self.books[row];
    CJNoteVC *noteVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"noteVC"];
    noteVC.book = book;
    [self.navigationController pushViewController:noteVC animated:YES];
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{

    CJBook *book = self.books[indexPath.row];
    CJWeak(self)
    UITableViewRowAction *setting = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"设置" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        CJMainNaVC *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"bookSettingNav"];
        CJBookSettingVC *bookSetVC = vc.rt_viewControllers[0];
        bookSetVC.book = book;
        [weakself presentViewController:vc animated:YES completion:nil];
        
    }];
    UITableViewRowAction *del = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        CJUser *user = [CJUser sharedUser];
        CJProgressHUD *hud = [CJProgressHUD cjShowWithPosition:CJProgressHUDPositionTabBar timeOut:0 withText:@"删除中..." withImages:nil];
        [CJAPI deleteBookWithParams:@{@"email":user.email,@"book_uuid":book.uuid} success:^(NSDictionary *dic) {
            if ([dic[@"status"] integerValue] == 0){
                NSUInteger row = indexPath.row;
                [hud cjHideProgressHUD];
                [CJRlm deleteObject:book];
                [weakself.books removeObjectAtIndex:row];
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
                
            }else{
                [hud cjShowError:@"删除失败!"];
            }
        } failure:^(NSError *error) {
            [hud cjShowError:@"删除失败!"];
        }];
        
    }];
    
    
    setting.backgroundColor = BlueBg;
    return @[del,setting];
}

- (nullable UIViewController *)previewingContext:(id <UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location NS_AVAILABLE_IOS(9_0) {
    
    NSIndexPath *indexPath = [self.bookView indexPathForCell:(UITableViewCell *)[previewingContext sourceView]];
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
