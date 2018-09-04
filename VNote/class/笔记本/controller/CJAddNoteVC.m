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
@property(nonatomic,strong) NSIndexPath *selectIndexPath;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneBtn;

@end

@implementation CJAddNoteVC

-(CJBookMenu *)menu{
    if (!_menu){
        _menu = [CJBookMenu xibBookMenuWithBooks:self.books title:self.titleView.title didClickIndexPath:^(NSIndexPath *indexPath) {
            NSString *title = self.books[indexPath.row].name;
            self.titleView.title = title;
            _menu.title = title;
            [_menu.tableView reloadData];
            self.selectIndexPath = indexPath;
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
    NSString *book_uuid = self.books[self.selectIndexPath.row].uuid;
    NSString *title = self.noteTitle.text;
    NSString *content = self.contentT.text;
    if (!title) return;
    CJProgressHUD *hud = [CJProgressHUD cjShowWithPosition:CJProgressHUDPositionNavigationBar timeOut:0 withText:@"加载中..." withImages:nil];
    
    [CJAPI addNoteWithParams:@{@"book_uuid":book_uuid,@"note_title":title,@"content":content,@"tags":@"[]"} success:^(NSDictionary *dic) {
        if ([dic[@"status"] integerValue] == 0){
            [hud cjShowSuccess:@"创建成功"];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self dismissViewControllerAnimated:YES completion:nil];
            });
            
        }
    } failure:^(NSError *error) {
        
    }];
    
    
}
-(void)textChange{
    self.doneBtn.enabled = self.noteTitle.text.length;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.doneBtn.enabled = NO;
    self.contentT.placeholder = @"开始书写";
    [self.noteTitle addTarget:self action:@selector(textChange) forControlEvents:UIControlEventEditingChanged];
    NSString *text = self.bookTitle ? self.bookTitle:self.books[0].name;
    CJTitleView *titleView = [[CJTitleView alloc]initWithTitle:text click:^{
        self.selectIndexPath = [NSIndexPath indexPathWithIndex:0];
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
