//
//  CJPenNoteVC.m
//  VNote
//
//  Created by ccj on 2018/7/22.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import "CJPenNoteVC.h"
#import "CJNote.h"
#import "CJContentVC.h"
@interface CJPenNoteVC ()<UITableViewDelegate,UITableViewDataSource,DZNEmptyDataSetSource,DZNEmptyDataSetDelegate>
@property (weak, nonatomic) IBOutlet CJTableView *tableView;

@end

@implementation CJPenNoteVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = self.bookTitle;
    self.tableView.tableFooterView = [[UIView alloc]init];
    [self.tableView initDataWithTitle:@"该好友无笔记" descriptionText:@"" didTapButton:^{
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        [manager POST:API_BOOK_DETAIL parameters:@{@"email":self.email,@"book_uuid":self.book_uuid} progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, NSDictionary *  _Nullable responseObject) {
            NSArray *res = responseObject[@"res"];
            NSMutableArray *notes = [NSMutableArray array];
            for (NSDictionary *dic in res){
                CJNote *note = [CJNote noteWithDict:dic];
                [notes addObject:note];
            }
            self.notes = notes;
            [self.tableView reloadData];
            [self.tableView endLoadingData];
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [self.tableView endLoadingData];

        }];
    }];
    
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellID = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    cell.textLabel.text = self.notes[indexPath.row].title;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.notes.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CJContentVC *contentVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"contentVC"];
    CJNote *note = self.notes[indexPath.row];
    contentVC.uuid = note.uuid;
    contentVC.title = note.title;
    contentVC.isMe = NO;
    
    [self.navigationController pushViewController:contentVC animated:YES];
    
}

@end
