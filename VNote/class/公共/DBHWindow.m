//
//  DBHWindow.m
//  DBHSideslipMenu
//
//  Created by 邓毕华 on 2017/11/10.
//  Copyright © 2017年 邓毕华. All rights reserved.
//

#import "DBHWindow.h"
#import "CJLeftView.h"
#import "CJTabBarVC.h"
#import "CJLoginVC.h"
#import "CJTabBarVC.h"
static NSString * const kDBHTableViewCellIdentifier = @"kDBHTableViewCellIdentifier";

@interface DBHWindow ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UIView *shadeView;
@property (nonatomic,strong) CJLeftView *leftView;
@property(nonatomic,copy) void (^addAccountBlock)(void);
@property(nonatomic,copy) void (^userInfoBlock)(void);
@property(nonatomic,copy) void (^didSelectBlock)(NSIndexPath *);
@end

@implementation DBHWindow

-(void)addAccountClick:(void (^)(void))addAccount userInfoClick:(void (^)(void))userInfoClick didSelectIndexPath:(void (^)(NSIndexPath *))didSelectIndexPath{
    self.addAccountBlock = addAccount;
    self.userInfoBlock = userInfoClick;
    self.didSelectBlock = didSelectIndexPath;
}
-(void)addAccount{
    [self hiddenLeftViewAnimation];
    if (self.addAccountBlock) self.addAccountBlock();
}

-(void)userInfo{
    NSLog(@"-------");
    [self hiddenLeftViewAnimation];
    if (self.userInfoBlock) self.userInfoBlock();
}
-(CJLeftView *)leftView{
    if(!_leftView){
        _leftView = [CJLeftView xibLeftView];
        _leftView.frame = CGRectMake(0, 0, -MAXEXCURSION, CJScreenHeight);
        _leftView.tableView.delegate = self;
        _leftView.tableView.dataSource = self;
        [_leftView.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kDBHTableViewCellIdentifier];
        _leftView.tableView.backgroundColor = BlueBg;
        _leftView.tableView.tableFooterView = [[UIView alloc]init];
        [_leftView.userInfoBtn addTarget:self action:@selector(userInfo) forControlEvents:UIControlEventTouchUpInside];
        
        [_leftView.addAccountBtn addTarget:self action:@selector(addAccount) forControlEvents:UIControlEventTouchUpInside];
    }
    return _leftView;
}

#pragma mark - Lifecycle
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self addSubview:self.leftView];
    }
    return self;
}



#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kDBHTableViewCellIdentifier forIndexPath:indexPath];
    NSInteger row = indexPath.row;
    NSString *text;
    switch (row) {
        case 0:
            text = @"个人笔记";
            break;
        case 1:
            text = @"回收站";
            break;
        case 2:
            text = @"笔友信息";
            break;
        default:
            break;
    }
    cell.textLabel.text = text;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = BlueBg;
    cell.textLabel.textColor = [UIColor whiteColor];
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self hiddenLeftViewAnimation];
    if (self.didSelectBlock) self.didSelectBlock(indexPath);
    
}

#pragma mark - Event Responds
/**
 点击了右侧半透明区域
 */
- (void)respondsToShadeView {
    [self hiddenLeftViewAnimation];
}
/**
 右侧半透明区域的左滑手势
 */
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

#pragma mark - Public Methdos
/**
 显示左侧视图动画
 */
- (void)showLeftViewAnimation {
    
    [UIView animateWithDuration:0.25 animations:^{
        self.transform = CGAffineTransformTranslate(self.rootViewController.view.transform, MAXEXCURSION, 0);
        self.shadeView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        [self addSubview:self.shadeView];
    }];
}
/**
 显示左侧视图
 
 @param excursion 偏移大小
 */
- (void)showLeftViewAnimationWithExcursion:(CGFloat)excursion {
    self.transform = CGAffineTransformTranslate(self.rootViewController.view.transform, excursion, 0);
    self.shadeView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5 * (excursion / MAXEXCURSION)];
    if (!self.shadeView.superview) {
        [self addSubview:self.shadeView];
    }
}
/**
 隐藏左侧视图动画
 */
- (void)hiddenLeftViewAnimation {
    
    [UIView animateWithDuration:0.25 animations:^{
        self.transform = CGAffineTransformIdentity;
        [self.shadeView removeFromSuperview];
    }];
}

#pragma mark - Private Methdos
/**
 重写hitTest方法，点击tableView才会响应
 */
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    if (!view) {
        CGPoint newPoint = [self.leftView.tableView convertPoint:point fromView:self.leftView];
        if (CGRectContainsPoint(self.leftView.tableView.bounds, newPoint)) {
            view = self.leftView.tableView;
        }
    }
    return view;
}

- (UIView *)shadeView {
    if (!_shadeView) {
        _shadeView = [[UIView alloc] initWithFrame:self.bounds];
        _shadeView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        
        UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(respondsToShadeView)];
        UIPanGestureRecognizer *panGR = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(respondsToPanGR:)];
        [_shadeView addGestureRecognizer:tapGR];
        [_shadeView addGestureRecognizer:panGR];
    }
    return _shadeView;
}

@end
