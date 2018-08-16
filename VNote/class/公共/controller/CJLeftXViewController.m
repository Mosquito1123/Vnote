//
//  CJLeftViewController.m
//  left
//
//  Created by ccj on 2018/8/14.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import "CJLeftXViewController.h"
#import "CJLeftView.h"
#import "CJAccountCell.h"
#import "CJAddAccountVC.h"
#import "CJAccountVC.h"
#import "CJRecycleBinVC.h"
#import "CJRecentVC.h"
#import "CJPenFriendVC.h"
#define MAXEXCURSION CJScreenWidth * 0.8
#define LEFTMAXWIDTH CJScreenWidth * 0.2


@interface CJLeftXViewController ()<UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate>
@property(nonatomic,weak)UIView *mainView;
@property (nonatomic, assign) BOOL isBestLeft;
@property (nonatomic, strong) UIView *shadeView;
@property (nonatomic,strong) CJLeftView *leftView;
@property (nonatomic,assign) NSUInteger selectRow;
@property (nonatomic,strong) UIViewController *mainVC;
@property(nonatomic,strong) NSMutableArray <NSDictionary *> *accounts;
@end
static NSString * const kDBHTableViewCellIdentifier = @"kDBHTableViewCellIdentifier";
static NSString * const accountCell = @"accountCell";

@implementation CJLeftXViewController

-(void)setSelectRow:(NSUInteger)selectRow{
    _selectRow = selectRow;
    [self.leftView.tableView reloadData];
}

-(NSMutableArray *)accounts{
    if (!_accounts){
        NSUserDefaults *userD = [NSUserDefaults standardUserDefaults];
        _accounts = [NSMutableArray arrayWithArray:[userD objectForKey:ALL_ACCOUNT]];
    }
    return _accounts;
}
-(CJLeftView *)leftView{
    if(!_leftView){
        _leftView = [CJLeftView xibLeftView];
        _leftView.frame = CGRectMake(-MAXEXCURSION, 0, MAXEXCURSION, CJScreenHeight);
        _leftView.tableView.delegate = self;
        _leftView.tableView.dataSource = self;
        _leftView.accountTableView.delegate = self;
        _leftView.accountTableView.dataSource = self;
        [_leftView.accountTableView registerNib:[UINib nibWithNibName:@"CJAccountCell" bundle:nil] forCellReuseIdentifier:accountCell];;
        _leftView.accountTableView.tableFooterView = [[UIView alloc]init];
        [_leftView.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kDBHTableViewCellIdentifier];
        _leftView.accountTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _leftView.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
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

-(void)userInfo{
    [self hiddenLeftViewAnimation];
    CJAccountVC *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"accountVC"];
    UITabBarController *tabVC = (UITabBarController *)self.mainVC;
    CJMainNaVC *navc = tabVC.selectedViewController;
    [navc pushViewController:vc animated:YES];
}

-(void)addAccount{
    CJAddAccountVC *vc = [[CJAddAccountVC alloc]init];
    [self presentViewController:vc animated:YES completion:nil];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.leftView.tableView){
        return 3;
    }else{
        return self.accounts.count;
    }
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.leftView.tableView){
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kDBHTableViewCellIdentifier forIndexPath:indexPath];
        NSInteger row = indexPath.row;
        NSString *text;
        NSString *imageName;
        switch (row) {
                break;
            case 1:
                imageName = @"垃圾侧";
                text = @"回收站";
                break;
            case 2:
                imageName = @"关注侧";
                text = @"关注";
                break;
            case 0:
                imageName = @"最近侧";
                text = @"最近";
                break;
            default:
                break;
        }
        cell.textLabel.text = text;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = BlueBg;
        cell.textLabel.font = [UIFont systemFontOfSize:16];
        cell.imageView.image = [UIImage imageNamed:imageName];
        cell.textLabel.textColor = [UIColor whiteColor];
        CGFloat lineH = 0.5;
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, cell.cj_height-lineH, cell.cj_width, lineH)];
        line.backgroundColor = SelectCellBg;
        [cell addSubview:line];
        if (indexPath.row == self.selectRow){
            cell.backgroundColor = SelectCellBg;
        }
        return cell;
    }else{
        CJAccountCell *cell = [tableView dequeueReusableCellWithIdentifier:accountCell forIndexPath:indexPath];
        NSDictionary *dict = self.accounts[indexPath.row];
        cell.avtar.backgroundColor = [UIColor whiteColor];
        [cell.avtar yy_setImageWithURL:IMG_URL(dict[@"avtar_url"]) placeholder:[UIImage imageNamed:@"avtar"]];
        
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
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
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (tableView == self.leftView.tableView){
        [self hiddenLeftViewAnimation];
        NSIndexPath *lastIndexpath = [NSIndexPath indexPathForRow:self.selectRow inSection:0];
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:lastIndexpath];
        cell.backgroundColor = BlueBg;
        cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.backgroundColor = SelectCellBg;
        self.selectRow = indexPath.row;
        UITabBarController *tab = (UITabBarController *)self.mainVC;
        UINavigationController *navc = tab.viewControllers[0];
        tab.selectedIndex = 0;
        if (indexPath.row == 0){
            CJRecentVC *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"recentVC"];
            [navc setViewControllers:@[vc]];
        }
        else if (indexPath.row == 1){
            CJRecycleBinVC *vc = [[CJRecycleBinVC alloc]init];
            [navc setViewControllers:@[vc]];
        }else if(indexPath.row == 2){
            CJPenFriendVC *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"penFriendVC"];
            [navc setViewControllers:@[vc]];
        }
        
    }else if (tableView == self.leftView.accountTableView){
        
        [self hiddenLeftViewAnimation];

        NSDictionary *dict = self.accounts[indexPath.row];
        CJUser *user = [CJUser sharedUser];
        if ([user.email isEqualToString:dict[@"email"]]) return;
        CJProgressHUD *hud = [CJProgressHUD cjShowWithPosition:CJProgressHUDPositionBothExist timeOut:0 withText:@"加载中..." withImages:nil];
        AFHTTPSessionManager *manger = [AFHTTPSessionManager manager];
        [manger POST:API_LOGIN parameters:@{@"email":dict[@"email"],@"passwd":dict[@"password"]} progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSDictionary *dict = responseObject;
            
            if ([dict[@"status"] intValue] == 0){
                [CJUser userWithDict:dict];
                NSNotification *noti = [NSNotification notificationWithName:CHANGE_ACCOUNT_NOTI object:nil];
                [[NSNotificationCenter defaultCenter]postNotification:noti];
                self.leftView.emailL.text = self.accounts[indexPath.row][@"email"];
                [hud cjShowSuccess:@"切换成功"];
                [self.leftView.accountTableView reloadData];
            }
            else{
                [hud cjShowError:@"切换失败"];
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [hud cjShowError:@"切换失败"];
        }];
    }
    
    
}


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
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeAccount:) name:CHANGE_ACCOUNT_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(avtarClick:) name:AVTAR_CLICK_NOTI object:nil];
}

