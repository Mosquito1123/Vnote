//
//  CJAPI.h
//  VNote
//
//  Created by ccj on 2018/8/19.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CJAPI : NSObject
+(void)requestWithAPI:(NSString *)api params:(NSDictionary *)params success:(void(^)(NSDictionary *dic))success failure:(void (^)(NSDictionary *dic))failure error:(void (^)(NSError *error))failure;

@end
