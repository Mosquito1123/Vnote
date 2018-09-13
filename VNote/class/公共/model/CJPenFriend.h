//
//  CJPenFriend.h
//  VNote
//
//  Created by ccj on 2018/6/30.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CJPenFriend : RLMObject<NSCopying>
@property(nonatomic,copy) NSString *user_id;
@property(nonatomic,copy)NSString *nickname;
@property(nonatomic,copy)NSString *username;
@property(nonatomic,copy)NSString *email;
@property(nonatomic,copy)NSString *password;
@property(nonatomic,assign)int is_share;
@property(nonatomic,copy)NSString *avtar_url;
@property(nonatomic,copy) NSString *code_style;
@property(nonatomic,copy) NSString *sex;
@property(nonatomic,copy) NSString *introduction;
@property(nonatomic,copy) NSString *date_joined;
@property(nonatomic,copy) NSString *note_count;
@property(nonatomic,copy) NSString *focused_count;
@property(nonatomic,copy) NSString *follows_count;
+(instancetype)penFriendWithDict:(NSDictionary *)dict;
@end
