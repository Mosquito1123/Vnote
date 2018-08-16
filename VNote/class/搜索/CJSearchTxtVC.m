//
//  CJSearchTxtVC.m
//  VNote
//
//  Created by ccj on 2018/8/12.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import "CJSearchTxtVC.h"
#import "CJSearchResVC.h"
#import "CJContentVC.h"

@interface CJSearchTxtVC ()<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet CJTableView *tableView;
@property (strong, nonatomic) UISearchBar *searchBar;
@property (nonatomic,strong) NSMutableArray <CJNote *> *notes;
@property (nonatomic,assign) BOOL searchStatus;
@property (nonatomic,strong) NSMutableArray *searchRecords;

@end

@implementation CJSearchTxtVC
-(UISearchBar *)searchBar{
    if (!_searchBar){
        _searchBar = [[UISearchBar alloc]init];
        _searchBar.barTintColor = BlueBg;
        _searchBar.tintColor = BlueBg;
        _searchBar.delegate = self;
        _searchBar.showsCancelButton = YES;
        _searchBar.placeholder = @"输入笔记名、标签名";
        _searchBar.barStyle = UISearchBarStyleMinimal;
        [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UISearchBar class]]].title = @"取消";
        [[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UISearchBar class]]] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,nil] forState:UIControlStateNormal];
        [_searchBar.heightAnchor constraintEqualToConstant:44].active = YES;
    }
    return _searchBar;
}
-(NSMutableArray *)searchRecords{
    if (!_searchRecords){
        NSUserDefaults *userD = [NSUserDefaults standardUserDefaults];
        _searchRecords = [NSMutableArray arrayWithArray:[userD objectForKey:SEARCH_RECORD]];
    }
    return _searchRecords;
}
-(void)setSearchStatus:(BOOL)searchStatus{
    _searchStatus = searchStatus;
    [self.tableView reloadData];
}
-(NSMutableArray<CJNote *> *)notes{
    if (!_notes){
        _notes = [NSMutableArray array];
    }
    return _notes;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UISearchBar class]]].title = @"取消";
    [[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UISearchBar class]]] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,nil] forState:UIControlStateNormal];
    self.navigationItem.titleView = self.searchBar;
    
    [self.searchBar becomeFirstResponder];
    self.searchStatus = NO;
    
}

-(void)viewWillAppear:(BOOL)animated{
    self.searchBar.text = @"";
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (!self.searchStatus){
        static NSString *cellId = @"cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        if (!cell){
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        }
        cell.textLabel.text = self.searchRecords[indexPath.row];
        cell.imageView.image = [UIImage imageNamed:@"时钟"];
        UIButton *accessoryView = [UIButton buttonWithType:UIButtonTypeCustom];
        [accessoryView setImage:[UIImage imageNamed:@"叉号"] forState:UIControlStateNormal];
        [accessoryView sizeToFit];
        CJWeak(self)
        [accessoryView cjRespondTargetForControlEvents:UIControlEventTouchUpInside actionBlock:^(UIControl *control) {
            [weakself.searchRecords removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        }];
        cell.accessoryView = accessoryView;
        return cell;
    }
    static NSString *cellId = @"cell1";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = self.notes[indexPath.row].title;
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (!self.searchStatus){
        return self.searchRecords.count;
    }else{
        return self.notes.count;
    }
    
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.searchBar resignFirstResponder];
    [self.view endEditing:YES];
    if (self.searchStatus){
        CJContentVC *contentVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"contentVC"];
        CJNote *note = self.notes[indexPath.row];
        contentVC.uuid = note.uuid;
        contentVC.noteTitle = note.title;
        contentVC.isMe = YES;
        
        [self.navigationController pushViewController:contentVC animated:YES];
    }else{
        NSString *text = self.searchRecords[indexPath.row];
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        CJUser *user = [CJUser sharedUser];
        CJProgressHUD *hud = [CJProgressHUD cjShowWithPosition:CJProgressHUDPositionBothExist timeOut:0 withText:@"加载中..." withImages:nil];
        CJWeak(self)
        [manager POST:API_SEARCH_NOTE parameters:@{@"email":user.email,@"key":text} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, NSDictionary * _Nullable dic) {
            if ([dic[@"status"] integerValue] == 0){
                [weakself.notes removeAllObjects];
                for (NSDictionary *d in dic[@"key_notes"]) {
                    CJNote *note = [CJNote noteWithDict:d];
                    [weakself.notes addObject:note];
                }
                if (weakself.notes.count){
                    [hud cjHideProgressHUD];
                    CJSearchResVC *vc = [[CJSearchResVC alloc]init];
                    vc.notes = weakself.notes;
                    
                    [weakself.navigationController pushViewController:vc animated:YES];
                }else{
                    [hud cjShowError:@"无记录"];
                }
            }else{
                [hud cjShowError:@"加载失败!"];
            }
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [hud cjShowError:@"加载失败!"];
        }];
    }
}


-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    [searchBar setShowsCancelButton:YES animated:YES];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
    [self.view endEditing:YES];
    [searchBar setShowsCancelButton:NO animated:YES];
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if (!searchText.length){
        self.searchStatus = NO;
    }
}



-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self.searchBar resignFirstResponder];
    [self.view endEditing:YES];
    NSString *text = self.searchBar.text;
    if (!text.length) return;
    // 保存搜索记录
    if (![self.searchRecords containsObject:text]){
        [self.searchRecords addObject:text];
    }
    NSUserDefaults *userD = [NSUserDefaults standardUserDefaults];
    [userD setObject:self.searchRecords forKey:SEARCH_RECORD];
    [userD synchronize];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    CJUser *user = [CJUser sharedUser];
    CJProgressHUD *hud = [CJProgressHUD cjShowWithPosition:CJProgressHUDPositionNavigationBar timeOut:0 withText:@"加载中..." withImages:nil];
    CJWeak(self)
    [manager POST:API_SEARCH_NOTE parameters:@{@"email":user.email,@"key":text} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, NSDictionary *  _Nullable dic) {
        if ([dic[@"status"] integerValue] == 0){
            [weakself.notes removeAllObjects];
            for (NSDictionary *d in dic[@"key_notes"]) {
                CJNote *note = [CJNote noteWithDict:d];
                [weakself.notes addObject:note];
            }
            if (weakself.notes.count){
                weakself.searchStatus = YES;
                [hud cjHideProgressHUD];
            }else{
                [hud cjShowError:@"无记录"];
                [weakself.tableView reloadData];
            }
        }else{
            [hud cjShowError:@"加载失败!"];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [hud cjShowError:@"加载失败!"];
    }];
    
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (!self.searchStatus && self.searchRecords.count){
        UIButton *btn = [[UIButton alloc]init];
        [btn setTitle:@"清空搜索记录" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [btn setTitleColor:BlueBg forState:UIControlStateHighlighted];
        [btn addTarget:self action:@selector(clearSearchRecords) forControlEvents:UIControlEventTouchUpInside];
        [btn sizeToFit];
        return btn;
    }
    return [[UIView alloc]init];
}

-(void)clearSearchRecords{
    [self.searchRecords removeAllObjects];
    NSUserDefaults *userD = [NSUserDefaults standardUserDefaults];
    [userD setObject:self.searchRecords forKey:SEARCH_RECORD];
    [self.tableView reloadData];
}



@end
