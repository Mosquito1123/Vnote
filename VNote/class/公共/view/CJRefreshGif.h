//
//  CJRefreshGif.h
//  VNote
//
//  Created by ccj on 2018/7/14.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,CJPullType){
    CJPullTypeNormal = 0,
    CJPullTypeWhite,
};

@interface MJRefreshGifHeader (gif)
+(instancetype)cjRefreshWithPullType:(CJPullType)type header:(void(^)(void))block;
@end
