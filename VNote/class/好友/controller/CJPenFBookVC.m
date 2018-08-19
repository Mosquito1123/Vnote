//
//  CJPenFBookVC.m
//  VNote
//
//  Created by ccj on 2018/7/22.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import "CJPenFBookVC.h"
#import "CJPenFHeadView.h"
#import "CJBook.h"
#import "CJNote.h"
#import "CJPenFriend.h"
#import "CJPenNoteVC.h"
@interface CJPenFBookVC ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet CJTableView *tableView;
@property(nonatomic,strong) NSMutableArray <CJBook *>*books;
@property(nonatomic,strong) NSMutableArray <CJNote *>*notes;
@end

@implementation CJPenFBookVC

-(NSMutableArray *)books{
    if (!_books){
        _books = [NSMutableArray array];
    }
    return _books;
}

-(NSMutableArray *)notes{
    if (!_notes){
        _notes = [NSMutableArray array];
    }
    return _notes;
}
-(void)getData{
    CJWeak(self)
    [CJAPI getBooksAndNotesWithParams:@{@"email":self.penF.email} success:^(NSDictionary *dic) {
        [weakself.books removeAllObjects];
        for (NSDictionary *d in dic[@"res"][@"book_info_list"]){
            CJBook *book = [CJBook bookWithDict:d];
            [weakself.books addObject:book];
        }
        [weakself.notes removeAllObjects];
        for (NSDictionary *d in dic[@"res"][@"notes"]){
            CJNote *note = [CJNote noteWithDict:d];
            [weakself.notes addObject:note];
        }
        
        [weakself.tableView.mj_header endRefreshing];
        [weakself.tableView reloadData];
    } failure:^(NSError *error) {
        [weakself.tableView.mj_header endRefreshing];
    }];
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc]init];
    self.tableView.mj_header = [MJRefreshGifHeader cjRefreshHeader:^{
        [self getData];
    }];
    [self.tableView.mj_header beginRefreshing];
    self.navigationItem.title = self.penF.nickname;

}

-(void)focusBtnClick:(UIButton *)btn{
    CJProgressHUD *hud = [CJProgressHUD cjShowWithPosition:CJProgressHUDPositionNavigationBar timeOut:0 withText:@"加载中..." withImages:nil];
    CJUser *user = [CJUser sharedUser];
    if ([btn.titleLabel.text isEqualToString:@"关注"]){
        [CJAPI focusWithParams:@{@"email":user.email,@"user_id":self.penF.v_user_id} success:^(NSDictionary *dic) {
            [hud cjHideProgressHUD];
            [btn setTitle:@"取消关注" forState:UIControlStateNormal];
        } failure:^(NSError *error) {
            [hud cjShowError:@"加载失败!"];
        }];
        
        
    }else{
        
        [CJAPI cancelFocusWithParams:@{@"email":user.email,@"pen_friend_id":self.penF.v_user_id} success:^(NSDictionary *dic) {
            [hud cjHideProgressHUD];
            [btn setTitle:@"关注" forState:UIControlStateNormal];
        } failure:^(NSError *error) {
            [hud cjShowError:@"加载失败!"];
        }];
        
    }
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if (section == 0){
        CJPenFHeadView *cell = [CJPenFHeadView xibPenFHeadView];
        
        [cell.avtar yy_setImageWithURL:IMG_URL(self.penF.avtar_url) placeholder:[UIImage imageNamed:@"avtar"]];
        [cell.focusBtn addTarget:self action:@selector(focusBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        cell.nicknameL.text = self.penF.nickname;
        cell.emailL.text = self.penF.email;
        return cell;
    }
    NSString *cellID = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = self.books[row].name;
    return cell;
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) return;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CJPenNoteVC *vc = [[CJPenNoteVC alloc]init];
    CJBook *book = self.books[indexPath.row];
    vc.bookTitle = book.name;
    vc.book_uuid = book.uuid;
    vc.email = self.penF.email;
    NSMutableArray *array = [NSMutableArray array];
    [self.notes enumerateObjectsUsingBlock:^(CJNote * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.book_uuid isEqualToString:book.uuid]){
            [array addObject:obj];
        }
        
    }];
    vc.notes = array;
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) return 1;
    return self.books.count;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 0){
        
        return [[UIView alloc]init];
    }
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CJScreenWidth, 40)];
    UILabel *l = [[UILabel alloc]init];
    l.frame = CGRectMake(5, 0, 100, 25);
    l.cj_centerY = view.cj_height / 2;
    l.text = @"笔记本";
    l.textColor = [UIColor whiteColor];
    view.backgroundColor = BlueBg;
    [view addSubview:l];
    return view;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0)return 0.0;
    return 40;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0){
        return 150;
    }
    return 44;
}

@end
