//
//  CJTag.m
//  VNote
//
//  Created by ccj on 2018/6/3.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import "CJTag.h"
#import "CJNote.h"
@implementation CJTag
+(instancetype)tagWithDict:(NSDictionary*)dic{
    CJTag *tag = [[CJTag alloc]init];
    tag.count = [dic[@"count"] intValue];
    tag.tag = dic[@"tag"];
    return tag;
}
@end
