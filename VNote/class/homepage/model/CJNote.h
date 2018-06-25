//
//  CJBook.h
//  VNote
//
//  Created by ccj on 2018/6/3.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CJNote : NSObject
@property(nonatomic,strong) NSString *book_uuid;
@property(nonatomic,strong) NSString *book_title;
@property(nonatomic,strong) NSString *content;
@property(nonatomic,strong) NSString *created_at;
@property(nonatomic,strong) NSArray *tags;
@property(nonatomic,strong) NSString *title;
@property(nonatomic,strong) NSString *updated_at;
@property(nonatomic,strong) NSString *uuid;
+(instancetype)noteWithDict:(NSDictionary *)dic;

@end
