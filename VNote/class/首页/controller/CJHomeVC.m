//
//  CJNoticeVC.m
//  VNote
//
//  Created by ccj on 2019/3/13.
//  Copyright © 2019 ccj. All rights reserved.
//

#import "CJHomeVC.h"
#import "CJNoteCell.h"
#import "CJWebVC.h"
#import "CJBtnCell.h"
#import "CJNoticeVC.h"
#import "CJUpdatesVC.h"
#import "CJMarkDownVC.h"
@interface CJHomeVC ()<UITableViewDelegate,UITableViewDataSource,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,FSCalendarDelegate,FSCalendarDataSource>
@property (weak, nonatomic) IBOutlet CJTableView *tableView;

@property(nonatomic,strong) SDCycleScrollView *carouseView;
@property(nonatomic,strong) NSMutableArray<UIImage *> *images;
@property(nonatomic,strong) UICollectionView *btns;
@property(nonatomic,strong) FSCalendar *calender;
@property(nonatomic,strong) NSMutableArray<CJNote *> *notes;
@property(nonatomic,strong) NSDate *selectDate;



@end

@implementation CJHomeVC
static CGFloat carouseViewMaxW = 500.f;
static CGFloat percent = 0.48;
static CGFloat padding = 15.f;
static CGFloat calenderH = 250.f;
static CGFloat calenderMinH = 100.f;
-(NSMutableArray<CJNote *> *)notes{
    if (!_notes){
        _notes = [NSMutableArray array];
    }
    return _notes;
}

-(void)reGetRlmNotes{
    RLMRealm *rlm = [CJRlm shareRlm];
    [self.notes removeAllObjects];
    NSMutableArray *array =  [CJNote cjAllObjectsInRlm:rlm];
    NSString *selectDate = [self.selectDate stringValueWithFormatter:@"yyyy-MM-dd"];
    for (CJNote *n in array) {
        NSString *update = [NSDate cjDateSince1970WithSecs:n.updated_at formatter:@"yyyy-MM-dd"];
        if ([update isEqualToString:selectDate]){
            [self.notes addObject:n];
        }
    }
    [self.tableView reloadData];
    
}

-(void)viewWillAppear:(BOOL)animated{
    if (self.tableView.contentOffset.y > CJScreenWidth * percent + 2 *padding){
        [self setStatusBarBackgroundColor:[UIColor whiteColor]];
    }else{
        [self setStatusBarBackgroundColor:[UIColor clearColor]];
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    [self setStatusBarBackgroundColor:BlueBg];
}

-(FSCalendar *)calender{
    if (!_calender){
        _calender = [[FSCalendar alloc]initWithFrame:CGRectMake(0, 0, CJScreenWidth, calenderH)];
        _calender.dataSource = self;
        _calender.delegate = self;
        _calender.locale = [NSLocale localeWithLocaleIdentifier:@"zh-CN"];
        _calender.backgroundColor = [UIColor whiteColor];
        _calender.appearance.headerTitleColor = BlueBg;
        _calender.appearance.weekdayTextColor = BlueBg;
        _calender.placeholderType = FSCalendarPlaceholderTypeNone;
        
    }
    return _calender;
}

-(SDCycleScrollView *)carouseView{
    if (!_carouseView){
        _carouseView = [SDCycleScrollView cycleScrollViewWithFrame:[self carouseViewFrame] imageNamesGroup:self.images];
        _carouseView.currentPageDotColor = BlueBg;
        CJCornerRadius(_carouseView) = 5.f;
        _carouseView.autoScrollTimeInterval = 8.f;
        CJWeak(self)
        _carouseView.clickItemOperationBlock = ^(NSInteger currentIndex) {
            
            CJWebVC *vc = [[CJWebVC alloc]init];
            vc.request = [NSURLRequest requestWithURL:[NSURL URLWithString:WeNoteUrl]];
            vc.webTitle = @"WeNote官网";
            [weakself.navigationController pushViewController:vc animated:YES];
        };
        
    }
    return _carouseView;
}

- (BOOL)joinGroup:(NSString *)groupUin key:(NSString *)key{
    NSString *urlStr = [NSString stringWithFormat:@"mqqapi://card/show_pslcard?src_type=internal&version=1&uin=%@&key=%@&card_type=group&source=external", @"797923570",@"1aaeede179f5356a76e4b114bb8389746471317c85a5ff77abfffa51131f9f80"];
    NSURL *url = [NSURL URLWithString:urlStr];
    if([[UIApplication sharedApplication] canOpenURL:url]){
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        return YES;
    }
    else return NO;
}

-(UICollectionView *)btns{
    if (!_btns){
        UICollectionViewFlowLayout *flowLayout =[[UICollectionViewFlowLayout alloc] init];
        CGFloat w = CJScreenWidth / (float)5.0;
        flowLayout.itemSize = CGSizeMake(w, [CJNoteCell height]);
        // 为UICollectionView设置布局对象
        _btns.collectionViewLayout = flowLayout;
        _btns = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, CJScreenWidth, [CJNoteCell height]) collectionViewLayout:flowLayout];
        _btns.contentInset =UIEdgeInsetsMake(0, 0, 0, 0);
        _btns.delegate = self;
        _btns.dataSource = self;
        _btns.backgroundColor = [UIColor whiteColor];
        _btns.scrollEnabled = NO;
        
    }
    return _btns;
}



