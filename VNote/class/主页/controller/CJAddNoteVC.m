//
//  CJAddNoteVC.m
//  VNote
//
//  Created by ccj on 2018/7/14.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import "CJAddNoteVC.h"
#import "CJTitleView.h"
#import "CJBookMenu.h"
@interface CJAddNoteVC ()
@property (weak, nonatomic) IBOutlet UITextField *noteTitle;
@property (weak, nonatomic) IBOutlet CJTextView *contentT;
@property (strong,nonatomic) NSMutableArray<CJBook *> *books;
@property (strong,nonatomic) CJBookMenu *menu;
@property(nonatomic,strong) UIView *maskView;
@property(nonatomic,strong) CJTitleView *titleView;



@end

@implementation CJAddNoteVC

-(CJBookMenu *)menu{
    if (!_menu){
        _menu = [CJBookMenu xibBookMenuWithBooks:self.books title:self.titleView.title didClickIndexPath:^(NSIndexPath *indexPath) {
            NSString *title = self.books[indexPath.row].name;
            self.titleView.title = title;
            _menu.title = title;
            [_menu.tableView reloadData];
            [self.maskView removeFromSuperview];
        }];
        _menu.cj_y = - _menu.cj_height;
        _menu.cj_x = 0;
        
    }
    return _menu;
    
}
-(UIView *)maskView{
    if (!_maskView){
        _maskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CJScreenWidth, CJScreenHeight)];
        
        _maskView.backgroundColor = [UIColor grayColor];
        
        
    }
    return _maskView;
}

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

-(NSMutableArray *)books{
    if (!_books){
        // 从数据库中读取
        _books = [self reGetRlmBooks];
    }
    return _books;
}


- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)done:(id)sender {
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.contentT.placeholder = @"开始书写";
    CJTitleView *titleView = [[CJTitleView alloc]initWithTitle:self.books[0].name click:^{
        
        if (self.menu.show) {
            [UIView animateWithDuration:0.4 animations:^{
                self.menu.cj_y = -self.menu.cj_height;
            } completion:^(BOOL finished) {
                [self.menu removeFromSuperview];
                [self.maskView removeFromSuperview];
                self.menu.show = NO;
            }];
            return ;
        }
        [self.view addSubview:self.maskView];
        [self.maskView addSubview:self.menu];
        
        [UIView animateWithDuration:0.3 animations:^{
            self.menu.cj_y = 0;
            
        }];
        self.menu.show = YES;
        
    }];
    self.navigationItem.titleView = titleView;
    
    self.titleView = titleView;
}


@end
