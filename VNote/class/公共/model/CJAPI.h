//
//  CJAPI.h
//  VNote
//
//  Created by ccj on 2018/8/19.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CJAPI : NSObject
+(void)changeIntroWithParams:(NSDictionary *)dic success:(void(^)(NSDictionary *dic))success failure:(void (^)(NSError *error))failure;
+(void)changeSexWithParams:(NSDictionary *)dic success:(void(^)(NSDictionary *dic))success failure:(void (^)(NSError *error))failure;
+(void)getAllTagsWithParams:(NSDictionary *)dic success:(void(^)(NSDictionary *dic))success failure:(void (^)(NSError *error))failure;
+(void)deleteBookWithParams:(NSDictionary *)dic success:(void(^)(NSDictionary *dic))success failure:(void (^)(NSError *error))failure;
+(void)renameBookWithParams:(NSDictionary *)dic success:(void(^)(NSDictionary *dic))success failure:(void (^)(NSError *error))failure;
+(void)addBookWithParams:(NSDictionary *)dic success:(void(^)(NSDictionary *dic))success failure:(void (^)(NSError *error))failure;
+(void)getBooksAndNotesWithParams:(NSDictionary *)dic success:(void(^)(NSDictionary *dic))success failure:(void (^)(NSError *error))failure;
+(void)bookDetailWithParams:(NSDictionary *)dic success:(void(^)(NSDictionary *dic))success failure:(void (^)(NSError *error))failure;
+(void)deleteNotesWithParams:(NSDictionary *)dic success:(void(^)(NSDictionary *dic))success failure:(void (^)(NSError *error))failure;
+(void)deleteNoteWithParams:(NSDictionary *)dic success:(void(^)(NSDictionary *dic))success failure:(void (^)(NSError *error))failure;
+(void)moveNotesWithParams:(NSDictionary *)dic success:(void(^)(NSDictionary *dic))success failure:(void (^)(NSError *error))failure;
+(void)moveNoteWithParams:(NSDictionary *)dic success:(void(^)(NSDictionary *dic))success failure:(void (^)(NSError *error))failure;
+(void)saveNoteWithParams:(NSDictionary *)dic success:(void(^)(NSDictionary *dic))success failure:(void (^)(NSError *error))failure;
+(void)addNoteWithParams:(NSDictionary *)dic success:(void(^)(NSDictionary *dic))success failure:(void (^)(NSError *error))failure;
+(void)loginWithParams:(NSDictionary *)dic success:(void(^)(NSDictionary *dic))success failure:(void (^)(NSError *error))failure;
+(void)registerWithParams:(NSDictionary *)dic success:(void(^)(NSDictionary *dic))success failure:(void (^)(NSError *error))failure;
+(void)getCodeWithParams:(NSDictionary *)dic success:(void(^)(NSDictionary *dic))success failure:(void (^)(NSError *error))failure;
+(void)cancelFocusWithParams:(NSDictionary *)dic success:(void(^)(NSDictionary *dic))success failure:(void (^)(NSError *error))failure;
+(void)focusWithParams:(NSDictionary *)dic success:(void(^)(NSDictionary *dic))success failure:(void (^)(NSError *error))failure;
+(void)searchUserWithParams:(NSDictionary *)dic success:(void(^)(NSDictionary *dic))success failure:(void (^)(NSError *error))failure;
+(void)getPenFriendsWithParams:(NSDictionary *)dic success:(void(^)(NSDictionary *dic))success failure:(void (^)(NSError *error))failure;
+(void)shareNoteWithParams:(NSDictionary *)dic success:(void(^)(NSDictionary *dic))success failure:(void (^)(NSError *error))failure;
+(void)uploadAvtarWithParams:(NSDictionary *)dic success:(void(^)(NSDictionary *dic))success failure:(void (^)(NSError *error))failure;
+(void)searchNoteWithParams:(NSDictionary *)dic success:(void(^)(NSDictionary *dic))success failure:(void (^)(NSError *error))failure;
+(void)getTrashNotesWithParams:(NSDictionary *)dic success:(void(^)(NSDictionary *dic))success failure:(void (^)(NSError *error))failure;
+(void)clearTrashWithParams:(NSDictionary *)dic success:(void(^)(NSDictionary *dic))success failure:(void (^)(NSError *error))failure;
+(void)deleteNote4EverWithParams:(NSDictionary *)dic success:(void(^)(NSDictionary *dic))success failure:(void (^)(NSError *error))failure;
+(void)getRecentNotesWithParams:(NSDictionary *)dic success:(void(^)(NSDictionary *dic))success failure:(void (^)(NSError *error))failure;
+(void)changeCodeStyleWithParams:(NSDictionary *)dic success:(void(^)(NSDictionary *dic))success failure:(void (^)(NSError *error))failure;
@end
