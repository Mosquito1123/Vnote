//
//  CJAddNoteVC.m
//  VNote
//
//  Created by ccj on 2018/7/14.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import "CJAddNoteVC.h"
#import "CJTitleView.h"
#import "CJBookMenuVC.h"
@interface CJAddNoteVC ()<UIPopoverPresentationControllerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *noteTitle;
@property (weak, nonatomic) IBOutlet CJTextView *contentT;
@property (strong,nonatomic) NSMutableArray<CJBook *> *books;
@property(nonatomic,strong) CJTitleView *titleView;
@property(nonatomic,strong) NSIndexPath *selectIndexPath;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneBtn;

@end

@implementation CJAddNoteVC


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
    CJWeak(self)
    CJProgressHUD *hud = [CJProgressHUD cjShowInView:self.view timeOut:TIME_OUT withText:@"加载中..." withImages:nil];
    [CJAPI addNoteWithParams:@{@"book_uuid":book_uuid,@"note_title":title,@"content":content,@"tags":@"[]"} success:^(NSDictionary *dic) {
        if ([dic[@"status"] integerValue] == 0){
            [hud cjShowSuccess:@"创建成功"];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakself dismissViewControllerAnimated:YES completion:nil];
            });
            
        }
    } failure:^(NSError *error) {
        [hud cjShowError:net101code];
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
    CJWeak(self)
    if (self.bookTitle){
        __block NSUInteger index = 0;
        [self.books enumerateObjectsUsingBlock:^(CJBook * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([weakself.bookTitle isEqualToString:obj.name]){
                index = idx;
                *stop = YES;
            }
        }];
        self.selectIndexPath = [NSIndexPath indexPathForRow:index inSection:0];
    }
    
    CJTitleView *titleView;
    titleView = [[CJTitleView alloc]initWithTitle:text click:^{
        CJBookMenuVC *vc = [[CJBookMenuVC alloc]init];
        vc.books = weakself.books;
        vc.indexPath = weakself.selectIndexPath;
        vc.selectIndexPath = ^(NSIndexPath *indexPath){
            weakself.selectIndexPath = indexPath;
            weakself.titleView.title = weakself.books[indexPath.row].name;
        };
        NSInteger c = weakself.books.count;
        NSInteger max = 6,count = c;
        
        if (c > max){
            count = max;
        }else{
            count = c;
        }
        
        CGFloat menuH = (max + 1) * 40.0;
    
        vc.preferredContentSize = CGSizeMake(0, menuH);
        vc.modalPresentationStyle = UIModalPresentationPopover;
        UIPopoverPresentationController *popController = vc.popoverPresentationController;
        popController.backgroundColor = [UIColor whiteColor];
        popController.delegate = weakself;
        popController.permittedArrowDirections = UIPopoverArrowDirectionUp;
        popController.sourceView = weakself.navigationItem.titleView;
        popController.sourceRect = weakself.navigationItem.titleView.bounds;
        
        [weakself presentViewController:vc animated:YES completion:nil];
        
    }];
    self.navigationItem.titleView = titleView;
    
    self.titleView = titleView;
}
-(UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
    return UIModalPresentationNone;
}



@end
