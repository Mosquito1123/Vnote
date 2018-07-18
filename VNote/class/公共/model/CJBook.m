//
//  CJBook.m
//  VNote
//
//  Created by ccj on 2018/6/3.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import "CJBook.h"

@implementation CJBook

+ (NSArray *)indexedProperties {
    return @[@"uuid"];
}
+(instancetype)bookWithDict:(NSDictionary *)dict{
    CJBook *book = [[CJBook alloc]init];
    book.name = dict[@"name"];
    book.uuid = dict[@"uuid"];
    book.count = [dict[@"count"] intValue];
    return book;
}
@end
