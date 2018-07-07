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
@interface CJMainVC ()<UITableViewDelegate,UITableViewDataSource>
@property(strong,nonatomic) NSMutableArray *booksArrM;
@property(strong,nonatomic) NSMutableArray *tagsArrM;
@property(strong,nonatomic) NSMutableArray *notesArrM;
@property(strong,nonatomic) CJBook *allBook;
@property(strong,nonatomic) CJBook *recentBoook;
@property(strong,nonatomic) CJBook *trashBook;
@property(assign,nonatomic) NSInteger selectIndex;
@property(strong,nonatomic) IBOutlet UITableView *bookView;
@property(strong,nonatomic) IBOutlet UITableView *tagView;
@end


@implementation CJMainVC

-(NSMutableArray *)booksArrM{
    if (!_booksArrM){
        // 从数据库中读取
        _booksArrM = [NSMutableArray array];
        RLMResults <CJBook *>*books= [CJBook allObjects];
        for (CJBook *b in books) {
            if ([b.name isEqualToString:@"Trash"] || [b.name isEqualToString:@"All Notes"] || [b.name isEqualToString:@"Recents"]){
                continue;
            }
            [_booksArrM addObject:b];
        }
        RLMResults <CJBook *>*res = [CJBook objectsWhere:@"name = 'Trash'"];
        if (res.count){
            self.trashBook = res[0];
        }
        res = [CJBook objectsWhere:@"name = 'Recents'"];
        if (res.count){
            self.recentBoook = res[0];
        }
        
        
        res = [CJBook objectsWhere:@"name = 'All Notes'"];
        if (res.count){
            self.allBook = res[0];
        }
    }
    return _booksArrM;
}
-(NSMutableArray *)notesArrM{
    if (!_notesArrM){
        _notesArrM = [NSMutableArray array];
        RLMResults <CJNote *>*notes = [CJNote allObjects];
        for (CJNote *n in notes) {
            [_notesArrM addObject:n];
        }
    }
    return _notesArrM;
}
-(NSMutableArray *)tagsArrM{
    if (!_tagsArrM){
        _tagsArrM = [[NSMutableArray alloc]init];
        RLMResults <CJTag *>*tags= [CJTag allObjects];
        for (CJTag *t in tags) {
            [_tagsArrM addObject:t];
        }
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


-(void)loadBookViewData{
    NSLog(@"%@",CJDocumentPath);
    self.bookView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
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

            RLMRealm *d = [RLMRealm defaultRealm];
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
        
        
    }];
    
}

-(void)loadTagViewData{
    self.tagView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        
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
            
            RLMRealm *d = [RLMRealm defaultRealm];
            [d beginWriteTransaction];
            [d deleteObjects:self.tagsArrM];
            self.tagsArrM = tagsArrM;
            [d addObjects:tagsArrM];
            [d commitWriteTransaction];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.tagView.mj_header endRefreshing];
                [self.tagView reloadData];
            });
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [self.tagView.mj_header endRefreshing];
            
            if (error.code == NSURLErrorCannotConnectToHost){
                // 无网络
            }else if (error.code == NSURLErrorTimedOut){
                // 请求超时
            }
        }];
        
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UISegmentedControl *titleView = [[UISegmentedControl alloc]initWithItems:@[@"笔记本",@"标签"]];
    titleView.selectedSegmentIndex = 0;
    [titleView addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
    self.navigationItem.titleView = titleView;
    

    self.tagView.backgroundColor = MainBg;
    self.tagView.tableFooterView = [[UIView alloc]init];
    

    self.bookView.backgroundColor = MainBg;
    [self.bookView layoutIfNeeded];
    self.bookView.tableHeaderView = [[UIView alloc]init];
    self.bookView.tableFooterView = [[UIView alloc]init];
    
    [self loadTagViewData];
    [self loadBookViewData];
    
    RLMResults <CJBook *>*res = [CJBook objectsWhere:@"name = 'Trash'"];
    if (!res.count){
        [self.bookView.mj_header beginRefreshing];
    }
    

}



-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellID = @"cell";
    NSInteger section = indexPath.section;
    UITableViewCell *cell;

    cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    cell.textLabel.textColor = [UIColor blackColor];
    cell.backgroundColor = [UIColor whiteColor];
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    
    if (section == 3){
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.accessoryView = nil;
    }else{
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.accessoryView = nil;
    }

    
    NSString *text;
    
    if (self.selectIndex == 1){
        
        CJTag *tag = self.tagsArrM[indexPath.row];
        text =tag.tag;
        
    }
    else{
        if(section == 0){
            switch (indexPath.row) {
                case 0:
                    text = @"最近";
                    break;
                case 1:
                    text = @"垃圾篓";
                    break;
                case 2:
                    text = @"所有笔记";
                    break;
                default:
                    break;
            }
            
        }else if (section == 1){
            CJBook *book = self.booksArrM[indexPath.row];
            text = book.name;
        }
    }
    cell.textLabel.text = text;
    
    if ([self respondsToSelector:@selector(traitCollection)]) {
        
        if ([self.traitCollection respondsToSelector:@selector(forceTouchCapability)]) {
            
            if (self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) {
                
                [self registerForPreviewingWithDelegate:(id)self sourceView:cell];
                
            }
        }
    }

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
            AFHTTPSessionManager *manger = [AFHTTPSessionManager manager];
            [manger POST:API_CLEAR_TRASH parameters:@{@"email":user.email} progress:^(NSProgress * _Nonnull uploadProgress) {
                
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                NSDictionary *dict = responseObject;
                
                if([dict[@"status"] intValue] == 0){
                    NSLog(@"清空垃圾");
                }
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                
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
        CGRect rect = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 250);
        previewingContext.sourceRect = rect;
        
        return presentationVC;
    }
    else{
        NSIndexPath *indexPath = [self.tagView indexPathForCell:(UITableViewCell *)[previewingContext sourceView]];
        //创建要预览的控制器
        CJTagVC *presentationVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"tagVC"];
        
        presentationVC.tag = self.tagsArrM[indexPath.row];
        //指定当前上下文视图Rect
        CGRect rect = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 250);
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
