//
//  CJCodeStyleView.m
//  VNote
//
//  Created by ccj on 2019/3/5.
//  Copyright © 2019 ccj. All rights reserved.
//

#import "CJCodeStyleView.h"
#import "CJStyleCell.h"
const CGFloat itemRadio = 90.0f / 170.f;
const CGFloat itemW = 200.f;
const NSInteger minCols = 2;
const CGFloat minimumInteritemSpacing = 5.f;
const CGFloat minSideWidth = 5.f;
const CGFloat maxSideWidth = 10.f;
@interface CJCodeStyleView()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property(nonatomic,strong) NSArray *styles;
@property(nonatomic,copy) void (^selectB)(NSString *,NSIndexPath *);
@property(nonatomic,copy) void (^confirmB)(NSString *);
@property(nonatomic,strong) NSIndexPath *selectIndexPath;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property(nonatomic,copy) void (^competion)(void);
@property (weak, nonatomic) IBOutlet UIView *titleBgView;
@property (nonatomic,assign) BOOL isFirst;
@property (nonatomic,assign) BOOL isShown;

@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;

@property (weak, nonatomic) IBOutlet UIButton *confirmBtn;

@end
#define selectColor CJColorFromHex(0x1296db)
#define codeColor selectColor
#define unSelectColor [UIColor whiteColor]
@implementation CJCodeStyleView

+(instancetype)xibWithCodeStyleView
{
    CJCodeStyleView *view = [[[NSBundle mainBundle] loadNibNamed:@"CJCodeStyleView" owner:nil options:nil]lastObject];
    view.isFirst = YES;
    CJCornerRadius(view.imageView) = 5;
    view.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    [view.collectionView registerNib:[UINib nibWithNibName:@"CJStyleCell" bundle:nil] forCellWithReuseIdentifier:@"cell"];
    view.collectionView.contentInset =UIEdgeInsetsMake(0, 0, 10, 0);
    view.collectionView.delegate = view;
    view.collectionView.dataSource = view;
    [[NSNotificationCenter defaultCenter] addObserver:view selector:@selector(rotate) name:ROTATE_NOTI object:nil];
    [view.cancelBtn addTarget:view action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
    [view.confirmBtn addTarget:view action:@selector(confirm:) forControlEvents:UIControlEventTouchUpInside];
    view.selectIndexPath = nil;
    return view;
}


-(UIImage *)getImageWithName:(NSString *)name{
    UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png",name]];
    return image;
    
}
-(void)selectItem:(void (^)(NSString *,NSIndexPath *))select confirm:(void(^)(NSString *))confirm selectIndexPath:(NSIndexPath *)indexPath competion:(void (^)(void))competion{
    _selectB = select;
    _confirmB = confirm;
    _selectIndexPath = indexPath;
    _competion = competion;
}
-(void)addInView:(UIView *)view{
    
    if(self.superview)return;
    self.isShown = NO;
    [view addSubview:self];
    [self setFlowlayout];
    
    
}

-(void)show{
    NSUInteger index;
    [self mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(0);
    }];
    [UIView animateWithDuration:0.5 animations:^{
        [self.superview layoutIfNeeded];
    }];
    if (self.isFirst){
        if (self.selectIndexPath){
            index = self.selectIndexPath.row;
        }
        else{
            CJUser *user = [CJUser sharedUser];
            index = [self.styles indexOfObject:user.code_style];
        }
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
        self.isFirst = NO;
    }
    self.isShown = YES;
}



-(void)hide{
    
    [self mas_updateConstraints:^(MASConstraintMaker *make) {
        
        make.bottom.mas_equalTo(CJScreenHeight);
    }];
    [UIView animateWithDuration:0.5 animations:^{
        
        [self.superview layoutIfNeeded];
    }];
    self.isShown = NO;
}

-(CGFloat)getStylePicMinWidth{
    CGFloat minWidth = 0;
    minWidth =  (CJScreenWidth - minimumInteritemSpacing - minCols * minSideWidth)  / 2;
    minWidth = minWidth > itemW ? itemW : minWidth;
    return minWidth;
}

