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
@end

@implementation CJCodeStyleVC

-(void)selectItem:(void (^)(NSString *,NSIndexPath *))select confirm:(void(^)(NSString *))confirm selectIndexPath:(NSIndexPath *)indexPath competion:(void (^)(void))competion{
    _selectB = select;
    _confirmB = confirm;
    _selectIndexPath = indexPath;
    _competion = competion;
}




- (void)viewDidLoad {
    [super viewDidLoad];
    CJCornerRadius(self.imageView) = self.imageView.cj_width / 2;
    self.bottomView.layer.borderColor = [UIColor grayColor].CGColor;
    self.bottomView.layer.borderWidth = 0.5;
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
        _styles = @[@"default.min",@"agate",@"androidstudio",@"arduino-light",@"arta",@"ascetic",@"atelier-cave-dark", @"atelier-cave-light",@"atelier-dune-dark",@"atelier-dune-light",@"atelier-estuary-dark",@"atelier-estuary-light",@"atelier-forest-dark", @"atelier-forest-light",@"atelier-heath-dark", @"atelier-heath-light", @"atelier-lakeside-dark",@"atelier-lakeside-light",@"atelier-plateau-dark",@"atelier-plateau-light",@"atelier-savanna-dark",@"atelier-savanna-light",@"atelier-seaside-dark", @"atelier-seaside-light",@"atelier-sulphurpool-dark",@"atelier-sulphurpool-light", @"atom-one-dark",@"atom-one-light",@"brown-paper",@"codepen-embed",@"color-brewer", @"darcula",@"dark",@"darkula",@"default", @"docco",@"dracula",@"far",@"foundation",@"github-gist",@"github", @"googlecode",@"grayscale",@"gruvbox-dark",@"gruvbox-light",@"hopscotch",@"hybrid",@"idea",@"ir-black",@"kimbie.dark",@"kimbie.light",@"magula",@"mono-blue",@"monokai-sublime",@"monokai",@"obsidian",@"ocean",@"paraiso-dark",@"paraiso-light",@"pojoaque",@"purebasic",@"qtcreator_dark",@"qtcreator_light",@"railscasts",@"rainbow",@"routeros",@"school-book", @"solarized-dark",@"solarized-light",@"sunburst",@"tomorrow-night-blue",@"tomorrow-night-bright",@"tomorrow-night-eighties",@"tomorrow-night",@"tomorrow",@"vs",@"vs2015",@"xcode",@"xt256",@"zenburn"];
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
    
    if ([style isEqualToString:[CJUser sharedUser].code_style]) return ;
    if (_confirmB){
        _confirmB(style);
    }
    if (_competion){
        self.competion();
    }

}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    static NSString *cellId = @"cell";
    CJStyleCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
    NSString *text = self.styles[indexPath.row];
    cell.cssL.text = text;
    
    cell.backgroundColor = BlueBg;
    CJUser *user = [CJUser sharedUser];
    if ([user.code_style isEqualToString:text]){
        cell.backgroundColor = [UIColor greenColor];
        cell.cssL.textColor = MainColor;
    }
    if (self.selectIndexPath && self.selectIndexPath.row == indexPath.row){
        cell.backgroundColor = [UIColor grayColor];
    }
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.styles.count;
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch *touch = touches.anyObject;
    UIView *view = touch.view;
    if (view == self.bottomView) return;
    [self dismissViewControllerAnimated:YES completion:nil];
    if (_competion){
        self.competion();
    }

}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *preCell = [collectionView cellForItemAtIndexPath:self.selectIndexPath];
    NSString *style = self.styles[self.selectIndexPath.row];
    
    if ([style isEqualToString:[CJUser sharedUser].code_style]) {
        preCell.backgroundColor = [UIColor greenColor];
    }else{
        preCell.backgroundColor = BlueBg;
    }
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    cell.backgroundColor = [UIColor grayColor];
    self.selectIndexPath = indexPath;
    if (_selectB){
        _selectB(self.styles[indexPath.row],indexPath);
    }
    
}


@end
