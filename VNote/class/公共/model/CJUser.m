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
-(NSDictionary *)toDic{
    return @{@"nickname":self.nickname,
             @"email":self.email,
             @"is_share":[NSString stringWithFormat:@"%d",self.is_share],
             @"avtar_url":self.avtar_url,
             @"password":self.password,
             @"username":self.username,
             @"code_style":self.code_style,
             @"sex":self.sex,
             @"introduction":self.introduction,
             @"date_joined":self.date_joined
             };
}
+(instancetype)userWithDict:(NSDictionary *)dict{
    CJUser *user = [[CJUser alloc]init];
    user.nickname = dict[@"nickname"];
    user.email = dict[@"email"];
    user.is_share = [dict[@"is_share"] intValue];
    user.avtar_url = dict[@"avtar_url"];
    user.password = dict[@"password"];
    user.username = dict[@"username"];
    user.code_style = dict[@"code_style"];
    user.sex = dict[@"sex"];
    user.introduction = dict[@"introduction"];
    user.date_joined = dict[@"date_joined"];
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
