//
//  CJRecentVC.m
//  VNote
//
//  Created by ccj on 2018/7/31.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import "CJRecentVC.h"
#import "CJContentVC.h"
@interface CJRecentVC ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet CJTableView *tableView;
@property(nonatomic,strong) NSMutableArray <CJNote *> *notes;
@end

@implementation CJRecentVC

-(void)getData{
    CJUser *user = [CJUser sharedUser];
    AFHTTPSessionManager *manger = [AFHTTPSessionManager manager];
    
    
    [manger POST:API_RECENT_NOTES parameters:@{@"email":user.email} progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dict = responseObject;
        NSMutableArray *array = [NSMutableArray array];
        if ([dict[@"status"] integerValue] == 0){
            for (NSDictionary *d in dict[@"recent_notes"]) {
                CJNote *note = [CJNote noteWithDict:d];
                [array addObject:note];
            }
            self.notes = array;
        }
        [self.tableView.mj_header endRefreshing];
        [self.tableView reloadData];
        [self.tableView endLoadingData];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self.tableView endLoadingData];
        [self.tableView.mj_header endRefreshing];
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc]init];
    [self.tableView initDataWithTitle:@"无笔记" descriptionText:@"最近没有更新过笔记..." didTapButton:^{
        [self getData];
    }];
    self.tableView.mj_header = [MJRefreshGifHeader cjRefreshHeader:^{
        [self getData];
    }];
    [self.tableView.mj_header beginRefreshing];
}


- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    static NSString *cellId = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = self.notes[indexPath.row].title;
    return cell;
    
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.notes.count;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CJContentVC *contentVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"contentVC"];
    CJNote *note = self.notes[indexPath.row];
    contentVC.uuid = note.uuid;
    contentVC.title = note.title;
    contentVC.isMe = YES;
    
    [self.navigationController pushViewController:contentVC animated:YES];
}


@end
