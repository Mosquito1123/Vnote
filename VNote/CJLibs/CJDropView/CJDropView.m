//
//  CJDropView.m
//  dd
//
//  Created by ccj on 2016/12/27.
//  Copyright © 2016年 ccj. All rights reserved.
//

#import "CJDropView.h"
#import <objc/runtime.h>



@interface CJTrangleView : UIView

@property(nonatomic, strong)UIColor *cjTrangleBgColor;

@end

@implementation CJTrangleView

-(void)setCjTrangleBgColor:(UIColor *)cjTrangleBgColor
{
    _cjTrangleBgColor=cjTrangleBgColor;
    self.backgroundColor=[UIColor clearColor];
    [self setNeedsDisplay];
}

//画三角形
-(void)drawRect:(CGRect)rect
{
    
    [self.cjTrangleBgColor set];
    UIBezierPath *path=[UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0, rect.size.height)];
    
    [path addLineToPoint:CGPointMake(rect.size.width/2, 0)];
    
    [path addLineToPoint:CGPointMake(rect.size.width, rect.size.height)];
    [path fill];
}

@end


@interface CJDropView ()<UITableViewDelegate,UITableViewDataSource>
{
    //容器视图,将来对该进行
    UIView *_containerView;
    
    //三角图形
    CJTrangleView *_trangleView;
    
    UITableView *_tableView;
    
}

@end

@implementation CJDropView

-(instancetype)initWithFrame:(CGRect)frame
{
    if(self=[super initWithFrame:frame])
    {
        //设置初始的值
        self.cjTrangleMargin=20.0f;
        self.cjTrangleSize=CGSizeMake(18, 10);
        self.cjDropViewMargin=10;
        self.cjDropViewWidth=160;
        self.cjDropViewCellHeight=40;
        self.cjTrangleY=64;
        self.cjDropViewBgColor=[UIColor whiteColor];
        self.cjAnimationType=CJDropViewAnimationTypeFlexible;
        self.cjTranglePosition=CJTranglePositionRight;
        
        
        //设置当前的DropView视图是蒙版
        self.frame=[UIScreen mainScreen].bounds;
        self.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
        
        
        //将三角形视图添加到DropView当中
        _trangleView=[[CJTrangleView alloc]init];
        _trangleView.cjTrangleBgColor=self.cjDropViewBgColor;
        [self addSubview:_trangleView];
        
        //添加容器视图
        _containerView=[[UIView alloc]init];
        _containerView.backgroundColor=[UIColor clearColor];
        _containerView.layer.masksToBounds=YES;
        _containerView.layer.cornerRadius=5.0;
        [self addSubview:_containerView];
        
        

        
        //将tableView添加到容器视图中
        _tableView=[[UITableView alloc]init];
        _tableView.delegate=self;
        _tableView.dataSource=self;
        
        _tableView.clipsToBounds=YES;
        _tableView.scrollEnabled=NO;
        _tableView.layer.cornerRadius=5.0;
        _tableView.layer.masksToBounds=YES;
        //将tableView的分割线设置在顶端
        _tableView.separatorInset=UIEdgeInsetsZero;
        [_tableView registerNib:[UINib nibWithNibName:@"CJDropViewCell" bundle:nil] forCellReuseIdentifier:@"cell"];
        [_containerView addSubview:_tableView];
    
        
        [self cjResetDropView];
    }
    return self;
}


-(void)cjResetDropView
{
    //设置颜色
    _trangleView.cjTrangleBgColor=self.cjDropViewBgColor;
//    _containerView.backgroundColor=self.cjDropViewBgColor;
    _tableView.backgroundColor=self.cjDropViewBgColor;
    
    NSUInteger count = self.cjDropViewCellModelArray.count + 1;
    CGRect trangleViewFrame,containerViewFrame;
    switch (self.cjTranglePosition)
    {
        case CJTranglePositionLeft:
            _tableView.layer.anchorPoint=CGPointMake(0, 0);
            trangleViewFrame=CGRectMake(self.cjTrangleMargin, self.cjTrangleY, self.cjTrangleSize.width, self.cjTrangleSize.height);
            containerViewFrame=CGRectMake(self.cjDropViewMargin, CGRectGetMaxY(trangleViewFrame), self.cjDropViewWidth, self.cjDropViewCellHeight*count);
            break;
        case CJTranglePositionRight:
            _tableView.layer.anchorPoint=CGPointMake(1, 0);
            trangleViewFrame=CGRectMake(self.frame.size.width-self.cjTrangleMargin-self.cjTrangleSize.width, self.cjTrangleY, self.cjTrangleSize.width, self.cjTrangleSize.height);
            containerViewFrame=CGRectMake(self.frame.size.width-self.cjDropViewMargin-self.cjDropViewWidth, CGRectGetMaxY(_trangleView.frame), self.cjDropViewWidth, self.cjDropViewCellHeight*count);
            break;
        case CJTranglePositionMiddle:
            _tableView.layer.anchorPoint=CGPointMake(0.5, 0);
            trangleViewFrame=CGRectMake(self.center.x-self.cjTrangleSize.width/2, self.cjTrangleY, self.cjTrangleSize.width, self.cjTrangleSize.height);
            containerViewFrame=CGRectMake(self.center.x-self.cjDropViewWidth/2, CGRectGetMaxY(trangleViewFrame), self.cjDropViewWidth, self.cjDropViewCellHeight*count);
            
            break;

    }
    

    //设置三角形的frame
    _trangleView.frame=trangleViewFrame;
    
    //设置容器视图的frame
    _containerView.frame=containerViewFrame;
    
    //设置tableView的位置
    _tableView.frame=_containerView.bounds;
    
    [_tableView reloadData];
}



