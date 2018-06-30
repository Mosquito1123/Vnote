//
//  CJFetchData.m
//  VNote
//
//  Created by ccj on 2018/6/30.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import "CJFetchData.h"

@implementation CJFetchData
+(void)fetchDataWithAPI:(NSString *)api postData:(NSDictionary *)parms completionHandler:(void (^)(NSData *, NSURLResponse *, NSError *))completionHandler{
    NSURLSession *session = [NSURLSession sharedSession];
    NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:[NSURL URLWithString:api]];
    request.HTTPMethod = @"POST";
    NSData *data = [NSJSONSerialization dataWithJSONObject:parms options:NSJSONWritingPrettyPrinted error:nil];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    request.HTTPBody = data;
    // 加载数据
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        completionHandler(data,response,error);
        
    }];
    [task resume];
}
@end
