//
//  CJUser.h
//  VNote
//
//  Created by ccj on 2018/6/30.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CJUser : NSObject
@property(nonatomic,copy)NSString *nickname;
@property(nonatomic,copy)NSString *username;
@property(nonatomic,copy)NSString *email;
@property(nonatomic,copy)NSString *password;
@property(nonatomic,assign)int is_share;
@property(nonatomic,copy)NSString *avtar_url;
@property(nonatomic,copy) NSString *code_style;
+(instancetype)userWithDict:(NSDictionary *)dict;
+(instancetype)userWithUserDefaults:(NSUserDefaults *)userD;
-(NSDictionary *)toDic;
CJSingletonH(User)
@end

