//
//  ViewController.m
//  sliderViewcontroller
//
//  Created by ccj on 2017/1/7.
//  Copyright © 2017年 ccj. All rights reserved.
//

#import "CJSlideViewController.h"
#import "UIView+CJViewExtension.h"


#define CJScreenW [UIScreen mainScreen].bounds.size.width
#define CJScreenH [UIScreen mainScreen].bounds.size.height

static const CGFloat titleScrollViewH=44;
@interface CJSlideViewController ()<UIScrollViewDelegate>

@property(nonatomic,strong) NSMutableArray *titles;

@property(nonatomic,strong) UIView *containerView;

@property(nonatomic,strong) UIScrollView *titleScrollView;


@property(nonatomic,strong) UIScrollView *contentScrollView;


@property(nonatomic,strong) UIButton *selectButton;

@property(nonatomic,strong) NSMutableArray *btnArray;

@property(nonatomic,strong) UIView *lineView;


@property(nonatomic,copy) void (^didSelectBlock)(NSUInteger selectIndex,UIViewController *selectVC);

@property(nonatomic,assign)NSUInteger lastIndex;


/**需要添加的viewcontroller*/
@property(nonatomic,strong) NSArray *cjSlideViewControllers;


@end

@implementation CJSlideViewController

-(NSMutableArray *)btnArray
{
    if(_btnArray==nil)
    {
        _btnArray=[NSMutableArray array];
    }
    return _btnArray;
}

-(NSMutableArray *)titles
{
    if(_titles==nil)
    {
        _titles=[NSMutableArray array];
        
    }
    return _titles;
}




- (void)viewDidLoad {
    [super viewDidLoad];
    //去除系统自带的约束
    self.automaticallyAdjustsScrollViewInsets=NO;
    
    //添加容器视图，方便以后管理标题滑动条和内容滑动视图容器的frame
    _containerView=[[UIView alloc]initWithFrame:CGRectMake(0, 0,self.view.cj_width,self.view.cj_height)];
    [self.view  addSubview:_containerView];
    
    
    //添加标题滑动条
    _titleScrollView=[[UIScrollView alloc]initWithFrame:CGRectMake(_containerView.cj_x, 0, _containerView.cj_width, titleScrollViewH)];
    _titleScrollView.showsHorizontalScrollIndicator=NO;
    [_containerView addSubview:_titleScrollView];

    
    //添加内容滑动视图容器
    _contentScrollView=[[UIScrollView alloc]initWithFrame:CGRectMake(_containerView.cj_x, titleScrollViewH,_containerView.cj_width, _containerView.cj_height-titleScrollViewH)];
    _contentScrollView.showsHorizontalScrollIndicator=YES;
    _contentScrollView.pagingEnabled=YES;
    _contentScrollView.delegate=self;
    [_containerView addSubview:_contentScrollView];
    
    
    
    
}


-(void)setCjSlideViewControllers:(NSArray *)cjSlideViewControllers
{
    if(_cjSlideViewControllers==cjSlideViewControllers)
    {
        return;
    }
    
    _cjSlideViewControllers=cjSlideViewControllers;
    for (UIViewController *vc in cjSlideViewControllers)
    {
        [self.titles addObject:vc.title];
        [self addChildViewController:vc];
    }

    //设置标题滑动条里面的标题
    [self setUpTitlesForTitleScrollView];
    
    NSUInteger count=self.titles.count;
    CGFloat itemW=count>=5?CJScreenW/5:CJScreenW/count;
    //添加滑动条
    _lineView=[[UIView alloc]initWithFrame:CGRectMake(0, titleScrollViewH-2, itemW, 2)];
    _lineView.layer.cornerRadius=1.0;
    _lineView.layer.masksToBounds=YES;
    _lineView.backgroundColor=[UIColor redColor];
    [_titleScrollView addSubview:_lineView];
    
    

}



-(void)setCjLineViewColor:(UIColor *)cjLineViewColor
{
    _lineView.backgroundColor=cjLineViewColor;
    for (UIButton *button in self.btnArray)
    {
        [button setTitleColor:cjLineViewColor forState:UIControlStateSelected];
    }

}

