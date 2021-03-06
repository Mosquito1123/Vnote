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
#import "CJNote.h"
@interface CJAddNoteVC ()<UIPopoverPresentationControllerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *noteTitle;
@property (weak, nonatomic) IBOutlet CJTextView *contentT;
@property (strong,nonatomic) NSMutableArray<CJBook *> *books;
@property(nonatomic,strong) CJTitleView *titleView;
@property(nonatomic,strong) NSIndexPath *selectIndexPath;
@property(nonatomic,strong) CJBookMenuVC *bookMenuVC;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomMargin;

@end

@implementation CJAddNoteVC
-(void)reload{
    self.noteTitle.text = @"";
    self.contentT.text = @"";
    [self.contentT setNeedsDisplay];
}

-(NSMutableArray *)reGetRlmBooks{
    RLMRealm *rlm = [CJRlm shareRlm];
    NSMutableArray *array = [NSMutableArray array];
    
    NSMutableArray *books= [CJBook cjAllObjectsInRlm:rlm];
    for (CJBook *b in books) {
        if ([b.name isEqualToString:@"Trash"] || [b.name isEqualToString:@"All Notes"] || [b.name isEqualToString:@"Recents"]){
            continue;
        }
        [array addObject:b];
    }
    return array;
}
- (IBAction)cancel:(id)sender {
    CJLeftSliderVC *vc = (CJLeftSliderVC *)[UIApplication sharedApplication].keyWindow.rootViewController;
    [vc hiddenLeftViewAnimation];
}

- (IBAction)done:(id)sender {
    [self.view endEditing:YES];
    self.books = [self reGetRlmBooks];
    CJBook *book = self.books[self.selectIndexPath.row];
    if ([book isInvalidated])return;
    NSString *book_uuid = book.uuid;
    NSString *title = self.noteTitle.text;
    NSString *content = self.contentT.text;
    if (!title) return;
    CJWeak(self)
    CJProgressHUD *hud = [CJProgressHUD cjShowInView:self.view timeOut:TIME_OUT withText:@"加载中..." withImages:nil];
    [CJAPI requestWithAPI:API_ADD_NOTE params:@{@"book_uuid":book_uuid,@"note_title":title,@"content":content,@"tags":@"[]",@"email":[CJUser sharedUser].email} success:^(NSDictionary *dic) {
        [hud cjShowSuccess:@"创建成功"];
        //
        CJNote *note = [CJNote noteWithDict:dic];
        [CJRlm addObject:note];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTE_CHANGE_NOTI object:nil];
        [weakself.view endEditing:YES];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            CJLeftSliderVC *vc = (CJLeftSliderVC *)[UIApplication sharedApplication].keyWindow.rootViewController;
            [vc hiddenLeftViewAnimation];
            
            // 创建笔记成功，s清空title和content
            [self reload];
        });
    } failure:^(NSDictionary *dic) {
        [hud cjShowError:dic[@"msg"]];
    } error:^(NSError *error) {
        [hud cjShowError:net101code];
    }];
}
-(void)textChange{
    self.doneBtn.enabled = self.noteTitle.text.length;
}

-(void)viewWillAppear:(BOOL)animated{
    
    //监听当键盘将要出现时
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    //监听当键将要退出时
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

//当键盘出现
- (void)keyboardWillShow:(NSNotification *)notification
{
    //获取键盘的高度
    NSDictionary *userInfo = [notification userInfo];
    NSValue *value = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [value CGRectValue];
    CGFloat height = keyboardRect.size.height;
    self.bottomMargin.constant = -height;
    [self.view layoutIfNeeded];
}

//当键退出
- (void)keyboardWillHide:(NSNotification *)notification
{
    self.bottomMargin.constant = 0;
    [self.view layoutIfNeeded];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

-(void)bookChange{
    _books = nil;
    self.bookMenuVC.books = self.books;
    [self.bookMenuVC reloadData];
    self.bookMenuVC.preferredContentSize = CGSizeMake(CJScreenWidth * 0.5, [self getMenuHeightWithCount:self.books.count]);
    
    NSString *text;
    if (self.books.count > 0){
        if ([self.books[0] isInvalidated])return;
        text = self.bookTitle ? self.bookTitle:self.books[0].name;
    }else{
        text = self.bookTitle;
    }
    self.titleView.title = text;
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
}
-(NSMutableArray<CJBook *> *)books{
    if (!_books){
        _books = [self reGetRlmBooks];
    }
    return _books;
}

-(CGFloat)getMenuHeightWithCount:(NSInteger)count{
    NSInteger max = 6;
    
    if (count > max){
        count = max;
    }
    CGFloat menuH = (count) * 40.0 + 20;
    return menuH;
}

-(CJBookMenuVC *)bookMenuVC{
    if (!_bookMenuVC){
        CJBookMenuVC *vc = [[CJBookMenuVC alloc]init];
        vc.books = self.books;
        vc.indexPath = self.selectIndexPath;
        CJWeak(self)
        vc.selectIndexPath = ^(NSIndexPath *indexPath){
            weakself.selectIndexPath = indexPath;
            if ([weakself.books[indexPath.row] isInvalidated]) return ;
            weakself.titleView.title = weakself.books[indexPath.row].name;
        };
        vc.preferredContentSize = CGSizeMake(CJScreenWidth * 0.5, [self getMenuHeightWithCount:weakself.books.count]);
        vc.modalPresentationStyle = UIModalPresentationPopover;
        _bookMenuVC = vc;
    }
    return _bookMenuVC;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.doneBtn.enabled = NO;
    self.contentT.placeholder = @"开始书写";
    [self.noteTitle addTarget:self action:@selector(textChange) forControlEvents:UIControlEventEditingChanged];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(bookChange) name:LOGIN_ACCOUT_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bookChange) name:BOOK_CHANGE_NOTI object:nil];
    
    CJWeak(self)
    NSString *text;
    if (self.books.count > 0){
        if ([self.books[0] isInvalidated])return;
        text = self.bookTitle ? self.bookTitle:self.books[0].name;
    }else{
        text = self.bookTitle;
    }
    CJTitleView *titleView;
    titleView = [[CJTitleView alloc]initWithTitle:text click:^{
        UIPopoverPresentationController *popController = weakself.bookMenuVC.popoverPresentationController;
        popController.backgroundColor = [UIColor whiteColor];
        popController.delegate = weakself;
        popController.permittedArrowDirections = UIPopoverArrowDirectionUp;
        popController.sourceView = weakself.navigationItem.titleView;
        popController.sourceRect = weakself.navigationItem.titleView.bounds;
        [weakself presentViewController:weakself.bookMenuVC animated:YES completion:nil];
    }];
    self.navigationItem.titleView = titleView;
    self.titleView = titleView;
}


-(void)viewWillLayoutSubviews{
    [self.navigationItem.titleView setNeedsLayout];
    self.bookMenuVC.preferredContentSize = CGSizeMake(CJScreenWidth * 0.5, self.bookMenuVC.preferredContentSize.height);
}

-(UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
    return UIModalPresentationNone;
}



@end
