//
//  UIViewController+guideView.m
//  尺寸的掌握
//
//  Created by ccj on 2016/12/21.
//  Copyright © 2016年 ccj. All rights reserved.
//

#import "UIViewController+guideView.h"
#import <objc/runtime.h>
@implementation UIViewController (guideView)


+(void)load
{

    
    //判断当前软件的版本是否是与之前安装的版本不一样
    //拿到Info.plist文件里面的版本信息
    NSString *version=[[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"];
    //到偏好设置文件查找，有没有相应的设置
    NSString *firstLaunchkey=[[NSUserDefaults standardUserDefaults] valueForKey:@"firstLaunchkey"];
    if([firstLaunchkey isEqualToString:version])
    {
        //说明不是第一次启动或者是更新软件之后的再次启动
        return;
    }
    
    //来到下面说明是第一次启动
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method viewDidLoadMethod=class_getInstanceMethod([UIViewController class], @selector(viewDidLoad));
        
        Method guideViewDidLoadMethod=class_getInstanceMethod([UIViewController class], @selector(guideViewDidLoad));
        
        method_exchangeImplementations(viewDidLoadMethod, guideViewDidLoadMethod);
        
    });

}



-(void)guideViewDidLoad
{
    //保证代码只运行一次，不然跳到一个界面就会调用[super viewDidLoad],就会有该界面的产生
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        self.view.backgroundColor=[UIColor whiteColor];
        [self.view addSubview:self.collectView];
        [self.view addSubview:self.pageControl];
        
        
    });
    //执行完之后调用工程里面的viewDidLoad
    [self guideViewDidLoad];//实际上就是调用的[self viewDidLoad]
}

-(NSArray<NSString *>*)imageNameArr
{
    return ImageNameArrM;
}

-(UICollectionView *)collectView
{
    //设置流式布局
    UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc]init];
    //设置元件大小
    layout.itemSize=[UIScreen mainScreen].bounds.size;
    layout.minimumLineSpacing=0;//设置行之间的大小
    layout.minimumInteritemSpacing=0;//设置列之间的大小
    layout.scrollDirection=UICollectionViewScrollDirectionHorizontal;//设置水平滚动
    
    UICollectionView *collectView=[[UICollectionView alloc]initWithFrame:[UIScreen mainScreen].bounds collectionViewLayout:layout];
    collectView.pagingEnabled=YES;//确定分页滑动

    collectView.backgroundColor=[UIColor whiteColor];
    collectView.showsVerticalScrollIndicator=NO;
    collectView.showsHorizontalScrollIndicator=NO;
    collectView.delegate=self;
    collectView.dataSource=self;
    //注册UICollectViewCell
    [collectView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"UICollectionViewCell"];
    

    return collectView;
    

}

-(UIButton *)experenceBtn
{
    UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"立即体验" forState:UIControlStateNormal];
    CGFloat btnW=170;
    CGFloat btnH=46;
    CGFloat btnX=self.view.center.x-btnW/2;
    CGFloat btnY=CGRectGetMaxY(self.view.frame)-140;
    button.frame=CGRectMake(btnX, btnY, btnW, btnH);
    button.layer.cornerRadius=btnH/2;
    button.layer.masksToBounds=YES;
    button.layer.borderColor=[UIColor whiteColor].CGColor;
    button.layer.borderWidth=1.0;
    button.titleLabel.font=[UIFont systemFontOfSize:15.0];
    button.backgroundColor=[UIColor redColor];
    [button addTarget:self action:@selector(experenceBtnClick) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

-(void)experenceBtnClick
{
    
    NSString *version=[[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"];
    
    NSUserDefaults *userDefault=[NSUserDefaults standardUserDefaults];
    [userDefault setValue:version forKey:@"firstLaunchkey"];
    [userDefault synchronize];
    
    //将界面的图片干掉
    for (UIView *view in self.view.subviews)
    {
        [view removeFromSuperview];
    }
    
}


-(UIPageControl *)pageControl
{
    UIPageControl *pageControl=[[UIPageControl alloc]init];
    
    CGFloat pageControlW=170;
    CGFloat pageControlH=20;
    CGFloat pageControlX=self.view.center.x-pageControlW/2;
    CGFloat pageControlY=CGRectGetMaxY(self.view.frame)-80;
    pageControl.frame=CGRectMake(pageControlX, pageControlY, pageControlW, pageControlH);
    pageControl.numberOfPages=self.imageNameArr.count;
    pageControl.currentPageIndicatorTintColor=[UIColor redColor];
    pageControl.pageIndicatorTintColor=[UIColor colorWithRed:0.56 green:0.70 blue:0.95 alpha:1.0];
    pageControl.tag=1;
    return pageControl;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    int currentIndex=scrollView.contentOffset.x/self.view.frame.size.width;
    UIPageControl *pageControl=[self.view viewWithTag:1];
    pageControl.currentPage=currentIndex;
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{

    UICollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"UICollectionViewCell" forIndexPath:indexPath];
    
    UIImageView *imageView=[[UIImageView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    imageView.image=[UIImage imageNamed:self.imageNameArr[indexPath.row]];
    [cell.contentView addSubview:imageView];
    if(indexPath.row==self.imageNameArr.count-1)
    {
        [cell.contentView addSubview:self.experenceBtn];
    }
    return cell;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.imageNameArr.count;
}


@end
