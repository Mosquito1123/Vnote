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
@interface CJTagNoteVC ()<UITableViewDelegate,UITableViewDataSource,DZNEmptyDataSetSource,DZNEmptyDataSetDelegate>
@property (weak, nonatomic) IBOutlet CJTableView *tableView;

@property(nonatomic,strong)NSMutableArray *notesArrM;
@end

@implementation CJTagNoteVC
-(NSMutableArray *)notesArrM{
    if (!_notesArrM){
        _notesArrM = [NSMutableArray array];
        CJUser *user = [CJUser sharedUser];
        RLMRealm *rlm = [CJRlm cjRlmWithName:user.email];
        RLMResults <CJNote *> * notes = [CJNote allObjectsInRealm:rlm];
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
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellId = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        
    }
    CJNote *note = self.notesArrM[indexPath.row];
    cell.textLabel.text = note.title;
    cell.imageView.image = [UIImage imageNamed:@"笔记灰"];
    return cell;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.notesArrM.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CJContentVC *contentVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"contentVC"];
    CJNote *note = self.notesArrM[indexPath.row];
    contentVC.uuid = note.uuid;
    contentVC.noteTitle = note.title;
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
