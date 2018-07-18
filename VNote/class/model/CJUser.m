//
//  CJUser.m
//  VNote
//
//  Created by ccj on 2018/6/30.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import "CJUser.h"

@implementation CJUser
CJSingletonM(User)
+(instancetype)userWithDict:(NSDictionary *)dict{
    CJUser *user = [[CJUser alloc]init];
    user.nickname = dict[@"nickname"];
    user.email = dict[@"email"];
    user.is_share = [dict[@"is_share"] intValue];
    user.avtar_url = dict[@"avtar_url"];
    user.password = dict[@"password"];
    user.username = dict[@"username"];
    
    NSUserDefaults *userD = [NSUserDefaults standardUserDefaults];
    
    for (NSString *key in dict) {
        [userD setValue:dict[key] forKey:key];
    }
    [userD synchronize];
    return user;
}
+(instancetype)userWithUserDefaults:(NSUserDefaults *)userD{
    NSDictionary *dict = [userD dictionaryRepresentation];
    return [CJUser userWithDict:dict];
}
@end
