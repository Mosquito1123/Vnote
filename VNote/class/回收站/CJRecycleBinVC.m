//
//  CJRecycleBinVC.m
//  VNote
//
//  Created by ccj on 2018/8/3.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import "CJRecycleBinVC.h"
#import "CJMoveNoteVC.h"
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
    
    self.rt_navigationController.tabBarItem.title = @"回收站";
    self.rt_navigationController.tabBarItem.image = [UIImage imageNamed:@"垃圾灰"];
    self.rt_navigationController.tabBarItem.selectedImage = [UIImage imageNamed:@"垃圾蓝"];
    self.tableView.tableFooterView = [[UIView alloc]init];
    self.tableView.mj_header = [MJRefreshGifHeader cjRefreshHeader:^{
        [self getData];
    }];
    [self.tableView initDataWithTitle:@"无笔记..." descriptionText:@"空空如也..." didTapButton:^{
        [self getData];
    }];
    [self.tableView.mj_header beginRefreshing];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"垃圾侧"] style:UIBarButtonItemStylePlain target:self action:@selector(clearBtnClick)];
    
}
-(void)clearBtnClick{
    
    CJWeak(self)
    AFHTTPSessionManager *manger = [AFHTTPSessionManager manager];
    CJProgressHUD *hud = [CJProgressHUD cjShowWithPosition:CJProgressHUDPositionBothExist timeOut:0 withText:@"删除中..." withImages:nil];
    CJUser *user = [CJUser sharedUser];
    [manger POST:API_CLEAR_TRASH parameters:@{@"email":user.email} progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [weakself.notes removeAllObjects];
        
        [weakself.tableView reloadData];
        [hud cjShowSuccess:@"已清空"];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [hud cjShowError:@"清空失败!"];

    }];



    
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

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
    
}

-(NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewRowAction *del = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        AFHTTPSessionManager *manger = [AFHTTPSessionManager manager];
        CJNote *note = self.notes[indexPath.row];
        CJProgressHUD *hud = [CJProgressHUD cjShowWithPosition:CJProgressHUDPositionNavigationBar timeOut:0 withText:@"删除中..." withImages:nil];
        [manger POST:API_DEL_NOTE_4ERVER parameters:@{@"note_uuid":note.uuid} progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [self.notes removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
            [hud cjShowSuccess:@"删除成功"];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [hud cjShowError:@"删除失败!"];
            
        }];
    }];
    CJWeak(self)
    UITableViewRowAction *move = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"移动" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        CJMoveNoteVC *vc = [[CJMoveNoteVC alloc]init];
        vc.bookTitle = @"";
        vc.selectIndexPath = ^(NSString *book_uuid){
            AFHTTPSessionManager *manger = [AFHTTPSessionManager manager];
            CJNote *note = self.notes[indexPath.row];
            CJProgressHUD *hud = [CJProgressHUD cjShowWithPosition:CJProgressHUDPositionNavigationBar timeOut:0 withText:@"移动中..." withImages:nil];
            [manger POST:API_MOVE_NOTE parameters:@{@"note_uuid":note.uuid,@"book_uuid":book_uuid} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                [weakself.notes removeObjectAtIndex:indexPath.row];
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
                [hud cjShowSuccess:@"移动成功"];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                [hud cjShowError:@"移动失败!"];
                
            }];
        };
        [weakself presentViewController:vc animated:YES completion:nil];
        
    }];
    move.backgroundColor = BlueBg;
    return @[del,move];
    
    
}



@end
