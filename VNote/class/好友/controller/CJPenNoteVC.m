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
#import "CJNoteCell.h"
@interface CJPenNoteVC ()<UITableViewDelegate,UITableViewDataSource,DZNEmptyDataSetSource,DZNEmptyDataSetDelegate>
@property (weak, nonatomic) IBOutlet CJTableView *tableView;

@end

@implementation CJPenNoteVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = self.bookTitle;
    self.tableView.tableFooterView = [[UIView alloc]init];
    CJWeak(self)
    [self.tableView initDataWithTitle:@"无笔记" descriptionText:@"该笔记本下无笔记" didTapButton:^{
        [CJAPI bookDetailWithParams:@{@"email":self.email,@"book_uuid":self.book_uuid} success:^(NSDictionary *dic) {
            NSArray *res = dic[@"res"];
            NSMutableArray *notes = [NSMutableArray array];
            for (NSDictionary *dic in res){
                CJNote *note = [CJNote noteWithDict:dic];
                [notes addObject:note];
            }
            weakself.notes = notes;
            [weakself.tableView reloadData];
            [weakself.tableView endLoadingData];
        } failure:^(NSError *error) {
            [weakself.tableView endLoadingData];
        }];
    }];
    [self.tableView registerNib:[UINib nibWithNibName:@"CJNoteCell" bundle:nil] forCellReuseIdentifier:@"cell"];
    
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CJNoteCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (!cell){
        cell = [CJNoteCell xibWithNoteCell];
    }
    NSInteger row = indexPath.row;
    CJNote *note = self.notes[row];
    
    cell.titleL.text = note.title;
    cell.updateTimeL.text = [NSDate cjDateSince1970WithSecs:note.updated_at formatter:@"YYYY/MM/dd"];
    return cell;
    
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
    contentVC.noteTitle = note.title;
    contentVC.isMe = NO;
    
    [self.navigationController pushViewController:contentVC animated:YES];
    
}

@end
