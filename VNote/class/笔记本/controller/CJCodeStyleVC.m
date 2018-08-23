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
@end

@implementation CJCodeStyleVC

- (void)viewDidLoad {
    [super viewDidLoad];
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

- (IBAction)confirm:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    static NSString *cellId = @"cell";
    CJStyleCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
    NSString *text = self.styles[indexPath.row];
    cell.cssL.text = text;
    
    CJUser *user = [CJUser sharedUser];
    if ([user.code_style isEqualToString:text]){
        cell.layer.borderColor = [UIColor greenColor].CGColor;
        cell.layer.borderWidth = 2;
    }else{
        cell.layer.borderWidth = 0.0;
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
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    cell.backgroundColor = [UIColor grayColor];
    
    
}


@end
