//
//  AFHTTPSessionManager+AFHttpSessionCategory.h
//  VNote
//
//  Created by ccj on 2018/8/18.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import "AFHTTPSessionManager.h"

@interface AFHTTPSessionManager (AFHttpSessionCategory)
+(AFHTTPSessionManager *)sharedHttpSessionManager;
@end
