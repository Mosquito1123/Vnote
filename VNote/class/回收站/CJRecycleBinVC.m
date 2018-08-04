//
//  CJRecycleBinVC.m
//  VNote
//
//  Created by ccj on 2018/8/3.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import "CJRecycleBinVC.h"

@interface CJRecycleBinVC ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet CJTableView *tableView;
@property(nonatomic,strong) NSMutableArray <CJNote *> *notes;
@end

@implementation CJRecycleBinVC
-(NSMutableArray<CJNote *> *)notes{
    if (!_notes){
        _notes = [NSMutableArray array];
    }
    return _notes;
}

-(void)getData{
    AFHTTPSessionManager *manger = [AFHTTPSessionManager manager];
    CJUser *user = [CJUser sharedUser];
    [manger POST:API_GET_TRASH_NOTES parameters:@{@"email":user.email} progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dict = responseObject;
        
        if ([dict[@"status"] integerValue] == 0){
            for (NSDictionary *d in dict[@"trash_notes"]) {
                CJNote *note = [CJNote noteWithDict:d];
                [self.notes addObject:note];
            }
            
            [self.tableView reloadData];
        }
        [self.tableView endLoadingData];
        [self.tableView.mj_header endRefreshing];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self.tableView endLoadingData];
        [self.tableView.mj_header endRefreshing];

    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"回收站";
    self.tableView.tableFooterView = [[UIView alloc]init];
    self.tableView.mj_header = [MJRefreshGifHeader cjRefreshHeader:^{
        [self getData];
    }];
    [self.tableView initDataWithTitle:@"无笔记..." descriptionText:@"空空如也..." didTapButton:^{
        [self getData];
    }];
    [self.tableView.mj_header beginRefreshing];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.notes.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellId = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    
    cell.textLabel.text = self.notes[indexPath.row].title;
    return cell;
}



@end
