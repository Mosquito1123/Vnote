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
#import "CJTagVC.h"
#import "CJAccountVC.h"
#import "CJBookSettingVC.h"
#import "CJBookCell.h"
@interface CJMainVC ()<UITableViewDelegate,UITableViewDataSource>
@property(strong,nonatomic) NSMutableArray *booksArrM;
@property(strong,nonatomic) NSMutableArray *tagsArrM;
@property(strong,nonatomic) NSMutableArray *notesArrM;
@property(strong,nonatomic) CJBook *allBook;
@property(strong,nonatomic) CJBook *recentBoook;
@property(strong,nonatomic) CJBook *trashBook;
@property(assign,nonatomic) NSInteger selectIndex;
@property(strong,nonatomic) IBOutlet CJTableView *bookView;
@property(strong,nonatomic) IBOutlet CJTableView *tagView;
@property(assign,nonatomic) BOOL ascending;
@property(nonatomic,strong) UIButton *penBtn;
//@property(nonatomic,strong) notificationToken;
@end


@implementation CJMainVC
-(void)viewWillAppear:(BOOL)animated{
    self.penBtn.superview.hidden = NO;
}
-(void)viewWillDisappear:(BOOL)animated{
    self.penBtn.superview.hidden = YES;
}

-(NSMutableArray *)reGetRlmBooks{
    CJUser *user = [CJUser sharedUser];
    RLMRealm *rlm = [CJRlm cjRlmWithName:user.email];
    NSMutableArray *array = [NSMutableArray array];
    
    RLMResults <CJBook *>*books= [[CJBook allObjectsInRealm:rlm] sortedResultsUsingKeyPath:@"name" ascending:!self.ascending];
    for (CJBook *b in books) {
        if ([b.name isEqualToString:@"Trash"] || [b.name isEqualToString:@"All Notes"] || [b.name isEqualToString:@"Recents"]){
            continue;
        }
        [array addObject:b];
    }
    RLMResults <CJBook *>*res = [CJBook objectsInRealm:rlm where:@"name = 'Trash'"];
    if (res.count){
        self.trashBook = res[0];
    }
    res = [CJBook objectsInRealm:rlm where:@"name = 'Recents'"];
    if (res.count){
        self.recentBoook = res[0];
    }
    
    
    res = [CJBook objectsInRealm:rlm where:@"name = 'All Notes'"];
    if (res.count){
        self.allBook = res[0];
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
-(NSMutableArray *)reGetRlmTags{
    NSMutableArray *array = [[NSMutableArray alloc]init];
    RLMRealm *rlm = [CJRlm cjRlmWithName:[CJUser sharedUser].email];
    RLMResults <CJTag *>*tags= [CJTag allObjectsInRealm:rlm];
    for (CJTag *t in tags) {
        [array addObject:t];
    }
    return array;
}

-(NSMutableArray *)notesArrM{
    if (!_notesArrM){
        _notesArrM = [self reGetRlmNotes];
    }
    return _notesArrM;
}
-(NSMutableArray *)tagsArrM{
    if (!_tagsArrM){
        _tagsArrM = [self reGetRlmTags];
    }
    return _tagsArrM;
}
-(void)segmentAction:(UISegmentedControl *)control{
    self.selectIndex = control.selectedSegmentIndex;
    if (self.selectIndex == 0){
        [self.bookView reloadData];
        [self.view bringSubviewToFront:self.bookView];
        if(!self.booksArrM.count){
            [self.bookView.mj_header beginRefreshing];
        }
        
    }
    else if (self.selectIndex == 1){
        [self.tagView reloadData];
        [self.view bringSubviewToFront:self.tagView];
        if(!self.tagsArrM.count){
            [self.tagView.mj_header beginRefreshing];
        }
    }
}


-(void)getBookData{
    CJUser *user = [CJUser sharedUser];
    if (!user.nickname){
        return ;
    }
    
    AFHTTPSessionManager *manger = [AFHTTPSessionManager manager];
    manger.requestSerializer.timeoutInterval = 8;
    [manger POST:API_GET_ALL_BOOKS_AND_NOTES parameters:@{@"nickname":user.nickname} progress:^(NSProgress * _Nonnull uploadProgress) {
        
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
        if (self.trashBook){
            [d deleteObject:self.trashBook];
        }
        if (self.recentBoook){
            [d deleteObject:self.recentBoook];
        }
        if (self.allBook){
            [d deleteObject:self.allBook];
        }
        
        self.trashBook = [CJBook bookWithDict:dic[@"res"][@"trash_book"]];
        self.allBook = [CJBook bookWithDict:dic[@"res"][@"all_book"]];
        self.recentBoook = [CJBook bookWithDict:dic[@"res"][@"recent_book"]];
        [d addObject:self.trashBook];
        [d addObject:self.allBook];
        [d addObject:self.recentBoook];
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
-(void)getTagData{
    CJUser *user = [CJUser sharedUser];
    if (!user.nickname){
        
        return ;
    }
    AFHTTPSessionManager *manger = [AFHTTPSessionManager manager];
    manger.requestSerializer.timeoutInterval = 8;
    [manger POST:API_GET_ALL_TAGS parameters:@{@"nickname":user.nickname} progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        // 解析data数据信息
        NSMutableArray *tagsArrM = [NSMutableArray array];
        NSDictionary *dic = responseObject;
        for (NSDictionary *d in dic[@"res"]){
            CJTag *tag = [CJTag tagWithDict:d];
            [tagsArrM addObject:tag];
        }
        
        RLMRealm *d = [CJRlm cjRlmWithName:user.email];
        [d beginWriteTransaction];
        [d deleteObjects:self.tagsArrM];
        self.tagsArrM = tagsArrM;
        [d addObjects:tagsArrM];
        [d commitWriteTransaction];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.tagView.mj_header endRefreshing];
            [self.tagView reloadData];
            [self.tagView endLoadingData];
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self.tagView.mj_header endRefreshing];
        [self.tagView endLoadingData];
        
        if (error.code == NSURLErrorCannotConnectToHost){
            // 无网络
        }else if (error.code == NSURLErrorTimedOut){
            // 请求超时
        }
    }];
}

-(void)loadTagViewData{
    [self.tagView initDataWithTitle:@"无标签" descriptionText:@"你没有在任何笔记下添加tag..." didTapButton:^{
        [self getTagData];
    }];
    self.tagView.mj_header = [MJRefreshGifHeader cjRefreshHeader:^{
        
        [self getTagData];
        
    }];
}

-(void)addNote{
    UINavigationController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"addNoteNav"];
    [self presentViewController:vc animated:YES completion:nil];
}

-(void)addPenBtn{
    UIView *shawView = [[UIView alloc]init];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"pen.png"] forState:UIControlStateNormal];
    [button sizeToFit];
    
    [shawView addSubview:button];
    [self.navigationController.view addSubview:shawView];
    [shawView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-30);
        make.bottom.mas_equalTo(-100);
        make.width.mas_equalTo(button.cj_width);
        make.height.mas_equalTo(button.cj_height);
    }];
    shawView.layer.shadowColor = BlueBg.CGColor;
    shawView.layer.shadowOffset = CGSizeMake(0, 3);
    shawView.layer.shadowOpacity = 1;
    shawView.layer.shadowRadius = 3.0;
    shawView.layer.cornerRadius = button.cj_width/2;
    shawView.clipsToBounds = NO;
    CJCornerRadius(button) = button.cj_width/2;
    
    [button addTarget:self action:@selector(addNote) forControlEvents:UIControlEventTouchUpInside];
    button.backgroundColor = [UIColor whiteColor];
    self.penBtn = button;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    NSUserDefaults *userD = [NSUserDefaults standardUserDefaults];
    if ([[userD valueForKey:@"note_order"] isEqualToString:@"0"]){
        self.ascending = YES;
    }else{
        self.ascending = NO;
    }
    UISegmentedControl *titleView = [[UISegmentedControl alloc]initWithItems:@[@"笔记本",@"标签"]];
    titleView.selectedSegmentIndex = 0;
    [titleView addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
    self.navigationItem.titleView = titleView;
    

    self.tagView.backgroundColor = MainBg;
    self.tagView.tableFooterView = [[UIView alloc]init];
    

    self.bookView.backgroundColor = MainBg;

    [self.bookView layoutIfNeeded];
    self.bookView.tableFooterView = [[UIView alloc]init];
    
    [self loadTagViewData];
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
    self.tagsArrM = [self reGetRlmTags];
    [self.tagView reloadData];
    
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
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if (self.selectIndex == 0){
        
        
        if (section == 0){
            
            switch (row) {
                case 0:
                    //Recents
                    text = @"最近";
                    break;
                case 1:
                    //Trash
                    text = @"垃圾篓";
                    break;
                case 2:
                    //All Notes
                    text = @"所有笔记";
                    break;
                default:
                    break;
            }
            
        }
        else{
            CJBook *book = self.booksArrM[row];
            text = book.name;
        }
        
    }
    else{
        
        cell.textLabel.textColor = [UIColor blackColor];
        cell.backgroundColor = [UIColor whiteColor];
        cell.textLabel.font = [UIFont systemFontOfSize:16];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.accessoryView = nil;
        if (row < self.tagsArrM.count){
            CJTag *tag = self.tagsArrM[row];
            text =tag.tag;
        }
        
        
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
    return cell;
}



-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (self.selectIndex == 1){
        //tags
        return 1;
    }
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.selectIndex == 1){
        
       return self.tagsArrM.count;
        
    }
    
    if (section == 0){
        return 3;
    }else if(section == 1){
        return self.booksArrM.count;
    }
    return 0;
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.accessoryView){
        return;
    }
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    if (self.selectIndex == 0){
        CJBook *book;
        // 点击bookView里面的cell

        if (section == 0){
            switch (row) {
                case 0:
                    //Recents
                    book = self.recentBoook;
                    break;
                case 1:
                    //Trash
                    book = self.trashBook;
                    break;
                case 2:
                    //All Notes
                    book = self.allBook;
                    break;
                default:
                    break;
            }
        }
        else if (section == 1){
            book = self.booksArrM[row];
            
        }
        CJNoteVC *noteVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"noteVC"];
        noteVC.book = book;
        [self.navigationController pushViewController:noteVC animated:YES];
    }else if (self.selectIndex == 1){
        // 点击tags里面的cell
        
        // 显示当前下面tag下面的笔记数目
        CJTag *tag = self.tagsArrM[row];
        CJTagVC *tagVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"tagVC"];
        tagVC.tag = tag;
        [self.navigationController pushViewController:tagVC animated:YES];
        
        
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.selectIndex == 0){
        return 50;
    }
    return 44;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    CJBook *book = self.booksArrM[indexPath.row];
    NSInteger section = indexPath.section;
    if (self.selectIndex == 0 && section == 0 && row == 1){
        UITableViewRowAction *setting = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"清空垃圾篓" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
            CJUser *user = [CJUser sharedUser];
            CJProgressHUD *hud = [CJProgressHUD cjShowWithPosition:CJProgressHUDPositionBothExist timeOut:0 withText:@"加载中..." withImages:nil];
            AFHTTPSessionManager *manger = [AFHTTPSessionManager manager];
            [manger POST:API_CLEAR_TRASH parameters:@{@"email":user.email} progress:^(NSProgress * _Nonnull uploadProgress) {
                
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                
                NSDictionary *dict = responseObject;
                
                if([dict[@"status"] intValue] == 0){
                    NSLog(@"清空垃圾");
                    [hud cjHideProgressHUD];
                    
                }else{
                    [hud cjShowError:@"操作失败!"];
                }
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                [hud cjHideProgressHUD];
            }];
            
            
        }];
        return @[setting];
    }
    if (self.selectIndex == 0 && section == 1){
        UITableViewRowAction *setting = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"设置" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
            UINavigationController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"bookSettingNav"];
            CJBookSettingVC *bookSetVC = vc.viewControllers[0];
            bookSetVC.book_uuid = book.uuid;
            bookSetVC.book_title = book.name;
            [self presentViewController:vc animated:YES completion:nil];
            
        }];
        return @[setting];
    }
    return @[];
}