-(void)setFlowlayout{
    UICollectionViewFlowLayout *flowLayout =[[UICollectionViewFlowLayout alloc] init];
    // 根据图片的大小和minCols的大小确定宽度
    CGFloat w = [self getStylePicMinWidth];
    
    CGFloat itemH = w * itemRadio;
    NSInteger cols = (int)(CJScreenWidth / w);
    CGFloat sideWidth = (CJScreenWidth - minimumInteritemSpacing * (cols - 1) - cols * w ) / 2;
    flowLayout.minimumInteritemSpacing = minimumInteritemSpacing;
    flowLayout.sectionInset = UIEdgeInsetsMake(0, sideWidth, 0, sideWidth);
    flowLayout.itemSize = CGSizeMake(w, itemH);
    // 为UICollectionView设置布局对象
    self.collectionView.collectionViewLayout = flowLayout;
    CJWeak(self)
    if (self.isShown){
        // 显示
        [self mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.equalTo(weakself.superview);
            make.height.mas_equalTo(CJScreenHeight / 2);
            make.bottom.mas_equalTo(0);
        }];
    }else{
        // 未显示
        [self mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.equalTo(weakself.superview);
            make.height.mas_equalTo(CJScreenHeight / 2);
            make.bottom.mas_equalTo(CJScreenHeight);
        }];
    }
    
}



-(void)rotate{
    if (self && self.superview){
        [self setFlowlayout];
    }
    
}

-(NSArray *)styles{
    if(!_styles){
        _styles = @[@"default.min",@"androidstudio",@"arta", @"atelier-dune-dark",@"atelier-dune-light",
                    @"atelier-estuary-dark", @"atelier-estuary-light",@"atelier-forest-dark", @"atelier-forest-light",
                    @"atom-one-dark",@"atom-one-light",@"brown-paper", @"gruvbox-dark",@"gruvbox-light",
                    @"kimbie.dark",@"kimbie.light", @"school-book",@"dracula"];
    }
    return _styles;
}



-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    // 获取usercell
    NSInteger index = [self.styles indexOfObject:[CJUser sharedUser].code_style];
    NSIndexPath *userIndexPath = [NSIndexPath indexPathForRow:index inSection:0];
    CJStyleCell *userCell = (CJStyleCell *)[collectionView cellForItemAtIndexPath:userIndexPath];
    [userCell showCheckmark:NO];
    
    CJStyleCell *preCell = (CJStyleCell *)[collectionView cellForItemAtIndexPath:self.selectIndexPath];
    [preCell showCheckmark:NO];
    
    CJStyleCell *cell = (CJStyleCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [cell showCheckmark:YES];
    
    self.selectIndexPath = indexPath;
    if (_selectB){
        _selectB(self.styles[indexPath.row],indexPath);
    }
    
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    static NSString *cellId = @"cell";
    CJStyleCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
    cell.backgroundColor = unSelectColor;
    NSString *text = self.styles[indexPath.row];
    cell.codeStyleImgView.image = [self getImageWithName:text];
    CJUser *user = [CJUser sharedUser];
    [cell showCheckmark:NO];
    if (!self.selectIndexPath && [user.code_style isEqualToString:text]){
        [cell showCheckmark:YES];
    }
    if (self.selectIndexPath && self.selectIndexPath.row == indexPath.row){
        [cell showCheckmark:YES];
    }
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.styles.count;
}



- (void)cancel:(id)sender {
    [self hide];
    if (_competion){
        self.competion();
    }
    self.isFirst = YES;
    [self hide];
}

- (void)confirm:(id)sender {
    [self hide];
    NSString *style = self.styles[self.selectIndexPath.row];
    if (_competion){
        self.competion();
    }
    if ([style isEqualToString:[CJUser sharedUser].code_style]) return ;
    if (_confirmB){
        _confirmB(style);
    }
    self.isFirst = YES;
    
}


@end