-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == self.cjDropViewCellModelArray.count){
        UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell1"];
        cell.textLabel.text = @"添加账号";
        cell.textLabel.textColor = BlueBg;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    static NSString *ID=@"cell";
    CJDropViewCell *cell=[tableView dequeueReusableCellWithIdentifier:ID forIndexPath:indexPath];
    
    cell.backgroundColor=self.cjDropViewBgColor;
    NSDictionary *dict = self.cjDropViewCellModelArray[indexPath.row];
    if ([dict[@"avtar_url"] length]){
        cell.avtar.yy_imageURL = IMG_URL(dict[@"avtar_url"]);
    }else
    {
        cell.avtar.image = [UIImage imageNamed:@"avtar"];
    }
    cell.nicknameL.text = dict[@"nickname"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.cjDropViewCellModelArray.count + 1;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.cjDidselectRowAtIndex(indexPath.row);
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.cjDropViewCellHeight;
}

-(void)cjShowDropView
{
    self.hidden = NO;
    //将当前的DropView添加到主要的window上
    UIWindow *keyWindow=[UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:self];
    
    
    //伸缩
    if(self.cjAnimationType==CJDropViewAnimationTypeFlexible)
    {
        _tableView.backgroundColor=[UIColor clearColor];
        _tableView.alpha=0.0;
        _trangleView.alpha=0.0;
        
        [_tableView.layer setValue:@(0.1) forKeyPath:@"transform.scale"];
        self.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.02];
        [UIView animateWithDuration:0.3 animations:^{
            self.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
            [_tableView.layer setValue:@(1) forKeyPath:@"transform.scale"];
            _tableView.alpha=1.0;
            _trangleView.alpha=1.0;
        }];
    }
    //淡入淡出
    else if(self.cjAnimationType==CJDropViewAnimationTypeFadeInFadeOut)
    {
        self.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.02];
        _tableView.alpha=0.0;
        _trangleView.alpha=0.0;
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            _tableView.alpha=1.0;
            _trangleView.alpha=1.0;
            self.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
        } completion:nil];
    }
    
    
    
}

-(void)cjHideDropView
{
    if(self.cjAnimationType==CJDropViewAnimationTypeFlexible)
    {
        [UIView animateWithDuration:0.2 animations:^{
            self.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.02];
            [_tableView.layer setValue:@(0.1) forKeyPath:@"transform.scale"];
            _tableView.alpha=0.0;
            _trangleView.alpha=0.0;
            
            
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    }
    
    else if(self.cjAnimationType==CJDropViewAnimationTypeFadeInFadeOut)
    {
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            _tableView.alpha=0.0;
            _trangleView.alpha=0.0;
            self.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.02];
        } completion:^(BOOL finished){
            [self removeFromSuperview];
            
        }];
    }
    self.hidden = YES;
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self cjHideDropView];
}

+(instancetype)cjShowDropVieWAnimationWithOption:(CJDropViewAnimationType) cjAnimationType tranglePosition:(CJTranglePositionType) cjTranglePosition cellModelArray:(NSArray *)modelArray detailAttributes:(NSDictionary *__nullable)attributes cjDidSelectRowAtIndex:(void (^ _Nonnull)(NSInteger index))didSelectRowAtIndex
{
    
    CJDropView *dropView=[[CJDropView alloc]init];
    //拿到字典里面已有的属性为成员变量赋值
    //使用runtime拿到一个类当中的属性
    unsigned int count;
    //获取成员属性列表
    Ivar *ivarList=class_copyIvarList(self, &count);
    
    for(int i=0;i<count;i++)
    {
        const char *ivarName=ivar_getName(ivarList[i]);
        NSString *propertyName=[NSString stringWithUTF8String:ivarName];
        NSString *property=[propertyName substringFromIndex:1];
        if(attributes[property]!=nil)
        {
            //为相应的成员赋值
            [dropView setValue:attributes[property] forKey:property];
        }
    }

    dropView.cjAnimationType=cjAnimationType;
    dropView.cjTranglePosition=cjTranglePosition;
    dropView.cjDropViewCellModelArray=modelArray;
    [dropView cjResetDropView];
    __weak typeof(dropView) weakDropView=dropView;
    dropView.cjDidselectRowAtIndex=^(NSInteger index){
        [weakDropView cjHideDropView];
        didSelectRowAtIndex(index);
        
    };
    
    return dropView;
}

@end











