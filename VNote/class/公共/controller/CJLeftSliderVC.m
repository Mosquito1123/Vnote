//
//  CJLeftViewController.m
//  left
//
//  Created by ccj on 2018/8/14.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import "CJLeftSliderVC.h"
#define MAXEXCURSION CJScreenWidth * 1.0
#define LEFTMAXWIDTH CJScreenWidth * 0.6
#define RIGHTMAXWIDTH CJScreenWidth * 0.6


@interface CJLeftSliderVC ()<UIGestureRecognizerDelegate>
@property(nonatomic,weak)UIView *mainView;
@property(nonatomic,weak)UIView *leftView;
@property (nonatomic, assign) BOOL isBestLeft;
@property (nonatomic, assign) BOOL isBestRight;
@property (nonatomic, strong) UIView *shadeView;
@property (nonatomic,strong) UIViewController *mainVC;
@property (nonatomic,strong) UIViewController *leftVC;
@property(nonatomic,strong) NSMutableArray <NSDictionary *> *accounts;
@property(nonatomic,assign) BOOL isInLeft;
@end

@implementation CJLeftSliderVC

- (void)respondsToShadeView {
    [self hiddenLeftViewAnimation];
}
- (void)respondsToPanGR:(UIPanGestureRecognizer *)panGR {
    CGPoint position = [panGR translationInView:self.shadeView];
    
    // 手势触摸结束
    if (panGR.state == UIGestureRecognizerStateEnded) {
        if (- position.x > MAXEXCURSION * 0.5) {
            [self hiddenLeftViewAnimation];
        } else {
            [self showLeftViewAnimation];
        }
        
        return;
    }
    
    // 判断是否滑出屏幕外
    if (position.x < - MAXEXCURSION || position.x > 0) {
        return;
    }
    [self showLeftViewAnimationWithExcursion:MAXEXCURSION + position.x];
}
- (UIView *)shadeView {
    if (!_shadeView) {
        _shadeView = [[UIView alloc] initWithFrame:self.mainView.bounds];
        _shadeView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        
        UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(respondsToShadeView)];
        UIPanGestureRecognizer *panGR = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(respondsToPanGR:)];
        [_shadeView addGestureRecognizer:tapGR];
        [_shadeView addGestureRecognizer:panGR];
    }
    return _shadeView;
}
-(void)avtarClick:(NSNotification *)noti{
    if ([noti.name isEqualToString:AVTAR_CLICK_NOTI]){
        [self showLeftViewAnimation];
    }
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(instancetype)initWithMainViewController:(UIViewController *)mainVc leftVC:(UIViewController *)leftVc{
    self = [super init];
    if (self){
        [self addChildViewController:mainVc];
        self.mainVC = mainVc;
        [self addChildViewController:leftVc];
        self.leftVC = leftVc;
        
    }
    self.view.backgroundColor = [UIColor whiteColor];
    self.view.autoresizesSubviews = NO; // 防止无缘无故的旋转大小问题
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:leftVc.view];
    [self.view addSubview:mainVc.view];
    self.mainView = mainVc.view;
    self.leftView = leftVc.view;
    self.leftView.frame = CGRectMake(-MAXEXCURSION, 0, MAXEXCURSION, CJScreenHeight);
    
    UIPanGestureRecognizer *rightGes = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(rightSwipe:)];
   
    
    [leftVc.view addGestureRecognizer:rightGes];
    
    UIPanGestureRecognizer *ges = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panGes:)];
    [mainVc.view addGestureRecognizer:ges];
    ges.delegate = self;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(rotateChange) name:ROTATE_NOTI object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(avtarClick:) name:AVTAR_CLICK_NOTI object:nil];
    
    self.isInLeft = NO;
    return self;
}

-(void)rotateChange{
    
    self.leftView.frame = CGRectMake(-MAXEXCURSION, 0, MAXEXCURSION, CJScreenHeight);
    self.mainView.frame = CGRectMake(0, 0, CJScreenWidth, CJScreenHeight);
    self.shadeView.cj_height = CJScreenHeight;
    self.shadeView.cj_width = CJScreenWidth;
    if (self.isInLeft){
        self.leftView.frame = CGRectMake(0, 0, MAXEXCURSION, CJScreenHeight);
        self.mainView.frame = CGRectMake(MAXEXCURSION, 0, CJScreenWidth, CJScreenHeight);
    }

}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)ges{
    UITabBarController *tab = (UITabBarController *)self.mainVC;
    CGPoint clickPoint = [ges locationInView:self.mainView];
    if (clickPoint.x < LEFTMAXWIDTH && tab.selectedViewController.childViewControllers.count == 1) return YES;
    return NO;
}


