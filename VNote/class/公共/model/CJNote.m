//
//  CJBook.m
//  VNote
//
//  Created by ccj on 2018/6/3.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import "CJNote.h"
#import "CJBook.h"
@implementation CJNote
-(instancetype)initWithDict:(NSDictionary *)dic{
    if (self = [super init]){
        self.book_uuid = dic[@"book_uuid"];
        self.created_at = dic[@"created_at"];
        self.updated_at = dic[@"updated_at"];
        self.title = dic[@"title"];
        self.tags = dic[@"tags"];
        self.uuid = dic[@"uuid"];
    }
    return self;
}

+(instancetype)noteWithDict:(NSDictionary *)dic{
    return [[self alloc]initWithDict:dic];
}
@end
