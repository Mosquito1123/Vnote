//
//  CJRLMObject.m
//  VNote
//
//  Created by ccj on 2019/4/24.
//  Copyright © 2019 ccj. All rights reserved.
//

#import "CJRLMObject.h"

@implementation CJRLMObject
+(NSMutableArray *)rlmResults2ArrayWith:(RLMResults *)res{
    NSMutableArray *arrayM = [NSMutableArray array];
    for (id obj in res) {
        [arrayM addObject:obj];
    }
    return arrayM;
}
+(NSMutableArray *)cjAllObjectsInRlm:(RLMRealm *)rlm{
    NSMutableArray *arrayM = [NSMutableArray array];
    if (rlm == nil) return arrayM;
    RLMResults *res = [self allObjectsInRealm:rlm];
    return [self rlmResults2ArrayWith:res];
    
}
+(NSMutableArray *)cjObjectsInRlm:(RLMRealm *)rlm where:(NSString *)formater
{
    NSMutableArray *arrayM = [NSMutableArray array];
    if (rlm == nil) return arrayM;
    RLMResults *res = [self objectsInRealm:rlm where:formater];
    return [self rlmResults2ArrayWith:res];
}
@end
