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


@end

@implementation CJHomeVC

static CGFloat percent = 0.48;
static CGFloat padding = 15.f;
static CGFloat calenderH = 150.f;

-(FSCalendar *)calender{
    if (!_calender){
        _calender = [[FSCalendar alloc]initWithFrame:CGRectMake(0, 0, CJScreenWidth, calenderH)];
        _calender.dataSource = self;
        _calender.delegate = self;
    }
    return _calender;
}

-(SDCycleScrollView *)carouseView{
    if (!_carouseView){
        CGFloat w = CJScreenWidth - 2* padding;
        
        _carouseView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(padding, padding,w , w * percent) imageNamesGroup:self.images];
        _carouseView.currentPageDotColor = BlueBg;
        CJCornerRadius(_carouseView) = 5.f;
        _carouseView.autoScrollTimeInterval = 5.f;
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
        [[UIApplication sharedApplication] openURL:url];
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




- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"CJNoteCell" bundle:nil] forCellReuseIdentifier:@"cell"];
    self.tableView.headerColor = BlueBg;
    [self.btns registerNib:[UINib nibWithNibName:@"CJBtnCell" bundle:nil] forCellWithReuseIdentifier:@"btncell"];
    self.tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    
}

- (void)setStatusBarBackgroundColor:(UIColor *)color {
    
    UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
    if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
        statusBar.backgroundColor = color;
    }
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger section = indexPath.section;
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
            [cell.contentView addSubview:self.btns];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
        
    }else if (section == 2){
        static NSString *cellID = @"calender";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (!cell){
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
            [cell addSubview:self.calender];
            CJWeak(cell)
            [self.calender mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.top.bottom.equalTo(weakcell);
            }];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    return nil;
    
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger section = indexPath.section;
    if (section == 0){
        return CJScreenWidth * percent + 2 * padding;
    }else if(section == 1){
        return [CJNoteCell height];
    }else if(section == 2){
        return calenderH;
    }else{
        return [CJNoteCell height];
    }
}


-(void)viewWillLayoutSubviews{
    CGFloat w = CJScreenWidth - 2* padding;
    self.carouseView.frame = CGRectMake(padding, padding, w, w * percent);
    
    self.btns.frame = CGRectMake(0, 0, CJScreenWidth, [CJNoteCell height]);
    UICollectionViewFlowLayout *flowLayout =[[UICollectionViewFlowLayout alloc] init];
    CGFloat itew = CJScreenWidth / (float)5.0;
    flowLayout.itemSize = CGSizeMake(itew, [CJNoteCell height]);
    // 为UICollectionView设置布局对象
    _btns.collectionViewLayout = flowLayout;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0 || section == 1)return 1;
    return 0;
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

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    
    return 0.0;
}

-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    
    return 0.0;
}
@end