-(void)avtarClick:(NSNotification *)noti{
    if ([noti.name isEqualToString:AVTAR_CLICK_NOTI]){
        [self showLeftViewAnimation];
    }
}
-(void)changeAccount:(NSNotification *)noti{
    if ([noti.name isEqualToString:CHANGE_ACCOUNT_NOTI]){
        [self.leftView.accountTableView reloadData];
    }
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
-(instancetype)initWithMainViewController:(UIViewController *)mainVc{
    self = [super init];
    if (self){
        [self addChildViewController:mainVc];
        self.mainVC = mainVc;
    }
    self.view.backgroundColor = BlueBg;
    [self.view addSubview:self.leftView];
    [self.view addSubview:mainVc.view];
    self.mainView = mainVc.view;
    UIPanGestureRecognizer *ges = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panGes:)];
    [mainVc.view addGestureRecognizer:ges];
    ges.delegate = self;
    
    return self;
    
}
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)ges{
    UITabBarController *tab = (UITabBarController *)self.mainVC;
    CGPoint clickPoint = [ges locationInView:self.mainView];
    if (clickPoint.x < LEFTMAXWIDTH && tab.selectedViewController.childViewControllers.count == 1) return YES;
    
    return NO;
    
}

-(void)showLeftViewAnimation{
    [UIView animateWithDuration:0.25 animations:^{
        self.mainView.transform = CGAffineTransformTranslate(self.view.transform, MAXEXCURSION, 0);
        self.leftView.transform = CGAffineTransformTranslate(self.view.transform, MAXEXCURSION, 0);
        self.shadeView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        [self.mainView addSubview:self.shadeView];
    }];
}
-(void)hiddenLeftViewAnimation{
    [UIView animateWithDuration:0.25 animations:^{
        self.mainView.transform = CGAffineTransformIdentity;
        self.leftView.transform = CGAffineTransformIdentity;
        [self.shadeView removeFromSuperview];
    }];
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
        if (position.x > MAXEXCURSION * 0.5) {
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
    self.mainView.transform = CGAffineTransformTranslate(self.view.transform, excursion, 0);
    self.leftView.transform = CGAffineTransformTranslate(self.view.transform, excursion, 0);
    self.shadeView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5 * (excursion / MAXEXCURSION)];
    if (!self.shadeView.superview) {
        [self.mainView addSubview:self.shadeView];
    }
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

@end
