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
#import "CJFavouriteVC.h"
#import "CJTabBarVC.h"
#define MAXEXCURSION CJScreenWidth * 0.8
#define LEFTMAXWIDTH CJScreenWidth * 0.4


@interface CJLeftXViewController ()<UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate>
@property(nonatomic,weak)UIView *mainView;
@property (nonatomic, assign) BOOL isBestLeft;
@property (nonatomic, strong) UIView *shadeView;
@property (nonatomic,strong) CJLeftView *leftView;
@property (nonatomic,assign) NSUInteger selectRow;
@property (nonatomic,strong) UIViewController *mainVC;
@property(nonatomic,strong) NSMutableArray <NSDictionary *> *accounts;
@property(nonatomic,assign) BOOL isInLeft;

@end
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
    vc.modalPresentationStyle = UIModalPresentationOverFullScreen;
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
        static NSString *cellid = @"cellid";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellid];
        
        if (!cell){
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellid];
        }
        cell.detailTextLabel.text = @"";
        NSInteger row = indexPath.row;
        NSString *text;
        NSString *imageName;
        switch (row) {
                break;
            case 1:
                imageName = @"垃圾侧";
                text = @"回收站";
                break;
            case 0:
                imageName = @"最近侧";
                text = @"最近";
                break;
            case 2:
                imageName = @"上下";
                cell.detailTextLabel.text = [CJTool getNoteOrderFromPlist];
                cell.detailTextLabel.textColor = [UIColor whiteColor];
                text = @"笔记排序";
                break;
            case 3:
                imageName = @"收藏白";
                text = @"收藏";
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
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, cell.cj_height-lineH, tableView.cj_width, lineH)];
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
    if (tableView == self.leftView.tableView){ // 左滑出现的菜单
        
        UITabBarController *tab = (UITabBarController *)self.mainVC;
        UINavigationController *navc = tab.viewControllers[0];
        NSIndexPath *lastIndexpath = [NSIndexPath indexPathForRow:self.selectRow inSection:0];
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:lastIndexpath];
        if (indexPath.row != 2){
            cell.backgroundColor = BlueBg;
            cell = [tableView cellForRowAtIndexPath:indexPath];
            cell.backgroundColor = SelectCellBg;
            self.selectRow = indexPath.row;
            tab.selectedIndex = 0;
        }
        if (indexPath.row == 0){
            [self hiddenLeftViewAnimation];
            CJRecentVC *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"recentVC"];
            [navc setViewControllers:@[vc]];
        }
        else if (indexPath.row == 1){
            [self hiddenLeftViewAnimation];
            CJRecycleBinVC *vc = [[CJRecycleBinVC alloc]init];
            [navc setViewControllers:@[vc]];
        }else if (indexPath.row == 2){
            cell = [tableView cellForRowAtIndexPath:indexPath];
            UIAlertController *vc = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
            UIAlertAction *up = [UIAlertAction actionWithTitle:@"标题 ↑" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [CJTool catchNoteOrder2Plist:NoteOrderTypeUp];
                cell.detailTextLabel.text = NoteOrderTypeUp;
            }];
            UIAlertAction *down = [UIAlertAction actionWithTitle:@"标题 ↓" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [CJTool catchNoteOrder2Plist:NoteOrderTypeDown];
                cell.detailTextLabel.text = NoteOrderTypeDown;
            }];
            [vc addAction:cancel];
            [vc addAction:up];
            [vc addAction:down];
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                UIPopoverPresentationController *popover = vc.popoverPresentationController;
                
                if (popover) {
                    popover.sourceView = cell;
                    popover.sourceRect = cell.bounds;
                    popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
                }
                [self presentViewController:vc animated:YES completion:nil];
            }];
            
            
        }else if (indexPath.row == 3){
            [self hiddenLeftViewAnimation];
            CJFavouriteVC *vc = [[CJFavouriteVC alloc]init];
            [navc setViewControllers:@[vc]];
        }
        
    }else if (tableView == self.leftView.accountTableView){ // 账号栏
        
        [self hiddenLeftViewAnimation];
        NSDictionary *dict = self.accounts[indexPath.row];
        CJUser *user = [CJUser sharedUser];
        if ([user.email isEqualToString:dict[@"email"]]) return;
        CJProgressHUD *hud = [CJProgressHUD cjShowInView:self.view timeOut:TIME_OUT withText:@"加载中..." withImages:nil];
        CJWeak(self)
        NSLog(@"dict=%@",dict);
        [CJAPI loginWithParams:@{@"email":dict[@"email"],@"passwd":dict[@"password"]} success:^(NSDictionary *dic) {
            if ([dic[@"status"] intValue] == 0){
                weakself.leftView.emailL.text = self.accounts[indexPath.row][@"email"];
                [hud cjShowSuccess:@"切换成功"];
            }
            else{
                // 来到这说明密码已经被更改，触发退出登录操作然后重新登录
                CJTabBarVC *tabVC = (CJTabBarVC *)self.tabBarController;
                CJLeftXViewController *vc = (CJLeftXViewController *)[tabVC parentViewController];
                [vc toRootViewController];
                NSUserDefaults *userD = [NSUserDefaults standardUserDefaults];
                [userD removeObjectForKey:@"email"];
                [userD removeObjectForKey:@"password"];
                [userD synchronize];
             
            }
        } failure:^(NSError *error) {
            [hud cjShowError:net101code];
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeAccount:) name:LOGIN_ACCOUT_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(avtarClick:) name:AVTAR_CLICK_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeAccount:) name:ACCOUNT_NUM_CHANGE_NOTI object:nil];
    
}

