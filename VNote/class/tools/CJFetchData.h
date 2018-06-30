//
//  CJFetchData.h
//  VNote
//
//  Created by ccj on 2018/6/30.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CJFetchData : NSObject
+(void)fetchDataWithAPI:(NSString *)api postData:(NSDictionary *)parms completionHandler:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completionHandler;
@end
