//
//  CJRLMObject.h
//  VNote
//
//  Created by ccj on 2019/4/24.
//  Copyright © 2019 ccj. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CJRLMObject : RLMObject

+(NSMutableArray *)cjAllObjectsInRlm:(RLMRealm *)rlm;
+(NSMutableArray *)cjObjectsInRlm:(RLMRealm *)rlm where:(NSString *)formater;
@end

NS_ASSUME_NONNULL_END