-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (self.selectIndex == 0){
        if (section == 0){
            return @"图书";
        }else{
            return @"笔记本";
        }
    }
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;// 不要设置成0
}

- (nullable UIViewController *)previewingContext:(id <UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location NS_AVAILABLE_IOS(9_0) {
    if (self.selectIndex == 0){
        NSIndexPath *indexPath = [self.bookView indexPathForCell:(UITableViewCell *)[previewingContext sourceView]];
        //创建要预览的控制器
        CJNoteVC *presentationVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"noteVC"];
        CJBook *book;
        if (indexPath.section == 0){
            switch (indexPath.row){
                case 0:book = self.recentBoook;break;
                case 1:book = self.trashBook;break;
                case 2:book = self.allBook;break;
            }
        }else{
            book = self.booksArrM[indexPath.row];
        }
        presentationVC.book = book;
        
        //指定当前上下文视图Rect
        CGRect rect = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 50);
        previewingContext.sourceRect = rect;
        
        return presentationVC;
    }
    else{
        NSIndexPath *indexPath = [self.tagView indexPathForCell:(UITableViewCell *)[previewingContext sourceView]];
        //创建要预览的控制器
        CJTagVC *presentationVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"tagVC"];
        
        presentationVC.tag = self.tagsArrM[indexPath.row];
        //指定当前上下文视图Rect
        CGRect rect = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44);
        previewingContext.sourceRect = rect;
        
        return presentationVC;
    }
    return nil;
}

#pragma mark pop(push)
- (void)previewingContext:(id <UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit NS_AVAILABLE_IOS(9_0) {
    
    [self showViewController:viewControllerToCommit sender:self];
}


@end