-(NSMutableArray<UIImage *> *)images{
    if (!_images){
        _images = [NSMutableArray array];
        [_images addObject:[UIImage imageNamed:@"p3"]];
        [_images addObject:[UIImage imageNamed:@"p0"]];
        [_images addObject:[UIImage imageNamed:@"p1"]];
        [_images addObject:[UIImage imageNamed:@"p2"]];
    }
    return _images;
}

-(void)getData{
    
    CJUser *user = [CJUser sharedUser];
    CJWeak(self)
    [CJAPI requestWithAPI:API_GET_ALL_BOOKS_AND_NOTES params:@{@"email":user.email} success:^(NSDictionary *dic) {
        NSMutableArray *booksArrM = [NSMutableArray array];
        for (NSDictionary *d in dic[@"books"]){
            CJBook *book = [CJBook bookWithDict:d];
            [booksArrM addObject:book];
        }
        NSMutableArray *notesArrM = [NSMutableArray array];
        for (NSDictionary *d in dic[@"notes"]){
            CJNote *note = [CJNote noteWithDict:d];
            [notesArrM addObject:note];
        }
        
        [CJRlm deleteObjects:[CJNote cjAllObjectsInRlm:[CJRlm shareRlm]]];
        [CJRlm deleteObjects:[CJBook cjAllObjectsInRlm:[CJRlm shareRlm]]];
        [CJRlm addObjects:booksArrM];
        [CJRlm addObjects:notesArrM];
        [weakself reGetRlmNotes];
        
        [weakself.tableView.mj_header endRefreshing];
        [weakself.tableView reloadData];
        [weakself.tableView endLoadingData];
    } failure:^(NSDictionary *dic) {
        [weakself.tableView endLoadingData];
        [weakself.tableView.mj_header endRefreshing];
    } error:^(NSError *error) {
        [weakself.tableView endLoadingData];
        [weakself.tableView.mj_header endRefreshing];
    }];
}

-(CGRect)carouseViewFrame{
    CGFloat w = CJScreenWidth - 2 * padding;
    w = w > carouseViewMaxW ? carouseViewMaxW : w;
    CGFloat p = (CJScreenWidth - w) / 2;
    
    CGRect frame = CGRectMake(p, padding ,w , w * percent);
    return frame;
}

-(CGFloat)carouseViewHeight{
    CGFloat w = CJScreenWidth - 2 * padding;
    w = w > carouseViewMaxW ? carouseViewMaxW : w;

    return w * percent + 2 * padding;
}


