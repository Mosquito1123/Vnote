//
//  CJTabBarVC.m
//  VNote
//
//  Created by ccj on 2018/7/8.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import "CJTabBarVC.h"
#import "CJCustomBtn.h"
#import "CJAccountVC.h"
#import "CJAddAccountVC.h"
#import "CJRecycleBinVC.h"
#import "CJPenFriendVC.h"
#import "CJRecentVC.h"
#import "CJSearchUserVC.h"
#import "CJSearchVC.h"
const CGFloat menuHPercent = 0.5;
const CGFloat logoHPercent = 0.2;
const CGFloat logoAlphaMin = 0.01;
const CGFloat logoAlphaMax = 1.0;
@interface CJTabBarVC ()<UIGestureRecognizerDelegate,UITabBarControllerDelegate>
@property(nonatomic,strong) UIVisualEffectView *visualView;
@property(nonatomic,strong) UIButton *minusBtn;
@property(nonatomic,strong) CJCustomBtn *addBookBtn;
@property(nonatomic,strong) CJCustomBtn *addNoteBtn;
@property(nonatomic,strong) CJCustomBtn *addFBtn;
@property(nonatomic,strong) UIImageView *weNoteImgView;
@end

@implementation CJTabBarVC


-(UIButton *)minusBtn{
    if (!_minusBtn){
        _minusBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_minusBtn setImage:[UIImage imageNamed:@"加灰"] forState:UIControlStateNormal];
        [_minusBtn sizeToFit];
        [_minusBtn addTarget:self action:@selector(minusClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _minusBtn;
}

-(UIVisualEffectView *)visualView{
    if (!_visualView){
        _visualView = [[UIVisualEffectView alloc]initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        _visualView.frame = window.bounds;
        [_visualView.contentView addSubview:self.minusBtn];
        self.minusBtn.cj_centerX = _visualView.cj_centerX;
        self.minusBtn.cj_centerY = self.visualView.cj_height - self.tabBar.cj_height/2;
        [_visualView.contentView addSubview:self.addBookBtn];
        [_visualView.contentView addSubview:self.addNoteBtn];
        [_visualView.contentView addSubview:self.addFBtn];
        UIImageView *imgView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"WeNote白"]];
        [imgView sizeToFit];
        self.weNoteImgView= imgView;
        self.weNoteImgView.alpha = logoAlphaMin;
        imgView.cj_centerX = _visualView.cj_width / 2;
        imgView.cj_y = _visualView.cj_height * logoHPercent;
        [_visualView.contentView addSubview:imgView];
        CGFloat width = self.addBookBtn.cj_width;
        CGFloat gap = (_visualView.cj_width - 4 * width) / 5;
        self.addBookBtn.cj_x = gap;
        self.addBookBtn.cj_y = _visualView.cj_height;
        self.addNoteBtn.cj_x = self.addBookBtn.cj_maxX + gap;
        self.addNoteBtn.cj_y = self.addBookBtn.cj_y;
        self.addFBtn.cj_x = self.addNoteBtn.cj_maxX + gap;
        self.addFBtn.cj_y = self.addBookBtn.cj_y;
    }
    return _visualView;
}


-(void)viewWillLayoutSubviews{
//    [self changeVisueViewFrame];
    if (IPHONE_X){
        return;
    }
    CGFloat h = [UIApplication sharedApplication].statusBarFrame.size.height;
    if (h>20){
        CGFloat up = h - 20;
        self.view.cj_height = CJScreenHeight - up;
    }else if(h <= 20){
        // 说明正常的情况
        self.view.cj_height = CJScreenHeight;
    }
}

-(void)removeVisualView{
    [self.visualView removeFromSuperview];
    self.minusBtn.transform = CGAffineTransformRotate(self.minusBtn.transform,-M_PI_4);
    CGFloat h = self.visualView.cj_height;
    self.addFBtn.cj_y = self.addNoteBtn.cj_y = self.addBookBtn.cj_y = h;
    
}

-(CJCustomBtn *)addFBtn{
    if (!_addFBtn){
        CJWeak(self)
        _addFBtn = [CJCustomBtn xibCustomBtnWithTapClick:^{
            [weakself removeVisualView];
            CJSearchUserVC *vc = [[CJSearchUserVC alloc]init];
            CJMainNaVC *nav = [[CJMainNaVC alloc]initWithRootViewController:vc];
            nav.modalPresentationStyle = UIModalPresentationOverFullScreen;
            [weakself presentViewController:nav animated:YES completion:nil];
        }];
        _addFBtn.imageView.image = [UIImage imageNamed:@"加好友蓝"];
        _addFBtn.textLabel.text = @"添加好友";
        _addFBtn.textLabel.font = [UIFont systemFontOfSize:12];
        _addFBtn.textLabel.textColor = BlueBg;
        _addFBtn.cj_size = CGSizeMake(80, 50);
        
    }
    return _addFBtn;
}

-(CJCustomBtn *)addBookBtn{
    if (!_addBookBtn){
        CJWeak(self)
        _addBookBtn = [CJCustomBtn xibCustomBtnWithTapClick:^{
            [weakself removeVisualView];
            UINavigationController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"addBookNav"];
            vc.modalPresentationStyle = UIModalPresentationOverFullScreen;
            [weakself presentViewController:vc animated:YES completion:nil];
        }];
        _addBookBtn.imageView.image = [UIImage imageNamed:@"加笔记本蓝"];
        
        _addBookBtn.textLabel.text = @"创建笔记本";
        _addBookBtn.textLabel.font = [UIFont systemFontOfSize:12];
        _addBookBtn.textLabel.textColor = BlueBg;
        _addBookBtn.cj_size = CGSizeMake(80, 50);
        
    }
    return _addBookBtn;
}
-(CJCustomBtn *)addNoteBtn{
    if (!_addNoteBtn){
        CJWeak(self)
        _addNoteBtn = [CJCustomBtn xibCustomBtnWithTapClick:^{
            [weakself removeVisualView];
            RLMRealm *rlm = [CJRlm shareRlm];
            NSMutableArray *res = [CJBook cjAllObjectsInRlm:rlm];
            if (!res.count){
                [CJProgressHUD cjShowErrorWithPosition:CJProgressHUDPositionBothExist withText:@"你未创建笔记本!"];
                return;
            }
            UINavigationController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"addNoteNav"];
            vc.modalPresentationStyle = UIModalPresentationOverFullScreen;
            [weakself presentViewController:vc animated:YES completion:nil];
        }];
        _addNoteBtn.imageView.image = [UIImage imageNamed:@"加笔记蓝"];
        
        _addNoteBtn.textLabel.text = @"添加笔记";
        _addNoteBtn.textLabel.font = [UIFont systemFontOfSize:12];
        _addNoteBtn.textLabel.textColor = BlueBg;
        _addNoteBtn.cj_size = CGSizeMake(80, 50);
    }
    return _addNoteBtn;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.tabBar.translucent = NO;
    UITabBarItem *item = [UITabBarItem appearance];
    NSMutableDictionary *normalAttrs = [NSMutableDictionary dictionary];
    normalAttrs[NSFontAttributeName] = [UIFont systemFontOfSize:11];
    normalAttrs[NSForegroundColorAttributeName] = HeadFontColor;
    [item setTitleTextAttributes:normalAttrs forState:UIControlStateNormal];
    
    NSMutableDictionary *selectedAttrs = [NSMutableDictionary dictionary];
    selectedAttrs[NSForegroundColorAttributeName] = BlueBg;
    [item setTitleTextAttributes:selectedAttrs forState:UIControlStateSelected];
    self.delegate = self;
    
}

