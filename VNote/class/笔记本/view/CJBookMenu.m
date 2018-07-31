//
//  CJBookMenu.m
//  VNote
//
//  Created by ccj on 2018/7/28.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import "CJBookMenu.h"

@interface CJBookMenu()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong) NSMutableArray <CJBook *> *books;
@property(nonatomic,copy)void (^block)(NSIndexPath *indexPath);

@end
@implementation CJBookMenu

+(instancetype)xibBookMenuWithBooks:(NSMutableArray<CJBook *> *)books title:(NSString *)title didClickIndexPath:(void(^)(NSIndexPath *indexPath))block{
    CJBookMenu *bookMenu = [[[NSBundle mainBundle] loadNibNamed:@"CJBookMenu" owner:nil options:nil] lastObject];
    bookMenu.books = books;
    CGFloat height = 400;
    bookMenu.bounds = CGRectMake(0, 0, CJScreenWidth, height);
    bookMenu.tableView.tableFooterView = [[UIView alloc]init];
    
    bookMenu.title = title;
    bookMenu.block = block;
    
    
    return bookMenu;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellId = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    NSString *name = self.books[indexPath.row].name;
    if ([name isEqualToString:self.title]){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    cell.textLabel.text = name;
    return cell;
    
}
- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.books.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [UIView animateWithDuration:0.4 animations:^{
        self.cj_y = -self.cj_height;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        self.show = NO;
        if (self.block){
            self.block(indexPath);
        }
        
    }];
    
    
    
}



@end
