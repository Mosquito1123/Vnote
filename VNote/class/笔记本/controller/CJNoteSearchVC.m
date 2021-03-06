//
//  CJNoteSearchView.m
//  VNote
//
//  Created by ccj on 2018/7/17.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import "CJNoteSearchVC.h"
#import "CJNote.h"
#import "CJContentVC.h"
#import "AppDelegate.h"
@interface CJNoteSearchVC()<UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource>
@property (strong, nonatomic) CJSearchBar *search;
@property (weak, nonatomic) IBOutlet CJTableView *tableView;
@property (nonatomic,strong) NSMutableArray <CJNote *>*notes;
@end
@implementation CJNoteSearchVC
-(UISearchBar *)search{
    if (!_search){
        _search = [[CJSearchBar alloc]init];
        _search.barTintColor = BlueBg;
        _search.tintColor = BlueBg;
        _search.delegate = self;
        _search.showsCancelButton = YES;
        _search.placeholder = @"笔记名称";
        _search.barStyle = UISearchBarStyleMinimal;
        
        
        [[self.search.heightAnchor constraintEqualToConstant:44.0] setActive:YES];
        
        
    }
    
    return _search;
}

-(NSMutableArray *)notes{
    if(!_notes){
        _notes = [NSMutableArray array];
    }
    return _notes;
}
-(void)getData{
    for (CJNote *n in self.noteArrM) {
        if ([n.title containsString:self.search.text]){
            [self.notes addObject:n];
        }
    }
    [self.tableView.mj_header endRefreshing];
    [self.tableView reloadData];
    [self.tableView endLoadingData];
    
    
}

-(void)viewDidLoad{
    [super viewDidLoad];
    self.navigationItem.titleView = self.search;
    [self.search becomeFirstResponder];
    self.search.delegate = self;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    CJWeak(self)
    self.tableView.tableFooterView = [[UIView alloc]init];
    self.tableView.mj_header = [MJRefreshGifHeader cjRefreshWithPullType:CJPullTypeNormal header:^{
        [weakself getData];
    }];
    
    [self.tableView initDataWithTitle:@"无结果" descriptionText:@"没有搜索到符合笔记..." didTapButton:^{
        [weakself getData];
    }];
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.notes.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    UIResponder *responder = [[tableView superview] superview];
    UINavigationController *navc;
    while ((responder = [responder nextResponder])) {
        if ([responder isKindOfClass:[UINavigationController class]]) {
            navc = (UINavigationController *)responder;
            break;
        }
    }
    
    CJContentVC *contentVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"contentVC"];
    CJNote *note = self.notes[indexPath.row];
    if ([note isInvalidated])return;
    contentVC.note = note;
    contentVC.isMe = YES;
    [self.navigationController pushViewController:contentVC animated:YES];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellID = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    CJNote *note = self.notes[indexPath.row];
    cell.textLabel.text = note.title;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    if (!searchBar.text.length){
        return;
    }
    
    [self.tableView.mj_header beginRefreshing];

}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:NO completion:nil];
    
    
}

@end
