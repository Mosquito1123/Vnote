//
//  CJTag.h
//  VNote
//
//  Created by ccj on 2018/6/3.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CJNote.h"

@interface CJTag : RLMObject

@property(assign,nonatomic)int count;
@property(copy,nonatomic)NSString *tag;
+(instancetype)tagWithDict:(NSDictionary *)dic;
@end

RLM_ARRAY_TYPE(CJTag)
