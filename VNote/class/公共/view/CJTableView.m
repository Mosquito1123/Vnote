//
//  CJTableView.m
//  VNote
//
//  Created by ccj on 2018/7/13.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import "CJTableView.h"
@interface CJTableView()<DZNEmptyDataSetSource,DZNEmptyDataSetDelegate>
@property(nonatomic,assign,getter=isLoading)BOOL loading;
@property(nonatomic,strong)UIActivityIndicatorView *activityView;
@property(nonatomic,copy)NSString *title;
@property(nonatomic,copy)NSString *descriptionText;
@property(nonatomic,copy)void (^block)(void);

@end

@implementation CJTableView
-(void)setEmtyHide:(BOOL)emtyHide{
    _emtyHide = emtyHide;
    if (!emtyHide){
        [self reloadEmptyDataSet];
    }
    
}



-(UIActivityIndicatorView *)activityView{
    if (_activityView == nil){
        _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _activityView.color = BlueBg;
    }
    return _activityView;
}
- (void)setLoading:(BOOL)loading
{
    if (self.isLoading == loading) {
        return;
    }
    
    _loading = loading;
    // 每次 loading 状态被修改，就刷新空白页面。
    [self reloadEmptyDataSet];
}
-(void)initDataWithTitle:(NSString *)title descriptionText:(NSString *)descriptionText didTapButton:(void (^)(void))block{
    
    self.emptyDataSetDelegate = self;
    self.emptyDataSetSource = self;
    self.title = title;
    self.descriptionText = descriptionText;
    self.block = block;
    self.emtyHide = YES; // 刚开始是隐藏的
    self.tableFooterView = [[UIView alloc]init];
}

-(void)beginLoadingData{
    [self.activityView startAnimating];
    self.loading = YES;
}

-(void)endLoadingData{
    self.emtyHide = NO;
    [self.activityView stopAnimating];
    self.loading = NO;
    
}


- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    if (self.isEmptyHidden) return nil;
    NSString *title = self.title;
    NSDictionary *attributes = @{
                                 NSFontAttributeName:[UIFont boldSystemFontOfSize:25.0f],
                                 NSForegroundColorAttributeName:[UIColor darkGrayColor]
                                 };
    return [[NSAttributedString alloc] initWithString:title attributes:attributes];
}

- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView {
    if (self.isEmptyHidden) return nil;
    NSString *text = self.descriptionText;
    
    NSMutableParagraphStyle *paragraph = [NSMutableParagraphStyle new];
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    paragraph.alignment = NSTextAlignmentCenter;
    
    NSDictionary *attributes = @{
                                 NSFontAttributeName:[UIFont systemFontOfSize:14.0f],
                                 NSForegroundColorAttributeName:[UIColor lightGrayColor],
                                 NSParagraphStyleAttributeName:paragraph
                                 };
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (UIView *)customViewForEmptyDataSet:(UIScrollView *)scrollView {
    if (self.isEmptyHidden) return nil;
    if (!self.isLoading) return nil;

    [self beginLoadingData];
    return self.activityView;
}


-(void)emptyDataSet:(UIScrollView *)scrollView didTapButton:(UIButton *)button{
    self.loading = YES;
    if (self.block){
        self.block();
    }
    
}

- (NSAttributedString *)buttonTitleForEmptyDataSet:(UIScrollView *)scrollView forState:(UIControlState)state {
    return nil;
    
//    if (self.isEmptyHidden){
//        return nil;
//    }
//    NSMutableDictionary *attribute = [[NSMutableDictionary alloc] init];
//    attribute[NSFontAttributeName] = [UIFont systemFontOfSize:15];
//    attribute[NSForegroundColorAttributeName] = BlueBg;
//    return [[NSAttributedString alloc] initWithString:@"点击刷新..." attributes:attribute];
}

- (BOOL)emptyDataSetShouldAllowScroll:(UIScrollView *)scrollView
{
    return YES;
}

@end