-(void)setUpTitlesForTitleScrollView
{
    NSUInteger count=self.titles.count;
    
    //确定滑动条上面每个Item对象的宽度
    CGFloat itemW;
    if(count>=5)
    {
        itemW=_containerView.cj_width/5;
    }
    else
    {
        itemW=_containerView.cj_width/count;
    }
    
    //设置标题滑动条滚动的范围
    _titleScrollView.contentSize=CGSizeMake(itemW*count, titleScrollViewH);
    
    //设置内容视图的滚动位置
    _contentScrollView.contentSize=CGSizeMake(_containerView.cj_width*count, _containerView.cj_height-titleScrollViewH);
    
    
    //设置标题
    int i;
    for (i=0; i<count; i++)
    {
        
        NSString *title=self.titles[i];
        UIButton *button=[[UIButton alloc]initWithFrame:CGRectMake(itemW*i, 0, itemW, titleScrollViewH)];
        button.backgroundColor=[UIColor whiteColor];
        [button setTitle:title forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
        
        button.tag=i;
        [button addTarget:self action:@selector(titleBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_titleScrollView addSubview:button];
        
        [self.btnArray addObject:button];
        //默认第一个view先要加载进来
        if(i==0)
        {
            [self setUpContentSubviews:0];
            button.selected=YES;
            _selectButton=button;
            self.lastIndex=0;
        }
    }
    
    
}



-(void)titleBtnClick:(UIButton *)button
{
    
    _selectButton.selected=NO;
    _selectButton=button;
    button.selected=YES;
    
    NSUInteger index=button.tag;
    if(index!=self.lastIndex)
    {
        self.didSelectBlock(index,self.childViewControllers[index]);
        self.lastIndex=index;
    }
    [self keepTitleItemOnCenterPosition:index];
    //设置内容控制器的视图
    [self setUpContentSubviews:index];
    
    //滑动视图
    [_contentScrollView setContentOffset:CGPointMake(_containerView.cj_width*index, 0) animated:NO];
}

-(void)setUpContentSubviews:(NSUInteger)index
{

    //取出对应控制器的view,将其添加到内容视图上
    UIViewController *vc=self.childViewControllers[index];
    if(vc.isViewLoaded)
    {
        return;
    }
    vc.view.frame=CGRectMake(index*_containerView.cj_width, 0, _containerView.cj_width, _containerView.cj_height-titleScrollViewH);
    
    [_contentScrollView addSubview:vc.view];
    

}

-(void)keepTitleItemOnCenterPosition:(NSUInteger)index
{
    
    NSUInteger count=self.titles.count;
    
    CGFloat itemW=count>=5?CJScreenW/5:CJScreenW/count;
    if(count<=5)
    {
        
    }
    //将标题始终保持在最中间
    else if(index<=2)
    {
        [_titleScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
        
    }
    else if (index>=count-3)
    {
        [_titleScrollView setContentOffset:CGPointMake((count-5)*itemW, 0) animated:YES];
    }
    else
    {
        [_titleScrollView setContentOffset:CGPointMake((index-2)*itemW, 0) animated:YES];
    }
    __weak typeof(_lineView) weakLineView=_lineView;
    [UIView animateWithDuration:0.1 animations:^{
        weakLineView.frame=CGRectMake(index*itemW, weakLineView.frame.origin.y, itemW, 3);
    }];
    
}


#pragma mark -UIScrollViewDelegate
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSUInteger index=scrollView.contentOffset.x/_containerView.cj_width;
    
    if(index!=self.lastIndex)
    {
        self.didSelectBlock(index,self.childViewControllers[index]);
        self.lastIndex=index;
    }
    [self setUpContentSubviews:index];
    
    _selectButton.selected=NO;
    _selectButton=self.btnArray[index];
    _selectButton.selected=YES;
    
    //将标题始终保持在最中间
    [self keepTitleItemOnCenterPosition:index];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    _lineView.frame=CGRectMake(_lineView.cj_width*(scrollView.contentOffset.x/_containerView.cj_width), _lineView.frame.origin.y, _lineView.frame.size.width, _lineView.frame.size.height);
    
}



+(instancetype)cjAddToViewControll:(UIViewController *)superVC withViewAddTo:(UIView *)superView withViewFrame:(CGRect)frame withSubviewControllers:(NSArray *)subviewControllers withSelectBlock:(void (^)(NSUInteger selectIndex, UIViewController *selectVC))didSelectBlock
{
    superVC.automaticallyAdjustsScrollViewInsets=NO;
    CJSlideViewController *slideVC=[[CJSlideViewController alloc]init];
    [superVC addChildViewController:slideVC];
    slideVC.view.frame=frame;
    [superView addSubview:slideVC.view];
    slideVC.cjSlideViewControllers=subviewControllers;
    slideVC.didSelectBlock=^(NSUInteger selectIndex,UIViewController *selectVC){
        didSelectBlock(selectIndex,selectVC);
    };
    return slideVC;
    
}



@end








