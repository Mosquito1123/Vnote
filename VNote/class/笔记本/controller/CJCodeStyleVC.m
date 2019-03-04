//
//  CJCodeStyleVC.m
//  VNote
//
//  Created by ccj on 2018/8/22.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import "CJCodeStyleVC.h"
#import "CJStyleCell.h"

const CGFloat itemRadio = 90.0f / 170.f;
const CGFloat itemW = 200.f;
const NSInteger minCols = 2;
const CGFloat minimumInteritemSpacing = 5.f;
const CGFloat minSideWidth = 5.f;
const CGFloat maxSideWidth = 10.f;
@interface CJCodeStyleVC ()<UICollectionViewDelegate,UICollectionViewDataSource>
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
@end

#define selectColor CJColorFromHex(0x364264)
#define codeColor BlueBg
#define unSelectColor [UIColor whiteColor]

@implementation CJCodeStyleVC
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

-(void)viewWillDisappear:(BOOL)animated{
    self.isFirst = YES;
    [self.coverView removeFromSuperview];
}

-(void)viewDidAppear:(BOOL)animated{
    
    NSUInteger index;
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
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isFirst = YES;
    CJCornerRadius(self.imageView) = 5;
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self setFlowlayout];
    [self.collectionView registerNib:[UINib nibWithNibName:@"CJStyleCell" bundle:nil] forCellWithReuseIdentifier:@"cell"];
    self.collectionView.contentInset =UIEdgeInsetsMake(0, 0, 10, 0);
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rotate) name:ROTATE_NOTI object:nil];
    
}

-(void)rotate{
    [self setFlowlayout];
}

-(NSArray *)styles{
    if(!_styles){
        _styles = @[@"default.min",@"androidstudio",@"arta", @"atelier-dune-dark",@"atelier-dune-light",
                    @"atelier-estuary-dark", @"atelier-estuary-light",@"atelier-forest-dark", @"atelier-forest-light",
                    @"atom-one-dark",@"atom-one-light",@"brown-paper", @"gruvbox-dark",@"gruvbox-light",
                    @"kimbie.dark",@"kimbie.light", @"school-book"];
    }
    return _styles;
}
- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    if (_competion){
        self.competion();
    }
    self.isFirst = YES;

}

- (IBAction)confirm:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
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

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    static NSString *cellId = @"cell";
    CJStyleCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
    cell.backgroundColor = unSelectColor;
    NSString *text = self.styles[indexPath.row];
    cell.codeStyleImgView.image = [self getImageWithName:text];
    CJUser *user = [CJUser sharedUser];
    if ([user.code_style isEqualToString:text]){
        cell.backgroundColor = codeColor;
        
    }
    if (self.selectIndexPath && self.selectIndexPath.row == indexPath.row){
        cell.backgroundColor = selectColor;
    }
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.styles.count;
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch *touch = touches.anyObject;
    UIView *view = touch.view;
    
    if (view == self.bottomView || [view isDescendantOfView:self.bottomView]) return;
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
    if (_competion){
        self.competion();
    }

}


-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    CJStyleCell *preCell = (CJStyleCell *)[collectionView cellForItemAtIndexPath:self.selectIndexPath];
    NSString *preStyle = self.styles[self.selectIndexPath.row];
    
    if (![preStyle isEqualToString:[CJUser sharedUser].code_style]) {
        preCell.backgroundColor = unSelectColor;
        ;    }
    CJStyleCell *cell = (CJStyleCell *)[collectionView cellForItemAtIndexPath:indexPath];
    cell.backgroundColor = selectColor;
    self.selectIndexPath = indexPath;
    if (_selectB){
        _selectB(self.styles[indexPath.row],indexPath);
    }
    
}



@end
