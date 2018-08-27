//
//  CJPenFriend.m
//  VNote
//
//  Created by ccj on 2018/6/30.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import "CJPenFriend.h"

@implementation CJPenFriend
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
    pen.focused_count = dict[@"follows_count"];
    pen.follows_count = dict[@"follows_count"];
    return pen;
}
@end
