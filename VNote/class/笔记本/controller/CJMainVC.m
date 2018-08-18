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
@property(strong,nonatomic) NSMutableArray *booksArrM;
@property(strong,nonatomic) NSMutableArray *notesArrM;
@property(strong,nonatomic) IBOutlet CJTableView *bookView;



@end


@implementation CJMainVC
- (IBAction)addBook:(id)sender {
    UINavigationController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"addBookNav"];
    [self presentViewController:vc animated:YES completion:nil];
}

-(NSMutableArray *)reGetRlmBooks{
    CJUser *user = [CJUser sharedUser];
    RLMRealm *rlm = [CJRlm cjRlmWithName:user.email];
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

-(NSMutableArray *)booksArrM{
    if (!_booksArrM){
        // 从数据库中读取
        _booksArrM = [self reGetRlmBooks];
    }
    return _booksArrM;
}

-(NSMutableArray *)reGetRlmNotes{
    NSMutableArray *array = [NSMutableArray array];
    CJUser *user = [CJUser sharedUser];
    RLMRealm *rlm = [CJRlm cjRlmWithName:user.email];
    RLMResults <CJNote *>*notes = [CJNote allObjectsInRealm:rlm];
    for (CJNote *n in notes) {
        [array addObject:n];
    }
    return array;
}

-(NSMutableArray *)notesArrM{
    if (!_notesArrM){
        _notesArrM = [self reGetRlmNotes];
    }
    return _notesArrM;
}



-(void)getBookData{
    CJUser *user = [CJUser sharedUser];
    if (!user.nickname){
        return ;
    }
    
    AFHTTPSessionManager *manger = [AFHTTPSessionManager sharedHttpSessionManager];
    manger.requestSerializer.timeoutInterval = 8;
    [manger POST:API_GET_ALL_BOOKS_AND_NOTES parameters:@{@"email":user.email} progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSMutableArray *booksArrM = [NSMutableArray array];
        NSDictionary *dic = responseObject;
        for (NSDictionary *d in dic[@"res"][@"book_info_list"]){
            CJBook *book = [CJBook bookWithDict:d];
            [booksArrM addObject:book];
        }
        NSMutableArray *notesArrM = [NSMutableArray array];
        for (NSDictionary *d in dic[@"res"][@"notes"]){
            CJNote *note = [CJNote noteWithDict:d];
            [notesArrM addObject:note];
        }
        
        
        RLMRealm *d = [CJRlm cjRlmWithName:user.email];
        [d beginWriteTransaction];
        [d deleteObjects:self.booksArrM];
        [d deleteObjects:self.notesArrM];
        self.booksArrM = booksArrM;
        self.notesArrM = notesArrM;
        [d addObjects:booksArrM];
        [d addObjects:notesArrM];
        [d commitWriteTransaction];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.bookView.mj_header endRefreshing];
            [self.bookView reloadData];
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [self.bookView.mj_header endRefreshing];
        
        if (error.code == NSURLErrorCannotConnectToHost){
            // 无网络
        }else if (error.code == NSURLErrorTimedOut){
            // 请求超时
        }
        
    }];
}

-(void)loadBookViewData{
    NSLog(@"%@",CJDocumentPath);
    self.bookView.mj_header = [MJRefreshGifHeader cjRefreshHeader:^{
        [self getBookData];
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeAcountNoti:) name:CHANGE_ACCOUNT_NOTI object:nil];

}

-(void)changeAcountNoti:(NSNotification *)noti{
    self.booksArrM = [self reGetRlmBooks];
    [self.bookView reloadData];
    
    self.notesArrM = [self reGetRlmNotes];
    
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
    CJBook *book = self.booksArrM[row];
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
    return self.booksArrM.count;
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger row = indexPath.row;
    CJBook *book = self.booksArrM[row];
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

    CJBook *book = self.booksArrM[indexPath.row];
    UITableViewRowAction *setting = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"设置" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        CJMainNaVC *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"bookSettingNav"];
        CJBookSettingVC *bookSetVC = vc.rt_viewControllers[0];
        bookSetVC.book_uuid = book.uuid;
        bookSetVC.book_title = book.name;
        [self presentViewController:vc animated:YES completion:nil];
        
    }];
    
    
    setting.backgroundColor = BlueBg;
    return @[setting];
}

- (nullable UIViewController *)previewingContext:(id <UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location NS_AVAILABLE_IOS(9_0) {
    
    NSIndexPath *indexPath = [self.bookView indexPathForCell:(UITableViewCell *)[previewingContext sourceView]];
    //创建要预览的控制器
    CJNoteVC *presentationVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"noteVC"];
    CJBook *book = self.booksArrM[indexPath.row];
    
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
