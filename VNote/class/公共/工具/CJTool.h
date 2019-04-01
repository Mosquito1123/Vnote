//
//  Tool.h
//  VNote
//
//  Created by ccj on 2018/8/4.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString *NoteOrderTypeUp;
FOUNDATION_EXPORT NSString *NoteOrderTypeDown;
@interface CJTool : NSObject
+(void)catchAccountInfo2Preference:(NSDictionary *)dic;
+(NSMutableArray *)orderObjects:(NSArray *)array withKey:(NSString *)key;
+(void)saveUserInfo2JsonWithNoteOrder:(NSString *)order closePenfriendFunc:(BOOL)b;
+(NSString *)getNoteOrder;
+(BOOL)getClosePenFriendFunc;
@end
