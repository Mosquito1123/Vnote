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
        NSMutableArray <CJNote *>*arrayM = [NSMutableArray array];
        if ([dict[@"status"] integerValue] == 0){
            for (NSDictionary *d in dict[@"trash_notes"]) {
                CJNote *note = [CJNote noteWithDict:d];
                [arrayM addObject:note];
            }
            self.notes = arrayM;
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
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"More"] style:UIBarButtonItemStylePlain target:self action:@selector(moreBtnClick)];
}
-(void)moreBtnClick{
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    CJWeak(vc)
    CJWeak(self)
    UIAlertAction *edit = [UIAlertAction actionWithTitle:@"编辑" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    UIAlertAction *clear = [UIAlertAction actionWithTitle:@"清空废纸篓" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [weakvc dismissViewControllerAnimated:YES completion:nil];
        AFHTTPSessionManager *manger = [AFHTTPSessionManager manager];
        CJProgressHUD *hud = [CJProgressHUD cjShowWithPosition:CJProgressHUDPositionBothExist timeOut:0 withText:@"删除中..." withImages:nil];
        CJUser *user = [CJUser sharedUser];
        [manger POST:API_CLEAR_TRASH parameters:@{@"email":user.email} progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            [weakself.notes removeAllObjects];
            
            [weakself.tableView reloadData];
            [hud cjShowSuccess:@"删除成功"];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [hud cjShowError:@"删除失败!"];

        }];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [vc addAction:edit];
    [vc addAction:clear];
    [vc addAction:cancel];
    [self presentViewController:vc animated:YES completion:nil];
    
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
