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
@interface CJTabBarVC ()<UIGestureRecognizerDelegate>
@property(nonatomic,strong) UIVisualEffectView *visualView;
@property(nonatomic,strong) UIButton *minusBtn;
@property(nonatomic,strong) CJCustomBtn *addBookBtn;
@property(nonatomic,strong) CJCustomBtn *addNoteBtn;
@property (nonatomic,strong) UIButton *plusBtn;

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
        self.minusBtn.cj_y = _visualView.cj_height - self.minusBtn.cj_height - 10;
        [_visualView.contentView addSubview:self.addBookBtn];
        [_visualView.contentView addSubview:self.addNoteBtn];
        CGFloat width = self.addBookBtn.cj_width;
        CGFloat gap = (_visualView.cj_width - 4 * width) / 5;
        self.addBookBtn.cj_x = gap;
        self.addBookBtn.cj_y = _visualView.cj_height;
        self.addNoteBtn.cj_x = gap *2 + width;
        self.addNoteBtn.cj_y = _visualView.cj_height;
        
    }
    return _visualView;
}
-(UIButton *)plusBtn{
    if(!_plusBtn){
        _plusBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_plusBtn addTarget:self action:@selector(plusClick) forControlEvents:UIControlEventTouchUpInside];
        CGFloat plusBtnW = self.tabBar.cj_width / 5;
        CGFloat plusBtnH = self.tabBar.cj_height;
        _plusBtn.frame = CGRectMake(plusBtnW * 2, 0, plusBtnW, plusBtnH);
        [_plusBtn setImage:[UIImage imageNamed:@"加蓝"] forState:UIControlStateNormal];
    }
    return _plusBtn;
}


-(CJCustomBtn *)addBookBtn{
    if (!_addBookBtn){
        CJWeak(self)
        _addBookBtn = [CJCustomBtn xibCustomBtnWithTapClick:^{
            [weakself.visualView removeFromSuperview];
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
        _addNoteBtn = [CJCustomBtn xibCustomBtnWithTapClick:^{
            [self.visualView removeFromSuperview];
            UINavigationController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"addNoteNav"];
            vc.modalPresentationStyle = UIModalPresentationOverFullScreen;
            [self presentViewController:vc animated:YES completion:nil];
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
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(rotateChange) name:UIDeviceOrientationDidChangeNotification object:nil];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
-(void)rotateChange{
    CGFloat plusBtnW = self.tabBar.cj_width / 5;
    CGFloat plusBtnH = self.tabBar.cj_height;
    self.plusBtn.frame = CGRectMake(plusBtnW * 2, 0, plusBtnW, plusBtnH);
    [self changeVisueViewFrame];
}


-(void)minusClick{
    [UIView animateWithDuration:0.3 animations:^{
        self.minusBtn.transform = CGAffineTransformRotate(self.minusBtn.transform,-M_PI_4);
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

-(void)changeVisueViewFrame{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    self.visualView.frame = window.bounds;
    
    self.minusBtn.cj_size = CGSizeMake(49, 49);
    self.minusBtn.cj_centerX = self.visualView.cj_centerX;
    self.minusBtn.cj_y = self.visualView.cj_height - self.minusBtn.cj_height - 10;
    
    self.addBookBtn.cj_size = self.addNoteBtn.cj_size = CGSizeMake(80, 50);
    CGFloat width = self.addBookBtn.cj_width;
    CGFloat gap = (self.visualView.cj_width - 4 * width) / 5;
    
    self.addBookBtn.cj_x = gap;
    self.addNoteBtn.cj_x = gap *2 + width;
    if (self.visualView.superview){
        self.addBookBtn.cj_y = self.visualView.cj_height - 250;
        self.addNoteBtn.cj_y = self.visualView.cj_height - 250;
        
        self.minusBtn.transform = CGAffineTransformRotate(self.minusBtn.transform,M_PI_4);
    }else{
        self.addBookBtn.cj_y = self.visualView.cj_height;
        self.addNoteBtn.cj_y = self.visualView.cj_height;
    }
    
}

-(void)plusClick{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self.visualView];
    
    [UIView animateWithDuration:0.3 animations:^{
       self.minusBtn.transform = CGAffineTransformRotate(self.minusBtn.transform,M_PI_4);;
    }];
    [UIView animateWithDuration:0.5 delay:0.3 usingSpringWithDamping:0.5 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.addBookBtn.cj_y = self.visualView.cj_height - 250;
    } completion:nil];
    CJUser *user = [CJUser sharedUser];
    RLMRealm *rlm = [CJRlm cjRlmWithName:user.email];
    RLMResults *res = [CJBook allObjectsInRealm:rlm];
    if (!res.count){
        return;
    }
    [UIView animateWithDuration:0.5 delay:0.4 usingSpringWithDamping:0.5 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.addNoteBtn.cj_y = self.visualView.cj_height - 250;
    } completion:nil];
    
    
}




@end
