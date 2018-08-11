//
//  CJSearchVC.m
//  VNote
//
//  Created by ccj on 2018/7/31.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import "CJSearchVC.h"
#import "CJSearchBar.h"
@interface CJSearchVC ()<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet CJTableView *tableView;
@property (strong, nonatomic) CJSearchBar *searchBar;

@end

@implementation CJSearchVC


-(CJSearchBar *)searchBar{
    if (!_searchBar){
        _searchBar = [[CJSearchBar alloc]initWithFrame:CGRectMake(0, 0, CJScreenWidth, 64)];
        _searchBar.barTintColor = BlueBg;
        
        _searchBar.delegate = self;
        _searchBar.showsCancelButton = YES;

        [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UISearchBar class]]].title = @"取消";
        [[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UISearchBar class]]] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,nil] forState:UIControlStateNormal];
    }
    return _searchBar;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc]init];
    [self.view addSubview:self.searchBar];
    
    
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [self.view endEditing:YES];
}


-(void)viewDidAppear:(BOOL)animated{
    [self.searchBar becomeFirstResponder];
}

-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden = YES;
}

-(void)viewWillDisappear:(BOOL)animated{
    [self.view endEditing:YES];
    self.navigationController.navigationBarHidden = NO;
}


- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    static NSString *cellId = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    cell.textLabel.text = @"1";
    return cell;
    
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

@end
