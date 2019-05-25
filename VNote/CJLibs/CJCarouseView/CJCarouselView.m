//
//  CJCarouselView.m
//  sliderViewcontroller
//
//  Created by ccj on 2017/1/20.
//  Copyright © 2017年 ccj. All rights reserved.
//



#import "CJCarouselView.h"
#import "UIView+CJViewExtension.h"
@interface CJCarouselView ()<UIScrollViewDelegate>
@property(nonatomic)UIScrollView *scrollView;
@property(nonatomic)UIImageView *currentImageView;
@property(nonatomic)UIImageView *anotherImageView;
@property(nonatomic,assign)CJCarouselViewMoveDirection direction;
@property(nonatomic,assign)NSInteger currentIndex;
@property(nonatomic,assign)NSInteger nextIndex;
@property(nonatomic,strong)NSTimer *timer;

@property(nonatomic,strong)UIPageControl *pageControl;
@property(nonatomic,copy)void (^didClickBlock)(NSInteger index);

@end

@implementation CJCarouselView
static CGFloat padding = 10.f;
-(instancetype)initWithFrame:(CGRect)frame
{
    if(self=[super initWithFrame:frame])
    {
        //添加视图
        [self addSubview:self.scrollView];
        [self.scrollView addSubview:self.currentImageView];
        [self.scrollView addSubview:self.anotherImageView];
        [self addSubview:self.pageControl];
        //KVO监听direction值的改变
        [self addObserver:self forKeyPath:@"direction" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
        
        //添加时间监听器
        __weak typeof(self) weakSelf=self;
        self.timer=[NSTimer scheduledTimerWithTimeInterval:5 repeats:YES block:^(NSTimer * _Nonnull timer) {
            //scrollView向左滑
            [weakSelf.scrollView setContentOffset:CGPointMake(weakSelf.cj_width*2, 0) animated:YES];
            
        }];
    }
    return self;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{

    //拿到监听的值
    CJCarouselViewMoveDirection newDirection=(CJCarouselViewMoveDirection)[change[NSKeyValueChangeNewKey] intValue];
    
    CJCarouselViewMoveDirection oldDirection=(CJCarouselViewMoveDirection)[change[NSKeyValueChangeOldKey] intValue];
    
    
    if(newDirection==oldDirection||newDirection==CJCarouselViewMoveDirectionNone) return;
    
    //scrollView左滑，图片的位置放在右边
    if(newDirection==CJCarouselViewMoveDirectionLeft)
    {
        self.nextIndex=self.currentIndex+1;
        if(self.nextIndex>=self.cjImages.count)
        {
            //来到这说明currentIndex已经是最后一张图片
            self.nextIndex=0;
        }
        self.anotherImageView.frame=CGRectMake(self.cj_width*2 + padding, 0, self.cj_width - 2 * padding, self.cj_height);
        
    }
    //scrollView右滑，图片的位置放在右边
    else if (newDirection==CJCarouselViewMoveDirectionRight)
    {
        self.nextIndex=self.currentIndex-1;
        if(self.nextIndex<0)
        {
            self.nextIndex=self.cjImages.count-1;
        }
        self.anotherImageView.frame=CGRectMake(padding, 0, self.cj_width - 2 * padding, self.cj_height);
        
    }
    self.anotherImageView.image=self.cjImages[self.nextIndex];
}


-(UIScrollView *)scrollView
{
    if(_scrollView==nil)
    {
        
        _scrollView=[[UIScrollView alloc]initWithFrame:self.bounds];
        _scrollView.showsVerticalScrollIndicator=NO;
        _scrollView.showsHorizontalScrollIndicator=NO;
        _scrollView.bounces=NO;
        _scrollView.pagingEnabled=YES;//分页
        _scrollView.contentSize=CGSizeMake(self.cj_width*3, self.cj_height);
        _scrollView.delegate=self;
    }
    return _scrollView;
}
-(UIImageView *)currentImageView
{
    if(_currentImageView==nil)
    {
        _currentImageView=[[UIImageView alloc]init];
        UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(currentImageViewDidTap:)];
        _currentImageView.userInteractionEnabled=YES;
        [_currentImageView addGestureRecognizer:tapGesture];
        CJCornerRadius(_currentImageView) = 5.f;
    }
    return _currentImageView;
}

-(void)currentImageViewDidTap:(UIGestureRecognizer *)ges
{
    self.didClickBlock(self.currentIndex);

}

-(UIImageView *)anotherImageView
{
    if(_anotherImageView==nil)
    {
        _anotherImageView=[[UIImageView alloc]init];
        CJCornerRadius(_anotherImageView) = 5.f;
    }
    return _anotherImageView;
}


-(UIPageControl *)pageControl
{
    if(_pageControl==nil)
    {
        _pageControl=[[UIPageControl alloc]init];
        _pageControl.currentPageIndicatorTintColor=BlueBg;
        _pageControl.pageIndicatorTintColor=[UIColor lightGrayColor];
        _pageControl.currentPage=0;
        
    }
    return  _pageControl;
}



-(void)layoutSubviews
{
    self.scrollView.contentInset=UIEdgeInsetsZero;

    
}


-(void)setCjPageControlPosition:(CJPageControlPosition)cjPageControlPosition
{
    
    CGFloat left=self.scrollView.cj_width/8;
    CGFloat right=left;
    CGFloat bottom=0;
    
    CGSize size=[self.pageControl sizeForNumberOfPages:self.cjImages.count];
    switch (cjPageControlPosition)
    {
        case CJPageControlPositionLeft:
            self.pageControl.frame=CGRectMake(left, self.scrollView.cj_height-size.height/2-bottom, size.width/2, size.height/2);
            break;
        case CJPageControlPositionRight:
            self.pageControl.frame=CGRectMake(self.scrollView.cj_width-right-size.width/2, self.scrollView.cj_height-size.height/2-bottom, size.width/2, size.height/2);
            break;
        case CJPageControlPositionCenter:
            self.pageControl.frame=CGRectMake(self.scrollView.cj_width/2-size.width/4, self.scrollView.cj_height-size.height/2-bottom, size.width/2, size.height/2);
            break;
        
    }
}

-(void)setCjImages:(NSMutableArray *)cjImages
{
    
    _cjImages=[NSMutableArray array];
    for (int i=0; i<cjImages.count; i++){
        if([cjImages[i] isKindOfClass:[UIImage class]])
        {
            //说明是本地图片
            [_cjImages addObject:cjImages[i]];
        }
        else if([cjImages[i] isKindOfClass:[NSString class]])
        {
            //说明是网络图片
            //1.使用占位图片
            [_cjImages addObject:[UIImage imageNamed:@"XRPlaceholder"]];
            
            //2.再对该url进行下载
            [self downloadImageWithURLString:cjImages[i] index:i];
        }
        
    }

    //设置初始时的图片
    self.currentImageView.image=_cjImages[0];
    //设置初始的位置
    self.currentImageView.frame=CGRectMake(self.cj_width + padding, 0,self.cj_width - 2 * padding, self.cj_height);
    self.scrollView.contentOffset=CGPointMake(self.cj_width, 0);
    self.currentIndex=0;
    self.pageControl.numberOfPages=cjImages.count;

    
    [self layoutSubviews];
    
}



-(void)downloadImageWithURLString:(NSString *)urlStr index:(NSInteger)index
{

    NSURL *url=[NSURL URLWithString:urlStr];
    NSURLCache *cache=[NSURLCache sharedURLCache];
    NSURLRequest *request=[NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:15];
    
    //先到缓存中取
    NSCachedURLResponse *response=[cache cachedResponseForRequest:request];
    if(response)
    {
        UIImage *image=[UIImage imageWithData:response.data];
        self.cjImages[index]=image;
    }
    else
    {
    
        NSURLSession *urlSession=[NSURLSession sharedSession];
        
        NSURLSessionTask *task=[urlSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            
            UIImage *image=[UIImage imageWithData:data];
            self.cjImages[index]=image;
            //判断当前的scrollView的位置是否是正在下载的网络图片
            
            if(self.currentIndex==index)
            {
                //回到主线程更新UI
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    
                    self.currentImageView.image=image;
                });
                
            }
        }];
        [task resume];
    }
    
}


