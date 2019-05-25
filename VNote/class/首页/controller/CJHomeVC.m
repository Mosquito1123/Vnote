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
@interface CJHomeVC ()<UITableViewDelegate,UITableViewDataSource,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (weak, nonatomic) IBOutlet CJTableView *tableView;

@property(nonatomic,strong) CJCarouselView *carouseView;
@property(nonatomic,strong) NSMutableArray<UIImage *> *images;
@property(nonatomic,strong) UICollectionView *btns;

@end

@implementation CJHomeVC


static CGFloat percent = 0.48;
static CGFloat padding = 15.f;

-(UICollectionView *)btns{
    if (!_btns){
        UICollectionViewFlowLayout *flowLayout =[[UICollectionViewFlowLayout alloc] init];
        CGFloat w = CJScreenWidth / (float)4.0;
        flowLayout.itemSize = CGSizeMake(w, [CJNoteCell height]);
        // 为UICollectionView设置布局对象
        _btns.collectionViewLayout = flowLayout;
        _btns = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, CJScreenWidth, 2 * [CJNoteCell height]) collectionViewLayout:flowLayout];
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
    
    CJWeak(self)
    UIView *bgView = [[UIView alloc] init];
    [self.tableView insertSubview:bgView atIndex:0];
    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(weakself.tableView);
        make.height.equalTo(weakself.tableView);
        make.left.equalTo(weakself.tableView);
        make.bottom.equalTo(weakself.tableView.mas_top);
    }];
    bgView.backgroundColor = BlueBg;
    [self.btns registerNib:[UINib nibWithNibName:@"CJBtnCell" bundle:nil] forCellWithReuseIdentifier:@"btncell"];
    self.tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    
}

-(CJCarouselView *)carouseView{
    CJWeak(self)
    if (!_carouseView){
        CGFloat w = CJScreenWidth;
        CGFloat h = w * percent;
        CGRect frame = CGRectMake(0, padding, w, h);
        _carouseView = [CJCarouselView cjCarouseViewWithFrame:frame withImagess:self.images pageControlPosition:CJPageControlPositionCenter didClickBlock:^(NSInteger index) {
            CJWebVC *vc = [[CJWebVC alloc]init];
            vc.request = [NSURLRequest requestWithURL:[NSURL URLWithString:WeNoteUrl]];
            vc.webTitle = @"WeNote官网";
            [weakself.navigationController pushViewController:vc animated:YES];
        }];
    }
    return _carouseView;
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
        }
        [self.carouseView removeFromSuperview];
        self.carouseView = nil;
        [cell addSubview:self.carouseView];
        
        cell.backgroundColor = BlueBg;
        
        return cell;
    }else if (section == 1){
        static NSString *cellID = @"collectionview";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (!cell){
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        }
        [cell.contentView addSubview:self.btns];
        return cell;
        
    }
    return nil;
    
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger section = indexPath.section;
    if (section == 0){
        return CJScreenWidth * percent + 2 * padding;
    }else if(section == 1){
        return 2 *[CJNoteCell height];
    }else{
        return [CJNoteCell height];
    }
}


-(void)viewWillLayoutSubviews{
    [self.tableView reloadData];
    self.btns.frame = CGRectMake(0, 0, CJScreenWidth, 2 * [CJNoteCell height]);
    UICollectionViewFlowLayout *flowLayout =[[UICollectionViewFlowLayout alloc] init];
    CGFloat w = CJScreenWidth / (float)4.0;
    flowLayout.itemSize = CGSizeMake(w, [CJNoteCell height]);
    // 为UICollectionView设置布局对象
    _btns.collectionViewLayout = flowLayout;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0 || section == 1)return 1;
    return 0;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
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
        imageName = @"公告蓝";
        text = @"更新日志";
    }else if (row == 2){
        text = @"问题反馈";
    }else if (row == 3){
        text = @"Markdown";
    }else if (row == 4){
        text = @"评价";
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
