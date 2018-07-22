//
//  CJTabBarVC.m
//  VNote
//
//  Created by ccj on 2018/7/8.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import "CJTabBarVC.h"
#import "CJCustomBtn.h"
@interface CJTabBarVC ()
@property(nonatomic,strong) UIVisualEffectView *visualView;
@property(nonatomic,strong) UIButton *minusBtn;


@property(nonatomic,strong) CJCustomBtn *addBookBtn;
@property(nonatomic,strong) CJCustomBtn *addNoteBtn;

@end

@implementation CJTabBarVC

-(CJCustomBtn *)addBookBtn{
    if (!_addBookBtn){
        _addBookBtn = [CJCustomBtn xibCustomBtnWithTapClick:^{
            [self.visualView removeFromSuperview];
            UINavigationController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"addBookNav"];
            [self presentViewController:vc animated:YES completion:nil];
        }];
        _addBookBtn.textLabel.text = @"创建笔记本";
        _addBookBtn.textLabel.font = [UIFont systemFontOfSize:12];
        _addBookBtn.textLabel.textColor = [UIColor blackColor];
        _addBookBtn.cj_size = CGSizeMake(80, 80);
        
    }
    return _addBookBtn;
}
-(CJCustomBtn *)addNoteBtn{
    if (!_addNoteBtn){
        _addNoteBtn = [CJCustomBtn xibCustomBtnWithTapClick:^{
            [self.visualView removeFromSuperview];
            [self.visualView removeFromSuperview];
            UINavigationController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"addNoteNav"];
            [self presentViewController:vc animated:YES completion:nil];
        }];
        _addNoteBtn.textLabel.text = @"添加笔记";
        _addNoteBtn.textLabel.font = [UIFont systemFontOfSize:12];
        _addNoteBtn.textLabel.textColor = [UIColor blackColor];
        _addNoteBtn.cj_size = CGSizeMake(80, 80);
    }
    return _addNoteBtn;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    UITabBarItem *item = [UITabBarItem appearance];
    NSMutableDictionary *normalAttrs = [NSMutableDictionary dictionary];
    normalAttrs[NSFontAttributeName] = [UIFont systemFontOfSize:12];
    normalAttrs[NSForegroundColorAttributeName] = HeadFontColor;
    [item setTitleTextAttributes:normalAttrs forState:UIControlStateNormal];
    
    NSMutableDictionary *selectedAttrs = [NSMutableDictionary dictionary];
    selectedAttrs[NSForegroundColorAttributeName] = BlueBg;
    [item setTitleTextAttributes:selectedAttrs forState:UIControlStateSelected];
    CJTabBar *tabBar = (CJTabBar *)self.tabBar;
    
    [tabBar.publishBtn addTarget:self action:@selector(plusClick) forControlEvents:UIControlEventTouchUpInside];

}
-(void)minusClick{
    [UIView animateWithDuration:0.3 animations:^{
        self.minusBtn.transform = CGAffineTransformMakeRotation(-M_PI_4);
    }];
    [UIView animateWithDuration:0.5 delay:0.4 usingSpringWithDamping:0.5 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.addBookBtn.cj_y = self.visualView.cj_height;
    } completion:^(BOOL finished){
        [self.visualView removeFromSuperview];
    }];
    
    [UIView animateWithDuration:0.5 delay:0.3 usingSpringWithDamping:0.5 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.addNoteBtn.cj_y = self.visualView.cj_height;
    } completion:nil];
    
    
    
}

-(void)plusClick{
    // 添加蒙版
    UIVisualEffectView *visualView = [[UIVisualEffectView alloc]initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
    self.visualView = visualView;
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    visualView.frame = window.bounds;
    [window addSubview:visualView];
    UIButton *minusBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [minusBtn setImage:[UIImage imageNamed:@"加白"] forState:UIControlStateNormal];
    [minusBtn sizeToFit];
    [visualView.contentView addSubview:minusBtn];
    minusBtn.cj_centerX = visualView.cj_centerX;
    minusBtn.cj_y = visualView.cj_height - minusBtn.cj_height - 10;
    [minusBtn addTarget:self action:@selector(minusClick) forControlEvents:UIControlEventTouchUpInside];
    self.minusBtn = minusBtn;
    
    // 页面的按钮
    [visualView.contentView addSubview:self.addBookBtn];
    [visualView.contentView addSubview:self.addNoteBtn];
    CGFloat width = self.addBookBtn.cj_width;
    CGFloat gap = (visualView.cj_width - 4 * width) / 5;
    self.addBookBtn.cj_x = gap;
    self.addBookBtn.cj_y = visualView.cj_height;
    self.addNoteBtn.cj_x = gap *2 + width;
    self.addNoteBtn.cj_y = visualView.cj_height;
    
    [UIView animateWithDuration:0.3 animations:^{
       minusBtn.transform = CGAffineTransformMakeRotation(M_PI_4);
    }];
    [UIView animateWithDuration:0.5 delay:0.3 usingSpringWithDamping:0.5 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.addBookBtn.cj_y = visualView.cj_height - 300;
    } completion:nil];
    
    [UIView animateWithDuration:0.5 delay:0.4 usingSpringWithDamping:0.5 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.addNoteBtn.cj_y = visualView.cj_height - 300;
    } completion:nil];
    
    
    
}


-(void)toRootViewController{
    UIViewController *viewController = self;
    while (viewController.presentingViewController) {
        //判断是否为最底层控制器
        if ([viewController isKindOfClass:[UIViewController class]]) {
            viewController = viewController.presentingViewController;
        }else{
            break;
        }
    }
    if (viewController) {
        [viewController dismissViewControllerAnimated:YES completion:nil];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