#pragma mark -UIScrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //拿到当前scrollView的偏移位置和current偏移位置进行比较
    self.direction=scrollView.contentOffset.x>self.cj_width?CJCarouselViewMoveDirectionLeft:CJCarouselViewMoveDirectionRight;
    
}


//该方法会在setContentOffset调用之后调用,[scrollView setContentOffset:animated:NO],不会调用，只会对动画结束才会调用
-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    self.currentImageView.image=self.anotherImageView.image;
    self.currentIndex=self.nextIndex;
    self.pageControl.currentPage=self.currentIndex;
    [scrollView setContentOffset:CGPointMake(self.cj_width, 0) animated:NO];
}

//手势滑动才会来到这
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    self.direction=CJCarouselViewMoveDirectionNone;//清空方向移动
    //滚动完成，显示一个完整的图片
    
    //拿到当前scrollView偏移量，得到当前的是在 左边，中间， 右边
    NSInteger index=scrollView.contentOffset.x/self.cj_width;
    if(index==1)
    {
        //表示停在中间，没有动
        return;
    }
    else if(index==0||index==2)//表示在左边
    {
        self.currentIndex=self.nextIndex;
        self.pageControl.currentPage=self.currentIndex;
        self.currentImageView.image=self.anotherImageView.image;
        
        [scrollView setContentOffset:CGPointMake(self.cj_width, 0) animated:NO];
    }
}

//手势滑动开始时
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.timer invalidate];//使定时器无效
}

//手势滑动结束时
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    //重新开启定时器
    __weak typeof(self) weakSelf=self;
    self.timer=[NSTimer scheduledTimerWithTimeInterval:5 repeats:YES block:^(NSTimer * _Nonnull timer) {
        //scrollView向左滑
        [weakSelf.scrollView setContentOffset:CGPointMake(weakSelf.cj_width*2, 0) animated:YES];
        
    }];
}

-(void)dealloc
{
    [self.timer invalidate];
    [self removeObserver:self forKeyPath:@"direction"];
    
}

+(instancetype)cjCarouseViewAddToView:(UIView *)superView withFrame:(CGRect)frame withImagess:(NSMutableArray *)images pageControlPosition:(CJPageControlPosition)pageControlPosition didClickBlock:(void (^)(NSInteger))block
{
    CJCarouselView *carouseView=[[CJCarouselView alloc]initWithFrame:frame];
    carouseView.cjImages=images;
    carouseView.cjPageControlPosition=pageControlPosition;
    carouseView.didClickBlock=^(NSInteger index){
        block(index);
    };
    [superView addSubview:carouseView];
    return carouseView;
}

+(instancetype)cjCarouseViewWithFrame:(CGRect)frame withImagess:(NSMutableArray *)images pageControlPosition:(CJPageControlPosition)pageControlPosition didClickBlock:(void (^)(NSInteger))block
{
    CJCarouselView *carouseView=[[CJCarouselView alloc]initWithFrame:frame];
    carouseView.cjImages=images;
    carouseView.cjPageControlPosition=pageControlPosition;
    carouseView.didClickBlock=^(NSInteger index){
        block(index);
    };
    return carouseView;
}




@end
