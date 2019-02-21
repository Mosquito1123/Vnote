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

const CGFloat menuHPercent = 0.5;
const CGFloat logoHPercent = 0.2;
const CGFloat logoAlphaMin = 0.01;
const CGFloat logoAlphaMax = 1.0;
@interface CJTabBarVC ()<UIGestureRecognizerDelegate>
@property(nonatomic,strong) UIVisualEffectView *visualView;
@property(nonatomic,strong) UIButton *minusBtn;
@property(nonatomic,strong) CJCustomBtn *addBookBtn;
@property(nonatomic,strong) CJCustomBtn *addNoteBtn;
@property (nonatomic,strong) UIButton *plusBtn;
@property(nonatomic,strong) CJCustomBtn *addFBtn;
@property(nonatomic,assign) CGFloat tabH;
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

-(UIButton *)plusBtn{
    if(!_plusBtn){
        _plusBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_plusBtn addTarget:self action:@selector(plusClick) forControlEvents:UIControlEventTouchUpInside];
        [self setPlusBtnFrame];
        [_plusBtn setImage:[UIImage imageNamed:@"加蓝"] forState:UIControlStateNormal];
    }
    return _plusBtn;
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
            vc.modalPresentationStyle = UIModalPresentationOverFullScreen;
            [weakself presentViewController:vc animated:YES completion:nil];
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
            CJUser *user = [CJUser sharedUser];
            RLMRealm *rlm = [CJRlm cjRlmWithName:user.email];
            RLMResults *res = [CJBook allObjectsInRealm:rlm];
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

    UITabBarItem *item = [UITabBarItem appearance];
    NSMutableDictionary *normalAttrs = [NSMutableDictionary dictionary];
    normalAttrs[NSFontAttributeName] = [UIFont systemFontOfSize:11];
    normalAttrs[NSForegroundColorAttributeName] = HeadFontColor;
    [item setTitleTextAttributes:normalAttrs forState:UIControlStateNormal];
    
    NSMutableDictionary *selectedAttrs = [NSMutableDictionary dictionary];
    selectedAttrs[NSForegroundColorAttributeName] = BlueBg;
    [item setTitleTextAttributes:selectedAttrs forState:UIControlStateSelected];

    [self.tabBar addSubview:self.plusBtn];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(rotateChange) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(rotateChange) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    // 接入热点
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(statusChange) name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
    self.selectedIndex = 1;
}

-(void)statusChange{
    NSLog(@"-----");
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
-(void)rotateChange{
    [self changeVisueViewFrame];
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
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    self.visualView.frame = window.bounds;
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
    [self setPlusBtnFrame];
    
}

-(void)setPlusBtnFrame{
    _plusBtn.cj_width = _plusBtn.cj_height = self.tabH - 1;
    _plusBtn.cj_centerX = CJScreenWidth / 2;
    _plusBtn.cj_y = 1;
}

-(CGFloat)tabH{
    for (UIView *v in self.tabBar.subviews) {
        if([v isKindOfClass:NSClassFromString(@"UITabBarButton")]){
            _tabH = v.cj_height;
            break;
        }
    }
    return _tabH;
}
-(void)viewDidAppear:(BOOL)animated{
    [self changeVisueViewFrame];
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




@end
