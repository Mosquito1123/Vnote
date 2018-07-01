//
//  CJPenFriend.h
//  VNote
//
//  Created by ccj on 2018/6/30.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CJPenFriend : NSObject
@property(nonatomic,copy)NSString *v_user_id;
@property(nonatomic,copy)NSString *nickname;
@property(nonatomic,copy)NSString *avtar_url;
@property(nonatomic,copy)NSString *email;
+(instancetype)penFriendWithDict:(NSDictionary *)dict;
@end
