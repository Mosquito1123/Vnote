//
//  CJTagVC.m
//  VNote
//
//  Created by ccj on 2018/7/31.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import "CJTagVC.h"
#import "CJTagNoteVC.h"
@interface CJTagVC ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet CJTableView *tableView;
@property (strong,nonatomic)NSMutableArray <CJTag *>*tags;

@end

@implementation CJTagVC


-(NSMutableArray *)reGetRlmTags{
    NSMutableArray *array = [[NSMutableArray alloc]init];
    RLMRealm *rlm = [CJRlm cjRlmWithName:[CJUser sharedUser].email];
    RLMResults <CJTag *>*tags= [CJTag allObjectsInRealm:rlm];
    for (CJTag *t in tags) {
        [array addObject:t];
    }
    return array;
}


-(NSMutableArray *)tags{
    if (!_tags){
        _tags = [self reGetRlmTags];
    }
    return _tags;
}


-(void)getTagData{
    CJUser *user = [CJUser sharedUser];
    if (!user.nickname){
        
        return ;
    }
    AFHTTPSessionManager *manger = [AFHTTPSessionManager manager];
    manger.requestSerializer.timeoutInterval = 8;
    [manger POST:API_GET_ALL_TAGS parameters:@{@"email":user.email} progress:^(NSProgress * _Nonnull uploadProgress) {
        
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
        [d deleteObjects:self.tags];
        self.tags = tagsArrM;
        [d addObjects:tagsArrM];
        [d commitWriteTransaction];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.tableView.mj_header endRefreshing];
            [self.tableView reloadData];
            [self.tableView endLoadingData];
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self.tableView.mj_header endRefreshing];
        [self.tableView endLoadingData];
        
        if (error.code == NSURLErrorCannotConnectToHost){
            // 无网络
        }else if (error.code == NSURLErrorTimedOut){
            // 请求超时
        }
    }];
}

-(void)loadTagViewData{
    [self.tableView initDataWithTitle:@"无标签" descriptionText:@"你没有在任何笔记下添加tag..." didTapButton:^{
        [self getTagData];
    }];
    self.tableView.mj_header = [MJRefreshGifHeader cjRefreshHeader:^{
        
        [self getTagData];
        
    }];
}



- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.backgroundColor = MainBg;
    self.tableView.tableFooterView = [[UIView alloc]init];
    
    [self loadTagViewData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeAcountNoti:) name:CHANGE_ACCOUNT_NOTI object:nil];
    
}

-(void)changeAcountNoti:(NSNotification *)noti{
    self.tags = [self reGetRlmTags];
    [self.tableView reloadData];
    
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
    cell.textLabel.textColor = [UIColor blackColor];
    cell.backgroundColor = [UIColor whiteColor];
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.accessoryView = nil;
    if (row < self.tags.count){
        CJTag *tag = self.tags[row];
        text =tag.tag;
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



-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.tags.count;
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.accessoryView){
        return;
    }
    NSInteger row = indexPath.row;

    CJTag *tag = self.tags[row];
    CJTagNoteVC *tagVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"tagNoteVC"];
    tagVC.tag = tag;
    [self.navigationController pushViewController:tagVC animated:YES];

}





- (nullable UIViewController *)previewingContext:(id <UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location NS_AVAILABLE_IOS(9_0) {

    NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell *)[previewingContext sourceView]];
    //创建要预览的控制器
    CJTagNoteVC *presentationVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"tagNoteVC"];

    presentationVC.tag = self.tags[indexPath.row];
    //指定当前上下文视图Rect
    CGRect rect = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44);
    previewingContext.sourceRect = rect;

    return presentationVC;

}

#pragma mark pop(push)
- (void)previewingContext:(id <UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit NS_AVAILABLE_IOS(9_0) {

    [self showViewController:viewControllerToCommit sender:self];
}

@end
