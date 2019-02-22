//
//  CJCodeStyleVC.m
//  VNote
//
//  Created by ccj on 2018/8/22.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import "CJCodeStyleVC.h"
#import "CJStyleCell.h"
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

@implementation CJCodeStyleVC

-(void)selectItem:(void (^)(NSString *,NSIndexPath *))select confirm:(void(^)(NSString *))confirm selectIndexPath:(NSIndexPath *)indexPath competion:(void (^)(void))competion{
    _selectB = select;
    _confirmB = confirm;
    _selectIndexPath = indexPath;
    _competion = competion;
}


-(void)viewDidLayoutSubviews{
    if (self.isFirst){
        CJUser *user = [CJUser sharedUser];
        NSUInteger index = [self.styles indexOfObject:user.code_style];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
        self.isFirst = NO;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isFirst = YES;
    CJCornerRadius(self.imageView) = self.imageView.cj_width / 2;
    self.imageView.layer.borderColor = BlueBg.CGColor;
    self.imageView.layer.borderWidth = 5.0;
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    UICollectionViewFlowLayout *flowLayout =[[UICollectionViewFlowLayout alloc] init];
    CGFloat itemW = (CJScreenWidth / 2) - 12;
    CGFloat itemH = 35.0;
    flowLayout.minimumInteritemSpacing = 3;
    flowLayout.sectionInset = UIEdgeInsetsMake(0, 6, 0, 6);
    flowLayout.itemSize = CGSizeMake(itemW, itemH);
    // 为UICollectionView设置布局对象
    self.collectionView.collectionViewLayout = flowLayout;
    [self.collectionView registerNib:[UINib nibWithNibName:@"CJStyleCell" bundle:nil] forCellWithReuseIdentifier:@"cell"];
    
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
    

}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    static NSString *cellId = @"cell";
    CJStyleCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
    NSString *text = self.styles[indexPath.row];
    cell.cssL.text = text;
    
    cell.backgroundColor = BlueBg;
    cell.cssL.textColor = [UIColor whiteColor];
    CJUser *user = [CJUser sharedUser];
    if ([user.code_style isEqualToString:text]){
        cell.backgroundColor = [UIColor greenColor];
        cell.cssL.textColor = BlueBg;
    }
    if (self.selectIndexPath && self.selectIndexPath.row == indexPath.row){
        cell.backgroundColor = [UIColor grayColor];
        cell.cssL.textColor = [UIColor whiteColor];
        
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
    [self dismissViewControllerAnimated:YES completion:nil];
    if (_competion){
        self.competion();
    }

}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    CJStyleCell *preCell = (CJStyleCell *)[collectionView cellForItemAtIndexPath:self.selectIndexPath];
    NSString *style = self.styles[self.selectIndexPath.row];
    
    if ([style isEqualToString:[CJUser sharedUser].code_style]) {
        preCell.backgroundColor = [UIColor greenColor];
        preCell.cssL.textColor = BlueBg;
    }else{
        preCell.backgroundColor = BlueBg;
        preCell.cssL.textColor = [UIColor whiteColor];
    }
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    cell.backgroundColor = [UIColor grayColor];
    self.selectIndexPath = indexPath;
    if (_selectB){
        _selectB(self.styles[indexPath.row],indexPath);
    }
    
}


@end