-(void)showLeftViewAnimation{
    if ([self reGetRlmBooks].count <= 0) return;
    if (!self.shadeView.superview){
        [self.mainView addSubview:self.shadeView];
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        self.leftView.frame = CGRectMake(0, 0, MAXEXCURSION, CJScreenHeight);
        self.mainView.frame = CGRectMake(MAXEXCURSION, 0, CJScreenWidth, self.mainView.cj_height);
        self.shadeView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        
    }];
    self.isInLeft = YES;
}
-(void)hiddenLeftViewAnimation{
    
    [UIView animateWithDuration:0.25 animations:^{
        self.leftView.frame = CGRectMake(-MAXEXCURSION, 0, MAXEXCURSION, CJScreenHeight);
        self.mainView.frame = CGRectMake(0, 0, CJScreenWidth, self.mainView.cj_height);
    } completion:^(BOOL finished) {
        [self.shadeView removeFromSuperview];
    }];
    self.isInLeft = NO;
    
}

-(void)rightSwipe:(UIPanGestureRecognizer *)ges{
    [self.view endEditing:YES];
    
    CGPoint position = [ges translationInView:self.leftView];
    if (ges.state == UIGestureRecognizerStateEnded) {
        if (position.x >= 0.0)return;
        if (fabs(position.x) > MAXEXCURSION * 0.3) {
            [self hiddenLeftViewAnimation];
        } else {
            [self showLeftViewAnimation];
        }

        return;
    }
    if (position.x >= 0.0){
        return;
    }
    
    
    
    [self showMainViewAnimationWithExcursion:fabs(position.x)];
}

-(void)showMainViewAnimationWithExcursion:(CGFloat)excursion{
    _mainView.cj_x = MAXEXCURSION - excursion;
    _leftView.cj_x = -excursion;
    self.shadeView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5 * (excursion / MAXEXCURSION)];
    if (!self.shadeView.superview) {
        [self.mainView addSubview:self.shadeView];
    }
    self.isInLeft = NO;
}

-(NSMutableArray *)reGetRlmBooks{
    RLMRealm *rlm = [CJRlm shareRlm];
    NSMutableArray *array = [NSMutableArray array];
    
    NSMutableArray *books= [CJBook cjAllObjectsInRlm:rlm];
    for (CJBook *b in books) {
        if ([b.name isEqualToString:@"Trash"] || [b.name isEqualToString:@"All Notes"] || [b.name isEqualToString:@"Recents"]){
            continue;
        }
        [array addObject:b];
    }
    return array;
}

-(void)panGes:(UIPanGestureRecognizer *)ges{
    
    [self.view endEditing:YES];
    CGPoint clickPoint = [ges locationInView:self.mainView];
    CGPoint position = [ges translationInView:self.mainView];
    if (ges.state == UIGestureRecognizerStateBegan) {
        // 判断手势起始点是否在最左边区域
        self.isBestLeft = clickPoint.x < LEFTMAXWIDTH;
    }
    if (ges.state == UIGestureRecognizerStateEnded) {
        if (position.x > MAXEXCURSION * 0.3) {
            [self showLeftViewAnimation];
        } else {
            [self hiddenLeftViewAnimation];
        }
        
        return;
    }
    if (position.x < 0 || position.x > MAXEXCURSION || !self.isBestLeft) {
        return;
    }
    [self showLeftViewAnimationWithExcursion:position.x];
}
- (void)showLeftViewAnimationWithExcursion:(CGFloat)excursion {
    if ([self reGetRlmBooks].count <= 0) return;
    _mainView.cj_x = excursion;
    _leftView.cj_x = -MAXEXCURSION + excursion;
    self.shadeView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5 * (excursion / MAXEXCURSION)];
    if (!self.shadeView.superview) {
        [self.mainView addSubview:self.shadeView];
    }
    self.isInLeft = YES;
}

-(void)viewWillLayoutSubviews{
    if (IPHONE_X){
        return;
    }
    CGFloat h = [UIApplication sharedApplication].statusBarFrame.size.height;
    if (h>20){
        CGFloat up = h - 20;
        self.view.cj_height = CJScreenHeight - up;
        self.mainView.cj_height = CJScreenHeight - up;
    }else if(h <= 20){
        // 说明正常的情况
        self.view.cj_height = CJScreenHeight;
        self.mainView.cj_height = CJScreenHeight;
    }
}

@end
