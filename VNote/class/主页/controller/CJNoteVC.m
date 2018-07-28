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
@interface CJNoteVC ()<UITableViewDelegate,UITableViewDataSource,DZNEmptyDataSetDelegate,DZNEmptyDataSetSource,UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet CJTableView *tableView;
@property(nonatomic,strong) NSMutableArray *noteArrM;

@end

@implementation CJNoteVC
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    CJNoteSearchView *view = [CJNoteSearchView xibNoteSearchView];
    [self.navigationController.view addSubview:view];
    view.frame = self.navigationController.view.bounds;
    view.noteArrM = self.noteArrM;
    return NO;
}


-(NSMutableArray *)noteArrM{
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
    CJUser *user = [CJUser sharedUser];
    if (!user.nickname){
        return ;
    }
    AFHTTPSessionManager *manger = [AFHTTPSessionManager manager];
    [manger POST:API_BOOK_DETAIL parameters:@{@"nickname":user.nickname,@"book_uuid":self.book.uuid} progress:^(NSProgress * _Nonnull uploadProgress) {
        
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
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.noteArrM.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CJContentVC *contentVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"contentVC"];
    CJNote *note = self.noteArrM[indexPath.row];
    contentVC.uuid = note.uuid;
    contentVC.title = note.title;
    contentVC.isMe = YES;
    
    [self.navigationController pushViewController:contentVC animated:YES];
}



- (NSArray<id<UIPreviewActionItem>> *)previewActionItems {
    
    NSMutableArray *arrItem = [NSMutableArray array];
    
    UIPreviewAction *previewAction0 = [UIPreviewAction actionWithTitle:@"取消" style:UIPreviewActionStyleDestructive handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
        
        NSLog(@"didClickCancel");
    }];
    UIPreviewAction *previewAction1 = [UIPreviewAction actionWithTitle:@"进入" style:UIPreviewActionStyleDefault handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
        
    }];
    
    [arrItem addObjectsFromArray:@[previewAction0,previewAction1]];
    
    return arrItem;
}
@end
