//
//  CJNoteSearchView.m
//  VNote
//
//  Created by ccj on 2018/7/17.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import "CJNoteSearchView.h"
#import "CJNote.h"
@interface CJNoteSearchView()<UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UISearchBar *search;
@property (weak, nonatomic) IBOutlet CJTableView *tableView;
@property (nonatomic,strong) NSMutableArray <CJNote *>*notes;
@end
@implementation CJNoteSearchView
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
    self.tableView.emtyHide = NO;
    
}

+(instancetype)xibNoteSearchView{
    CJNoteSearchView *view = [[[NSBundle mainBundle]loadNibNamed:@"CJNoteSearchView" owner:nil options:nil] lastObject];
    view.search.barTintColor = BlueBg;
    view.search.layer.borderWidth = 0;
    [view.search becomeFirstResponder];
    [[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UISearchBar class]]] setTintColor:[UIColor whiteColor]];
    [[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UISearchBar class]]] setTitle:@"取消"];
    view.search.delegate = view;
    view.tableView.delegate = view;
    view.tableView.dataSource = view;
    view.tableView.tableFooterView = [[UIView alloc]init];
    view.tableView.mj_header = [MJRefreshGifHeader cjRefreshHeader:^{
        [view getData];
    }];
    [view.tableView initDataWithTitle:@"无结果" descriptionText:@"没有搜索到符合笔记..." didTapButton:^{
        [view getData];
    }];
    view.tableView.emtyHide = YES;
    return view;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.notes.count;
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
    CJNoteSearchView *view = (CJNoteSearchView *)[searchBar superview];
    [view.tableView.mj_header beginRefreshing];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    CJNoteSearchView *view = (CJNoteSearchView *)[searchBar superview];
    [view removeFromSuperview];
}

@end
