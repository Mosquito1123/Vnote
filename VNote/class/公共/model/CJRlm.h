//
//  CJRlm.h
//  VNote
//
//  Created by ccj on 2018/7/22.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import "RLMRealm.h"

@interface CJRlm : RLMRealm
+(RLMRealm *)cjRlmWithName:(NSString *)name;
+(RLMRealm *)shareRlm;
+(void)deleteObject:(RLMObject *)obj;
+(void)deleteObjects:(id<NSFastEnumeration>)objects;
+(void)addObjects:(id<NSFastEnumeration>)objects;
+(void)addObject:(RLMObject *)obj;
@end
