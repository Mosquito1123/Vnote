//
//  CJRefreshGif.m
//  VNote
//
//  Created by ccj on 2018/7/14.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import "CJRefreshGif.h"
const NSInteger imgCount = 5;

@implementation MJRefreshGifHeader (gif)

+(instancetype)cjRefreshWithPullType:(CJPullType)type header:(void(^)(void))block{
    MJRefreshGifHeader *gifHeader=[MJRefreshGifHeader headerWithRefreshingBlock:block];
        
    //下拉时出现的动画
    NSMutableArray *idleImages=[NSMutableArray array];
    
    for (int i = 1; i <= imgCount; i++){
        
        NSString *idleStr=[NSString stringWithFormat:@"%@%d",type == CJPullTypeNormal ? @"pull" : @"pull白",i];
        UIImage *idleImage=[UIImage imageNamed:idleStr];
        [idleImages addObject:idleImage];
    }
    
    [gifHeader setImages:idleImages forState:MJRefreshStateIdle];

    //刷新时出现的动画
    NSMutableArray *refreshImages=[NSMutableArray array];
    for (int i = 1; i <= imgCount; i++){
        NSString *refreshStr=[NSString stringWithFormat:@"%@%d",type == CJPullTypeNormal ? @"pull" : @"pull白",i];
        UIImage *refreshImage=[UIImage imageNamed:refreshStr];
        [refreshImages addObject:refreshImage];
    }
    [gifHeader setImages:refreshImages forState:MJRefreshStateRefreshing];
    gifHeader.lastUpdatedTimeLabel.hidden=YES;
    
    gifHeader.stateLabel.hidden=YES;

    [gifHeader setTitle:@"pull to refresh" forState:MJRefreshStateIdle];
    [gifHeader setTitle:@"refreshing" forState:MJRefreshStateRefreshing];
    [gifHeader setTitle:@"release to fresh" forState:MJRefreshStatePulling];
    return gifHeader;
}

@end
