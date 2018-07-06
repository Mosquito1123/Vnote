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
@interface CJNoteVC ()<UITableViewDelegate,UITableViewDataSource,DZNEmptyDataSetDelegate,DZNEmptyDataSetSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic,strong)NSMutableArray *noteArrM;
@end

@implementation CJNoteVC

-(NSMutableArray *)noteArrM{
    if(!_noteArrM){
        _noteArrM = [NSMutableArray array];
        RLMResults <CJNote *>* notes = [CJNote objectsWhere:[NSString stringWithFormat:@"book_uuid = '%@'",self.book.uuid]];
        for (CJNote *n in notes) {
            [_noteArrM addObject:n];
        }
    }
    return _noteArrM;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = self.book.name;
    // Do any additional setup after loading the view.
    self.tableView.emptyDataSetSource = self;
    self.tableView.emptyDataSetDelegate = self;
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
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
            RLMRealm *realm = [RLMRealm defaultRealm];
            [realm beginWriteTransaction];
            [realm deleteObjects:self.noteArrM];
            self.noteArrM = notes;
            [realm addObjects:notes];
            [realm commitWriteTransaction];
            
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.tableView.mj_header endRefreshing];
                [self.tableView reloadData];
            });
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
        }];
        
    }];
    
    self.tableView.tableFooterView = [[UIView alloc]init];
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
    CJContentVC *contentVC = [[CJContentVC alloc]init];
    CJNote *note = self.noteArrM[indexPath.row];
    contentVC.uuid = note.uuid;
    
    [self.navigationController pushViewController:contentVC animated:YES];
}

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSString *title = @"无笔记";
    NSDictionary *attributes = @{
                                 NSFontAttributeName:[UIFont boldSystemFontOfSize:25.0f],
                                 NSForegroundColorAttributeName:[UIColor darkGrayColor]
                                 };
    return [[NSAttributedString alloc] initWithString:title attributes:attributes];
}

- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView {
    NSString *text = @"当前的笔记本下还没有任何笔记...";
    
    NSMutableParagraphStyle *paragraph = [NSMutableParagraphStyle new];
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    paragraph.alignment = NSTextAlignmentCenter;
    
    NSDictionary *attributes = @{
                                 NSFontAttributeName:[UIFont systemFontOfSize:14.0f],
                                 NSForegroundColorAttributeName:[UIColor lightGrayColor],
                                 NSParagraphStyleAttributeName:paragraph
                                 };
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

@end