-(void)changeChildrenViewControllers{
    BOOL close = [CJTool getClosePenFriendFunc];
    self.addFBtn.hidden = close;
    UINavigationController *nv = self.viewControllers[4];
    if (close){
        CJAccountVC *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"accountVC"];
        [nv setViewControllers:@[vc]];
        nv.tabBarItem.title = @"我的";
        nv.tabBarItem.image = [UIImage imageNamed:@"账号灰"];
        nv.tabBarItem.selectedImage = [UIImage imageNamed:@"账号蓝"];
    }else{
        CJPenFriendVC *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"penFriendVC"];
        [nv setViewControllers:@[vc]];
        nv.tabBarItem.title = @"关注";
        nv.tabBarItem.image = [UIImage imageNamed:@"关注灰"];
        nv.tabBarItem.selectedImage = [UIImage imageNamed:@"关注蓝"];
    }
}


-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
-(void)rotateChange{
//    [self changeVisueViewFrame];
}


-(void)minusClick{
    [UIView animateWithDuration:0.4 animations:^{
        self.minusBtn.transform = CGAffineTransformRotate(self.minusBtn.transform,-M_PI_4);
    }];
    [UIView animateWithDuration:0.5 delay:0.5 usingSpringWithDamping:0.5 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.addBookBtn.cj_y = self.visualView.cj_height;
    } completion:^(BOOL finished){
        [self.visualView removeFromSuperview];
    }];
    
    [UIView animateWithDuration:0.5 delay:0.4 usingSpringWithDamping:0.5 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.addNoteBtn.cj_y = self.visualView.cj_height;
    } completion:nil];
    [UIView animateWithDuration:0.5 delay:0.3 usingSpringWithDamping:0.5 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.addFBtn.cj_y = self.visualView.cj_height;
    } completion:nil];
    [UIView animateWithDuration:0.8 animations:^{
        self.weNoteImgView.alpha = logoAlphaMin;
    }];
    
}

