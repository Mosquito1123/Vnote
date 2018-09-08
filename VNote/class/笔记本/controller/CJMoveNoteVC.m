//
//  CJMoveNoteVC.m
//  VNote
//
//  Created by ccj on 2018/8/11.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import "CJMoveNoteVC.h"

@interface CJMoveNoteVC ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic,strong) NSMutableArray <CJBook *> *books;
@end

@implementation CJMoveNoteVC

-(NSMutableArray *)reGetRlmBooks{
    CJUser *user = [CJUser sharedUser];
    RLMRealm *rlm = [CJRlm cjRlmWithName:user.email];
    NSMutableArray *array = [NSMutableArray array];
    
    RLMResults <CJBook *>*books= [CJBook allObjectsInRealm:rlm];
    for (CJBook *b in books) {
        if ([b.name isEqualToString:@"Trash"] || [b.name isEqualToString:@"All Notes"] || [b.name isEqualToString:@"Recents"]){
            continue;
        }
        [array addObject:b];
    }
    return array;
}

-(NSMutableArray<CJBook *> *)books{
    if (!_books){
        // 从数据库中读取
        _books = [self reGetRlmBooks];
    }
    return _books;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc]init];
    self.navigationItem.title = @"移动笔记";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(close)];
}
- (void)close {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellId = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    CJBook *book = self.books[indexPath.row];
    cell.textLabel.text = book.name;
    cell.accessoryType = UITableViewCellAccessoryNone;
    if ([book.name isEqualToString:self.bookTitle]){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    return cell;
    
    
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.books.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CJBook *book = self.books[indexPath.row];
    if ([self.bookTitle isEqualToString:book.name]) return;
    [self dismissViewControllerAnimated:YES completion:nil];
    if (self.selectIndexPath)self.selectIndexPath(book.uuid);
}



@end

