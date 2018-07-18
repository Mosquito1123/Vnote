//
//  CJBook.h
//  VNote
//
//  Created by ccj on 2018/6/3.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CJBook : RLMObject

@property(nonatomic,strong) NSString *name;
@property(nonatomic,strong) NSString *uuid;
@property(nonatomic,assign) int count;

+(instancetype)bookWithDict:(NSDictionary *)dict;
@end
