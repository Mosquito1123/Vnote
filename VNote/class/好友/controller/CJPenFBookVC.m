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
#import "CJFocusedVC.h"
#import "CJFollowsVC.h"
@interface CJPenFBookVC ()<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet CJTableView *tableView;
@property(nonatomic,strong) NSMutableArray <CJBook *>*books;
@property(nonatomic,strong) NSMutableArray <CJNote *>*notes;
@property(nonatomic,strong) UIView *titleView;
@property(nonatomic,strong) UIView *line;
@property(nonatomic,strong) UIButton *bookBtn;
@property(nonatomic,strong) UIButton *favouriteBtn;
@end
#define NORMAL_COLOR CJColorFromHex(0x868686)

@implementation CJPenFBookVC
-(void)btnClick:(UIButton *)btn{
    [btn setTitleColor:BlueBg forState:UIControlStateNormal];
    if (btn == self.bookBtn){
        [self.favouriteBtn setTitleColor:NORMAL_COLOR forState:UIControlStateNormal];
    }else{
        [self.bookBtn setTitleColor:NORMAL_COLOR forState:UIControlStateNormal];
    }
    [UIView animateWithDuration:0.25 animations:^{
        self.line.cj_centerX = btn.cj_centerX;
    }];
}
-(UIView *)titleView{
    if (!_titleView){
        _titleView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CJScreenWidth, 40)];
        _titleView.backgroundColor = [UIColor whiteColor];
        UIButton *bookBtn = [[UIButton alloc]init];
        [bookBtn setTitle:@"笔记本" forState:UIControlStateNormal];
        [bookBtn setTitleColor:BlueBg forState:UIControlStateNormal];
        bookBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [bookBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        bookBtn.cj_width = CJScreenWidth / 4;
        bookBtn.cj_height = (_titleView.cj_height / 2 - 4) * 2;
        bookBtn.cj_centerX = _titleView.cj_width / 4;
        bookBtn.cj_centerY = _titleView.cj_height / 2;
        [_titleView addSubview:bookBtn];
        // 暂时不加收藏这个功能
//        UIButton *favouriteBtn = [[UIButton alloc]init];
//        [favouriteBtn setTitle:@"收藏" forState:UIControlStateNormal];
//        [favouriteBtn setTitleColor:NORMAL_COLOR forState:UIControlStateNormal];
//        [favouriteBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
//        favouriteBtn.titleLabel.font = [UIFont systemFontOfSize:15];
//        favouriteBtn.cj_width = CJScreenWidth / 4;
//        favouriteBtn.cj_height = bookBtn.cj_height;
//        favouriteBtn.cj_centerX = _titleView.cj_width / 4 * 3;
//        favouriteBtn.cj_centerY = _titleView.cj_height / 2;
//        [_titleView addSubview:favouriteBtn];
        // 加蓝色滑条
        UIView *line = [[UIView alloc]init];
        line.backgroundColor = BlueBg;
        line.cj_height = 1;
        line.cj_width = CJScreenWidth / 4;
        line.cj_centerX = bookBtn.cj_centerX;
        line.cj_y = bookBtn.cj_maxY + 1;
        self.line = line;
        self.bookBtn = bookBtn;
//        self.favouriteBtn = favouriteBtn;
        [_titleView addSubview:line];
        UIView *grayView = [[UIView alloc]init];
        grayView.backgroundColor = CJColorFromHex(0xe4e5e7);
        grayView.cj_height = 2;
        grayView.cj_x = 0;
        grayView.cj_width = CJScreenWidth;
        grayView.cj_y = line.cj_maxY;
        [_titleView addSubview:grayView];
        
    }
    return _titleView;
}
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
        for (NSDictionary *d in dic[@"books"]){
            CJBook *book = [CJBook bookWithDict:d];
            [weakself.books addObject:book];
        }
        [weakself.notes removeAllObjects];
        for (NSDictionary *d in dic[@"notes"]){
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
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.tableView.tableFooterView = [[UIView alloc]init];
    CJWeak(self)
    self.tableView.mj_header = [MJRefreshGifHeader cjRefreshHeader:^{
        [weakself getData];
    }];
    [self.tableView.mj_header beginRefreshing];
    self.tableView.backgroundColor = MainBg;
}


-(void)focusBtnClick:(UIButton *)btn{
    CJProgressHUD *hud = [CJProgressHUD cjShowInView:self.view timeOut:TIME_OUT withText:@"加载中..." withImages:nil];
    CJUser *user = [CJUser sharedUser];
    if ([btn.titleLabel.text isEqualToString:@"关注"]){
        [CJAPI focusWithParams:@{@"email":user.email,@"user_id":self.penF.user_id} success:^(NSDictionary *dic) {
            [CJRlm addObject:self.penF];
            [[NSNotificationCenter defaultCenter] postNotificationName:PEN_FRIEND_CHANGE_NOTI object:nil];
            [hud cjHideProgressHUD];
            [btn setTitle:@"取消关注" forState:UIControlStateNormal];
        } failure:^(NSError *error) {
            [hud cjShowError:net101code];
        }];
        
        
    }else{
        
        [CJAPI cancelFocusWithParams:@{@"email":user.email,@"pen_friend_id":self.penF.user_id} success:^(NSDictionary *dic) {
            CJPenFriend *p = self.penF.copy;
            [CJRlm deleteObject:self.penF];
            self.penF = p;
            [[NSNotificationCenter defaultCenter] postNotificationName:PEN_FRIEND_CHANGE_NOTI object:nil];
            [hud cjHideProgressHUD];
            [btn setTitle:@"关注" forState:UIControlStateNormal];
        } failure:^(NSError *error) {
            [hud cjShowError:net101code];
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
        cell.introL.text = self.penF.introduction;
        [cell.focusedCountBtn setTitle:self.penF.focused_count forState:UIControlStateNormal];
        [cell.followsBtn setTitle:self.penF.follows_count forState:UIControlStateNormal];
        CJWeak(self)
        [cell.focusedCountBtn cjRespondTargetForControlEvents:UIControlEventTouchUpInside actionBlock:^(UIControl *control) {
            CJFocusedVC *vc = [[CJFocusedVC alloc]init];
            vc.penF = self.penF;
            [weakself.navigationController pushViewController:vc animated:YES];
        }];
        cell.sexImg.image = [UIImage imageNamed:self.penF.sex];
        [cell.followsBtn cjRespondTargetForControlEvents:UIControlEventTouchUpInside actionBlock:^(UIControl *control) {
            CJFollowsVC *vc = [[CJFollowsVC alloc]init];
            vc.penF = self.penF;
            [weakself.navigationController pushViewController:vc animated:YES];
        }];
        return cell;
    }
    NSString *cellID = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    cell.imageView.image = [UIImage imageNamed:@"笔记本灰"];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = self.books[row].name;
    
    return cell;
    
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView.contentOffset.y > 80){
        
        self.navigationItem.title = self.penF.nickname;
    }else{
        self.navigationItem.title = nil;
        
    }
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
    
    return self.titleView;
    
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