-(void)avtarClick:(NSNotification *)noti{
    if ([noti.name isEqualToString:AVTAR_CLICK_NOTI]){
        [self showLeftViewAnimation];
    }
}
-(void)changeAccount:(NSNotification *)noti{
    self.accounts = nil;
    [self.leftView.accountTableView reloadData];
    [self.leftView.tableView reloadData];
    self.leftView.emailL.text = [CJUser sharedUser].email;

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
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.leftView];
    
    [self.view addSubview:mainVc.view];
    self.mainView = mainVc.view;
    UIPanGestureRecognizer *ges = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panGes:)];
    [mainVc.view addGestureRecognizer:ges];
    ges.delegate = self;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(rotateChange) name:ROTATE_NOTI object:nil];
    self.isInLeft = NO;
    return self;
    
}

-(void)rotateChange{
    
//    _leftView.frame = CGRectMake(-MAXEXCURSION, 0, MAXEXCURSION, CJScreenHeight);
//    self.shadeView.cj_height = CJScreenHeight;
//    self.shadeView.cj_width = CJScreenWidth;
//    [self.leftView.tableView reloadData];
//    if (self.isInLeft){
//        _leftView.frame = CGRectMake(0, 0, MAXEXCURSION, CJScreenHeight);
//        _mainView.frame = CGRectMake(MAXEXCURSION, 0, CJScreenWidth, CJScreenHeight);
//    }
//    
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)ges{
    UITabBarController *tab = (UITabBarController *)self.mainVC;
    CGPoint clickPoint = [ges locationInView:self.mainView];
    if (clickPoint.x < LEFTMAXWIDTH && tab.selectedViewController.childViewControllers.count == 1) return YES;
    
    return NO;
}


-(void)showLeftViewAnimation{
    [UIView animateWithDuration:0.25 animations:^{
        self.leftView.frame = CGRectMake(0, 0, MAXEXCURSION, CJScreenHeight);
        self.mainView.frame = CGRectMake(MAXEXCURSION, 0, CJScreenWidth, CJScreenHeight);
        self.shadeView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        [self.mainView addSubview:self.shadeView];
    }];
    self.isInLeft = YES;
}
-(void)hiddenLeftViewAnimation{
    [UIView animateWithDuration:0.25 animations:^{
        self.leftView.frame = CGRectMake(-MAXEXCURSION, 0, MAXEXCURSION, CJScreenHeight);
        self.mainView.frame = CGRectMake(0, 0, CJScreenWidth, CJScreenHeight);
        [self.shadeView removeFromSuperview];
    }];
    self.isInLeft = NO;
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
    _mainView.cj_x = excursion;
    _leftView.cj_x = -MAXEXCURSION + excursion;
//    _leftView.cj_x = -excursion + MAXEXCURSION;
//    self.mainView.transform = CGAffineTransformTranslate(self.view.transform, excursion, 0);
//    self.leftView.transform = CGAffineTransformTranslate(self.view.transform, excursion, 0);
    self.shadeView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5 * (excursion / MAXEXCURSION)];
    if (!self.shadeView.superview) {
        [self.mainView addSubview:self.shadeView];
    }
    self.isInLeft = YES;
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
