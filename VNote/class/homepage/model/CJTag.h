//
//  CJTag.h
//  VNote
//
//  Created by ccj on 2018/6/3.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CJTag : NSObject
@property(strong,nonatomic)NSMutableArray *noteInfos;
@property(assign,nonatomic)int count;
@property(strong,nonatomic)NSString *tag;

+(instancetype)tagWithDict:(NSDictionary *)dic;
@end