-(void)noteChange{
    [self reGetRlmNotes];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(noteChange) name:NOTE_CHANGE_NOTI object:nil];
    [self.tableView registerNib:[UINib nibWithNibName:@"CJNoteCell" bundle:nil] forCellReuseIdentifier:@"cell"];
    CJWeak(self)
    self.tableView.mj_header = [MJRefreshGifHeader cjRefreshWithPullType:CJPullTypeWhite header:^{
        [weakself getData];
    }];
    
    self.tableView.headerColor = BlueBg; // 这个要在mj_header后面设置
    [self.btns registerNib:[UINib nibWithNibName:@"CJBtnCell" bundle:nil] forCellWithReuseIdentifier:@"btncell"];
    self.selectDate = [NSDate date];
    [self reGetRlmNotes];
    
    
}


-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView.contentOffset.y > CJScreenWidth * percent + 2 *padding){
        [self setStatusBarBackgroundColor:[UIColor whiteColor]];
    }else{
        [self setStatusBarBackgroundColor:[UIColor clearColor]];
    }
}
- (void)setStatusBarBackgroundColor:(UIColor *)color {
    
    UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
    if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
        statusBar.backgroundColor = color;
    }
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if (section == 0){
        static NSString *cellID = @"carouseView";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (!cell){
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
            [cell addSubview:self.carouseView];
            cell.backgroundColor = BlueBg;
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }else if (section == 1){
        static NSString *cellID = @"collectionview";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (!cell){
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
            [cell addSubview:self.btns];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
        
    }else if (section == 2){
        static NSString *cellID = @"notecell";
        CJNoteCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (!cell){
            cell = [CJNoteCell xibWithNoteCell];
        }
        CJNote *note = self.notes[row];
        if (note.isInvalidated) return cell;
        [cell setUI:note];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    }
    return nil;
    
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger section = indexPath.section;
    if (section == 0){
        
        return [self carouseViewHeight];
    }else if(section == 1){
        return [CJNoteCell height];
    }else if(section == 2){
        return [CJNoteCell height];
    }else{
        return [CJNoteCell height];
    }
}


-(void)viewWillLayoutSubviews{
    self.carouseView.frame = [self carouseViewFrame];
    
    self.btns.frame = CGRectMake(0, 0, CJScreenWidth, [CJNoteCell height]);
    UICollectionViewFlowLayout *flowLayout =[[UICollectionViewFlowLayout alloc] init];
    CGFloat itew = CJScreenWidth / (float)5.0;
    flowLayout.itemSize = CGSizeMake(itew, [CJNoteCell height]);
    // 为UICollectionView设置布局对象
    _btns.collectionViewLayout = flowLayout;
    self.calender.frame = CGRectMake(0, 0, CJScreenWidth, calenderH);
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0 || section == 1)return 1;
    return self.notes.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}




- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    static NSString *cellId = @"btncell";
    CJBtnCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
    if (!cell){
        cell = [CJBtnCell xibWithView];
    }
    NSInteger row = indexPath.row;
    NSString *imageName;
    NSString *text;
    if (row == 0){
        imageName = @"公告蓝";
        text = @"公告";
    }else if (row == 1){
        imageName = @"更新日志蓝";
        text = @"更新日志";
    }else if (row == 2){
        imageName = @"markdown蓝";
        text = @"Markdown";
    }else if (row == 3){
        imageName = @"评价蓝";
        text = @"评价";
    }else if (row == 4){
        imageName = @"QQ蓝";
        text = @"官网Q群";
    }
    
    cell.img.image = [UIImage imageNamed:imageName];
    cell.label.text = text;
    return cell;
    
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 5;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 2) return 0.01f;
    return 20.f;
}


