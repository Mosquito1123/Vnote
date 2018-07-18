//
//  CJPenFriend.h
//  VNote
//
//  Created by ccj on 2018/6/30.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CJPenFriend : RLMObject
@property NSString *v_user_id;
@property NSString *nickname;
@property NSString *avtar_url;
@property NSString *email;
+(instancetype)penFriendWithDict:(NSDictionary *)dict;
@end