-(void)changeVisueViewFrame{
    self.visualView.cj_height = CJScreenHeight;
    self.visualView.cj_width = CJScreenWidth;
    CGFloat menuH = CJScreenHeight*menuHPercent;
    self.minusBtn.cj_centerX = self.visualView.cj_centerX;
    self.minusBtn.cj_centerY = self.visualView.cj_height - self.tabBar.cj_height/2;
    self.addFBtn.cj_size = self.addBookBtn.cj_size = self.addNoteBtn.cj_size = CGSizeMake(80, 50);
    CGFloat width = self.addBookBtn.cj_width;
    CGFloat gap = (self.visualView.cj_width - 4 * width) / 5;
    
    self.addBookBtn.cj_x = gap;
    self.addNoteBtn.cj_x = self.addBookBtn.cj_maxX + gap;
    self.addFBtn.cj_x = self.addNoteBtn.cj_maxX + gap;
    CGFloat h = 0.0;
    if (self.visualView.superview){
        h = self.visualView.cj_height - menuH;
        self.minusBtn.transform = CGAffineTransformRotate(self.minusBtn.transform,M_PI_4);
    }else{
        h = self.visualView.cj_height;
    }
    self.addFBtn.cj_y = self.addBookBtn.cj_y = self.addNoteBtn.cj_y = h;
    self.weNoteImgView.cj_centerX = _visualView.cj_width / 2;
    self.weNoteImgView.cj_y = _visualView.cj_height * logoHPercent;
}

-(void)viewDidAppear:(BOOL)animated{
    self.selectedIndex = 1;
//    [self changeVisueViewFrame];
//    [self changeChildrenViewControllers];
}

-(void)plusClick{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self.visualView];
    CGFloat menuH = CJScreenHeight*menuHPercent;
    [UIView animateWithDuration:0.3 animations:^{
       self.minusBtn.transform = CGAffineTransformRotate(self.minusBtn.transform,M_PI_4);
    }];
    [UIView animateWithDuration:0.5 delay:0.3 usingSpringWithDamping:0.5 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.addBookBtn.cj_y = self.visualView.cj_height - menuH;
    } completion:nil];

    [UIView animateWithDuration:0.5 delay:0.4 usingSpringWithDamping:0.5 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.addNoteBtn.cj_y = self.visualView.cj_height - menuH;
    } completion:nil];
    [UIView animateWithDuration:0.5 delay:0.5 usingSpringWithDamping:0.5 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.addFBtn.cj_y = self.visualView.cj_height - menuH;
    } completion:nil];
    [UIView animateWithDuration:0.8 animations:^{
        self.weNoteImgView.alpha = logoAlphaMax;
    }];
    
    
}

-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item{
    
    if (!item.title.length) {
        [self plusClick];
        return;
    }
    
    
}
-(BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController{
    if (tabBarController.tabBar.selectedItem.title.length == 0) {
        return NO;
    }
    return YES;
}


@end
