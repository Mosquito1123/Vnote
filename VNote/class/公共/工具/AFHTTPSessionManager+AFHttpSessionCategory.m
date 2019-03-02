//
//  AFHTTPSessionManager+AFHttpSessionCategory.m
//  VNote
//
//  Created by ccj on 2018/8/18.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import "AFHTTPSessionManager+AFHttpSessionCategory.h"

@implementation AFHTTPSessionManager (AFHttpSessionCategory)
static AFHTTPSessionManager *manager;

+(AFHTTPSessionManager *)sharedHttpSessionManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [AFHTTPSessionManager manager];
        manager.requestSerializer.timeoutInterval = 5.0;
    });
    
    return manager;
}



@end
