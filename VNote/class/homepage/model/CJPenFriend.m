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
    pen.nickname = dict[@"nickname"];
    pen.avtar_url = dict[@"avtar_url"];
    pen.email = dict[@"email"];
    return pen;
}
@end
