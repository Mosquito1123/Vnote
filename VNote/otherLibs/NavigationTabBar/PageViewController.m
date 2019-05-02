//
//  PageViewController.m
//  DLNavigationTabBar
//
//  Created by FT_David on 2016/12/4.
//  Copyright © 2016年 FT_David. All rights reserved.
//

#import "PageViewController.h"
#import "DLNavigationTabBar.h"
@interface PageViewController ()<UIPageViewControllerDelegate,UIPageViewControllerDataSource,UIGestureRecognizerDelegate,UIScrollViewDelegate>
{
    NSUInteger _currentIndex; //当前显示的索引
    BOOL _isFist;
    
    BOOL transitionFinish; //页面过度是否结束
}
@property (nonatomic,strong)UIPanGestureRecognizer *fakePan;
@property(nonatomic,strong)DLNavigationTabBar *navigationTabBar;
@property(nonatomic,strong)NSArray<UIViewController *> *subViewControllers;
@property(nonatomic,strong)UIScrollView *scrollView;
@end

@implementation PageViewController

-(void)cjNavigationSliderControllerWithTitles:(NSArray *)titles titleSelectColor:(UIColor *)selectColor normalColor:(UIColor *)normalColor subviewControllers:(NSArray<UIViewController *> *)vcs didClickItem:(TabBarDidClickAtIndex)click{
    self.navigationTabBar = [[DLNavigationTabBar alloc] initWithTitles:titles normalTitleColor:normalColor selectedTileColor:selectColor];
    __weak typeof(self) weakSelf = self;
    [self.navigationTabBar setDidClickAtIndex:^(NSInteger index){
        [weakSelf navigationDidSelectedControllerIndex:index animate:NO];
        if (click){
            click(index);
        }
    }];
    self.navigationItem.titleView = self.navigationTabBar;
    self.delegate = self;
    self.dataSource = self;
    [self setViewControllers:@[vcs.firstObject]
                   direction:UIPageViewControllerNavigationDirectionForward
                    animated:YES
                  completion:nil];
    self.subViewControllers = vcs;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    __block UIScrollView *scrollView = nil;
    [self.view.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[UIScrollView class]]) scrollView = (UIScrollView *)obj;
        
    }];
    self.scrollView = scrollView;
    scrollView.delegate = self;
    scrollView.bounces = NO;
//    if(scrollView)
//    {
//        //新添加的手势，起手势锁的作用
//        _fakePan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panGes:)];
//        _fakePan.delegate = self;
//        [scrollView addGestureRecognizer:_fakePan];
//        
//    }

}
//-(void)panGes:(UIPanGestureRecognizer *)ges{
//    
//    CGPoint translation = [ges translationInView:ges.view];
//    NSLog(@"%f",translation.x);
//    UIScrollView *scrollView = (UIScrollView *)ges.view;
////    CGFloat x = scrollView.contentOffset.x;
////    NSLog(@"x=%f",x);
//    if (translation.x < 0)
//    {
//        [scrollView setContentOffset:CGPointMake(CJScreenWidth-translation.x, 0)];
//    }
//    else
//    {
//        // 向右滑
//        [scrollView setContentOffset:CGPointMake(CJScreenWidth-translation.x, 0)];
//    }
//}


//- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer
//{
//
//    CGPoint translation = [gestureRecognizer translationInView:gestureRecognizer.view];
//    if (_currentIndex == 0 && translation.x >0){
//        return NO;
//    }else if (_currentIndex == self.subViewControllers.count - 1 && translation.x < 0){
//        return NO;
//    }else if(translation.x > 0){
//
////        [self navigationDidSelectedControllerIndex:_currentIndex-1 animate:YES];
//    }else if(translation.x < 0){
////        [self navigationDidSelectedControllerIndex:_currentIndex+1 animate:YES];
//    }
//    return YES;
//}




#pragma mark - UIPageViewControllerDelegate
- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSInteger index = [self.subViewControllers indexOfObject:viewController];
    if(index == 0 || index == NSNotFound) {
        return nil;
    }
    return [self.subViewControllers objectAtIndex:index - 1];
}

- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSInteger index = [self.subViewControllers indexOfObject:viewController];
    if(index == NSNotFound || index == self.subViewControllers.count - 1) {
        return nil;
    }
    return [self.subViewControllers objectAtIndex:index + 1];
}

- (void)pageViewController:(UIPageViewController *)pageViewController
        didFinishAnimating:(BOOL)finished
   previousViewControllers:(NSArray *)previousViewControllers
       transitionCompleted:(BOOL)completed {
    UIViewController *viewController = self.viewControllers[0];
    NSUInteger index = [self.subViewControllers indexOfObject:viewController];
    _currentIndex = index;
    [self.navigationTabBar scrollToIndex:index];
    transitionFinish = YES;
    
    
}


#pragma mark - PrivateMethod
- (void)navigationDidSelectedControllerIndex:(NSInteger)index animate:(BOOL)ani{
    transitionFinish = NO;
    [self setViewControllers:@[[self.subViewControllers objectAtIndex:index]] direction:UIPageViewControllerNavigationDirectionForward animated:ani completion:^(BOOL finished){
        if (finished)
        {
            
            self->transitionFinish = YES;
            self->_currentIndex = index;
            
        }
    }];
}



@end
