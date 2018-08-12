//
//  CJSearchVC.m
//  VNote
//
//  Created by ccj on 2018/7/31.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import "CJSearchVC.h"
#import "CJSearchTxtVC.h"
#import "CJSearchResVC.h"
@interface CJSearchVC ()<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet CJTableView *tableView;
@property (strong, nonatomic) UISearchBar *searchBar;
@property (nonatomic,strong) NSMutableArray *searchRecords;
@property (nonatomic,strong) NSMutableArray <CJNote *> *notes;
@end

@implementation CJSearchVC
-(NSMutableArray<CJNote *> *)notes{
    if (!_notes){
        _notes = [NSMutableArray array];
    }
    return _notes;
}
-(NSMutableArray *)searchRecords{
    if (!_searchRecords){
        NSUserDefaults *userD = [NSUserDefaults standardUserDefaults];
        _searchRecords = [NSMutableArray arrayWithArray:[userD objectForKey:SEARCH_RECORD]];
    }
    return _searchRecords;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"搜索";
    self.tableView.tableFooterView = [[UIView alloc]init];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"搜索白"] style:UIBarButtonItemStylePlain target:self action:@selector(searchClick)];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateSearchRecord:) name:UPDATE_SEARCH_RECORD_NOTI object:nil];
}
-(void)updateSearchRecord:(NSNotification *)noti{
    if ([noti.name isEqualToString:UPDATE_SEARCH_RECORD_NOTI]){
        [self.tableView reloadData];
    }
}

-(void)searchClick{
    CJSearchTxtVC *vc = [[CJSearchTxtVC alloc]init];
    vc.searchRecords = self.searchRecords;
    [self presentViewController:vc animated:NO completion:nil];
    
}



-(void)viewDidAppear:(BOOL)animated{
    [self.searchBar becomeFirstResponder];
}

-(void)viewWillDisappear:(BOOL)animated{
    [self.view endEditing:YES];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
        static NSString *cellId = @"cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        if (!cell){
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        }
        cell.textLabel.text = self.searchRecords[indexPath.row];
        return cell;
    
    
    
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.searchRecords.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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



@end
