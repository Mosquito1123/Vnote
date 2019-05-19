//
//  CJTagVC.m
//  VNote
//
//  Created by ccj on 2018/6/25.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import "CJTagNoteVC.h"
#import "CJNote.h"
#import "CJContentVC.h"
#import "CJTag.h"
#import "CJNoteCell.h"
@interface CJTagNoteVC ()<UITableViewDelegate,UITableViewDataSource,DZNEmptyDataSetSource,DZNEmptyDataSetDelegate>
@property (weak, nonatomic) IBOutlet CJTableView *tableView;

@property(nonatomic,strong)NSMutableArray *notesArrM;
@end

@implementation CJTagNoteVC
-(NSMutableArray *)notesArrM{
    if (!_notesArrM){
        _notesArrM = [NSMutableArray array];
        RLMRealm *rlm = [CJRlm shareRlm];
        NSMutableArray *notes = [CJNote cjAllObjectsInRlm:rlm];
        for (CJNote *n in notes) {
            NSData *data = [n.tags dataUsingEncoding:NSUTF8StringEncoding];
            NSArray *array = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            
            if ([array containsObject:self.tag.tag]){
                [_notesArrM addObject:n];
            }
        }
    }
    return _notesArrM;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = [NSString stringWithFormat:@"#%@",self.tag.tag];
    self.tableView.tableFooterView = [[UIView alloc]init];
    [self.tableView registerNib:[UINib nibWithNibName:@"CJNoteCell" bundle:nil] forCellReuseIdentifier:@"cell"];
    self.tableView.rowHeight = [CJNoteCell height];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellId = @"cell";
    CJNoteCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell){
        cell = [CJNoteCell xibWithNoteCell];
        
    }
    CJNote *note = self.notesArrM[indexPath.row];
    if ([note isInvalidated])return cell;
    [cell setUI:note];
    cell.accessoryView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"more"]];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithCjGestureRecognizer:^(UIGestureRecognizer *gesture) {
        [cell showSwipe:MGSwipeDirectionRightToLeft animated:YES];
        return;
    }];
    cell.accessoryView.userInteractionEnabled = YES;
    [cell.accessoryView addGestureRecognizer:tap];
    CJWeak(self)
    MGSwipeButton *link = [MGSwipeButton buttonWithTitle:@"复制链接" backgroundColor:CopyColor callback:^BOOL(MGSwipeTableCell * _Nonnull cell) {
        UIPasteboard *pasteB = [UIPasteboard generalPasteboard];
        CJNote *n = weakself.notesArrM[indexPath.row];
        pasteB.string = NOTE_DETAIL_WEB_LINK(n.uuid);
        [CJProgressHUD cjShowSuccessWithPosition:CJProgressHUDPositionNavigationBar withText:@"复制成功"];
        return YES;
    }];
    cell.rightButtons = @[link];
    return cell;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.notesArrM.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CJContentVC *contentVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"contentVC"];
    CJNote *note = self.notesArrM[indexPath.row];
    if (note.isInvalidated){
        self.notesArrM = nil;
        [self.tableView reloadData];
        
    }
    contentVC.note = note;
    contentVC.isMe = YES;
    [self.navigationController pushViewController:contentVC animated:YES];
}

- (NSArray<id<UIPreviewActionItem>> *)previewActionItems {
    
    NSMutableArray *arrItem = [NSMutableArray array];
    
    UIPreviewAction *previewAction0 = [UIPreviewAction actionWithTitle:@"取消" style:UIPreviewActionStyleDestructive handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
        
        NSLog(@"didClickCancel");
    }];
    
    
    [arrItem addObjectsFromArray:@[previewAction0]];
    
    return arrItem;
}


@end
