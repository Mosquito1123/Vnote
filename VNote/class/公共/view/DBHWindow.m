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
#import "CJAccountCell.h"
static NSString * const kDBHTableViewCellIdentifier = @"kDBHTableViewCellIdentifier";
static NSString * const accountCell = @"accountCell";

@interface DBHWindow ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UIView *shadeView;
@property (nonatomic,strong) CJLeftView *leftView;
@property(nonatomic,copy) void (^addAccountBlock)(void);
@property(nonatomic,copy) void (^userInfoBlock)(void);
@property(nonatomic,copy) void (^didSelectBlock)(NSIndexPath *);
@property(nonatomic,strong) NSMutableArray <NSDictionary *> *accounts;
@end

@implementation DBHWindow

-(NSMutableArray *)accounts{
    if (!_accounts){
        NSUserDefaults *userD = [NSUserDefaults standardUserDefaults];
        _accounts = [NSMutableArray arrayWithArray:[userD objectForKey:ALL_ACCOUNT]];
    }
    return _accounts;
}

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
    [self hiddenLeftViewAnimation];
    if (self.userInfoBlock) self.userInfoBlock();
}
-(CJLeftView *)leftView{
    if(!_leftView){
        _leftView = [CJLeftView xibLeftView];
        _leftView.frame = CGRectMake(0, 0, -MAXEXCURSION, CJScreenHeight);
        _leftView.tableView.delegate = self;
        _leftView.tableView.dataSource = self;
        _leftView.accountTableView.delegate = self;
        _leftView.accountTableView.dataSource = self;
        [_leftView.accountTableView registerNib:[UINib nibWithNibName:@"CJAccountCell" bundle:nil] forCellReuseIdentifier:accountCell];;
        _leftView.accountTableView.tableFooterView = [[UIView alloc]init];
        [_leftView.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kDBHTableViewCellIdentifier];
        _leftView.accountTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _leftView.tableView.backgroundColor = BlueBg;
        _leftView.accountTableView.backgroundColor = BlueBg;
        _leftView.tableView.tableFooterView = [[UIView alloc]init];
        [_leftView.userInfoBtn addTarget:self action:@selector(userInfo) forControlEvents:UIControlEventTouchUpInside];
        [_leftView.addAccountBtn addTarget:self action:@selector(addAccount) forControlEvents:UIControlEventTouchUpInside];
        _leftView.accountTableView.bounces = NO;
        _leftView.tableView.bounces = NO;
    }
    return _leftView;
}

#pragma mark - Lifecycle
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self addSubview:self.leftView];
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(loginAccountNoti:) name:LOGIN_ACCOUT_NOTI object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changeAccountNoti:) name:CHANGE_ACCOUNT_NOTI object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(addAccountNoti:) name:ACCOUNT_NUM_CHANGE_NOTI object:nil];
    }
    return self;
}
-(void)loginAccountNoti:(NSNotification *)noti{
    if ([noti.name isEqualToString:LOGIN_ACCOUT_NOTI]){
        self.accounts = nil;
        CJUser *user = [CJUser sharedUser];
        self.leftView.emailL.text = user.email;
        [self.leftView.accountTableView reloadData];
    }
}

-(void)changeAccountNoti:(NSNotification *)noti{
    if ([noti.name isEqualToString:CHANGE_ACCOUNT_NOTI]){
        [self.leftView.accountTableView reloadData];
        CJUser *user = [CJUser sharedUser];
        self.leftView.emailL.text = user.email;
        
    }
}
-(void)addAccountNoti:(NSNotification *)noti{
    
    if ([noti.name isEqualToString:ACCOUNT_NUM_CHANGE_NOTI]){
        self.accounts = nil;
        [self.leftView.accountTableView reloadData];
    }
}


-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.leftView.tableView){
        return 2;
    }else{
        return self.accounts.count;
    }
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.leftView.tableView){
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kDBHTableViewCellIdentifier forIndexPath:indexPath];
        NSInteger row = indexPath.row;
        NSString *text;
        switch (row) {
                break;
            case 0:
                text = @"回收站";
                break;
            case 1:
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
    }else{
        CJAccountCell *cell = [tableView dequeueReusableCellWithIdentifier:accountCell forIndexPath:indexPath];
        NSDictionary *dict = self.accounts[indexPath.row];
        if ([dict[@"avtar_url"] length]){
            cell.avtar.yy_imageURL = IMG_URL(dict[@"avtar_url"]);
            
        }else{
            cell.avtar.image = [UIImage imageNamed:@"avtar"];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = BlueBg;
        CJUser *user = [CJUser sharedUser];
        if ([dict[@"email"] isEqualToString:user.email]){
            cell.backgroundColor = SelectCellBg;
        }
        return cell;
        
    }
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.leftView.tableView){
        [self hiddenLeftViewAnimation];
        if (self.didSelectBlock) self.didSelectBlock(indexPath);
    }else if (tableView == self.leftView.accountTableView){
        
        [self hiddenLeftViewAnimation];
        
        CJProgressHUD *hud = [CJProgressHUD cjShowWithPosition:CJProgressHUDPositionBothExist timeOut:0 withText:@"加载中..." withImages:nil];
        AFHTTPSessionManager *manger = [AFHTTPSessionManager manager];
        NSDictionary *dict = self.accounts[indexPath.row];
        CJLog(@"%@",dict);
        [manger POST:API_LOGIN parameters:@{@"email":dict[@"email"],@"passwd":dict[@"password"]} progress:^(NSProgress * _Nonnull uploadProgress) {

        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSDictionary *dict = responseObject;

            if ([dict[@"status"] intValue] == 0){
                [CJUser userWithDict:dict];
                NSNotification *noti = [NSNotification notificationWithName:CHANGE_ACCOUNT_NOTI object:nil];
                [[NSNotificationCenter defaultCenter]postNotification:noti];
                self.leftView.emailL.text = self.accounts[indexPath.row][@"email"];
                [hud cjShowSuccess:@"切换成功"];
            }
            else{
                [hud cjShowError:@"切换失败"];
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [hud cjShowError:@"切换失败"];
        }];
    }
    
    
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
//    NSLog(@"{%f-%f}",point.x,point.y);
    if (!view) {
        CGPoint newPoint = [self.leftView convertPoint:point fromView:self];
        if (CGRectContainsPoint(self.leftView.bounds, newPoint)) {
            CGPoint childP =[self convertPoint:point toView:self.leftView];
            view = [self.leftView hitTest:childP withEvent:event];
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
