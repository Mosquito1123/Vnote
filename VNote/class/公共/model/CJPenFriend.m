//
//  CJPenFriend.m
//  VNote
//
//  Created by ccj on 2018/6/30.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import "CJPenFriend.h"

@implementation CJPenFriend
-(id)copyWithZone:(NSZone *)zone
{
    CJPenFriend *pen = [[CJPenFriend alloc]init];
    pen.user_id = self.user_id;
    pen.nickname = self.nickname.mutableCopy;
    pen.email = self.email.mutableCopy;
    pen.is_share = self.is_share;
    pen.avtar_url = self.avtar_url.mutableCopy;
    pen.password = self.password.mutableCopy;
    pen.username = self.username.mutableCopy;
    pen.code_style = self.code_style.mutableCopy;
    pen.sex = self.sex.mutableCopy;
    pen.introduction = self.introduction.mutableCopy;
    pen.date_joined = self.date_joined.mutableCopy;
    pen.note_count = self.note_count.mutableCopy;
    pen.focused_count = self.focused_count.mutableCopy;;
    pen.follows_count = self.follows_count.mutableCopy;
    return pen;
    
}
+(instancetype)penFriendWithDict:(NSDictionary *)dict{
    CJPenFriend *pen = [[CJPenFriend alloc]init];
    pen.user_id = dict[@"id"];
    pen.nickname = dict[@"nickname"];
    pen.email = dict[@"email"];
    pen.is_share = [dict[@"is_share"] intValue];
    pen.avtar_url = dict[@"avtar_url"];
    pen.password = dict[@"password"];
    pen.username = dict[@"username"];
    pen.code_style = dict[@"code_style"];
    pen.sex = dict[@"sex"];
    pen.introduction = dict[@"introduction"];
    pen.date_joined = dict[@"date_joined"];
    pen.note_count = dict[@"note_count"];
    pen.focused_count = dict[@"focused_count"];
    pen.follows_count = dict[@"follows_count"];
    return pen;
}
@end