-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger row = indexPath.row;
    if (row == 0){
        CJNoticeVC *vc = [[CJNoticeVC alloc]init];
        [self.navigationController pushViewController:vc animated:YES];
    }else if (row == 1){
        CJUpdatesVC *vc = [[CJUpdatesVC alloc]init];
        [self.navigationController pushViewController:vc animated:YES];
    }else if (row == 2){
        CJMarkDownVC *vc = [[CJMarkDownVC alloc]init];
        [self.navigationController pushViewController:vc animated:YES];
    }else if (row == 3){
        // 评价
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_11_0
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:APP_OPEN_EVALUATE_AFTER_IOS11]];
#else
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:APP_OPEN_EVALUATE]];
#endif
    }else if (row == 4){
        [self joinGroup:nil key:nil];
    }
}

-(void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section{
    UITableViewHeaderFooterView *v = (UITableViewHeaderFooterView *)view;
    v.backgroundView.backgroundColor = [UIColor whiteColor];
    v.tintColor = [UIColor whiteColor];
    v.backgroundColor = [UIColor redColor];
    if (section == 2){
        if (self.calender.superview) return;
        [v addSubview:self.calender];
        UIView *backView = [[UIView alloc]init];
        backView.backgroundColor = [UIColor whiteColor];
        [v addSubview:backView];
        CJWeak(v)
        [backView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(weakv);
            make.height.mas_equalTo(34);
        }];
        UIView *lineView = [[UIView alloc]init];
        [v addSubview:lineView];
        lineView.backgroundColor = BlueBg;
        
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(weakv).offset(20);
            make.right.equalTo(weakv).offset(-20);
            make.bottom.equalTo(weakv);
            make.height.mas_equalTo(0.8);
        }];
        UIButton *btn = [[UIButton alloc]init];
        [v addSubview:btn];
        [btn addTarget:self action:@selector(upClick:) forControlEvents:UIControlEventTouchUpInside];
        CJWeak(lineView)
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(30);
            make.bottom.equalTo(weaklineView.mas_top).offset(-2);
            make.right.equalTo(weakv).offset(-20);
        }];
        NSString *imgName;
        if (self.calender.scope == FSCalendarScopeMonth) {
            imgName = @"向上蓝";
        } else {
            imgName = @"向下蓝";
        }
        [btn setImage:[UIImage imageNamed:imgName] forState:UIControlStateNormal];

    }else{
        
        for (UIView *view in v.subviews) {
            if (view == v.contentView) continue;
            [view removeFromSuperview];
        }
    }
    
}


-(void)upClick:(UIButton *)btn{
    
    NSString *imgName;
    if (self.calender.scope == FSCalendarScopeMonth) {
        [self.calender setScope:FSCalendarScopeWeek animated:YES];
        imgName = @"向下蓝";
    } else {
        imgName = @"向上蓝";
        [self.calender setScope:FSCalendarScopeMonth animated:YES];
    }
    
    [btn setImage:[UIImage imageNamed:imgName] forState:UIControlStateNormal];
    [self.tableView reloadData];
    
}

-(CGRect)calenderFrame{
    CGRect frame;
    if (self.calender.scope == FSCalendarScopeMonth){
        frame = CGRectMake(0, 0, CJScreenWidth, calenderH);
    }else{
        frame = CGRectMake(0, 0, CJScreenWidth, calenderMinH);
    }
    return frame;
}

#pragma mark - <FSCalendarDelegate>
- (void)calendar:(FSCalendar *)calendar boundingRectWillChange:(CGRect)bounds animated:(BOOL)animated
{
    
    self.calender.frame = [self calenderFrame];
}




-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    if (section == 2){
        return [self calenderFrame].size.height + 34.f;
    }
    return 0.01f;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    
    return 0.0;
}

-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    
    return 0.0;
}

- (void)calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition{
    // 默认从本地取，如果下拉刷新
    self.selectDate = date;
    [self reGetRlmNotes];

}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    if (section == 2){
        CJContentVC *contentVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"contentVC"];
        CJNote *note = self.notes[row];
        if ([note isInvalidated])return;
        contentVC.note = note;
        contentVC.isMe = YES;
        
        [self.navigationController pushViewController:contentVC animated:YES];
    }
}
@end
