//
//  CJAPI.m
//  VNote
//
//  Created by ccj on 2018/8/19.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import "CJAPI.h"

@implementation CJAPI
+(void)changeCodeStyleWithParams:(NSDictionary *)dic success:(void(^)(NSDictionary *dic))success failure:(void (^)(NSError *error))failure{
    AFHTTPSessionManager *manger = [AFHTTPSessionManager sharedHttpSessionManager];
    [manger POST:API_CHANGE_CODE_STYLE parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
    }];
}
+(void)getRecentNotesWithParams:(NSDictionary *)dic success:(void(^)(NSDictionary *dic))success failure:(void (^)(NSError *error))failure{
    AFHTTPSessionManager *manger = [AFHTTPSessionManager sharedHttpSessionManager];
    [manger POST:API_RECENT_NOTES parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
    }];
}
+(void)deleteNote4EverWithParams:(NSDictionary *)dic success:(void(^)(NSDictionary *dic))success failure:(void (^)(NSError *error))failure{
    AFHTTPSessionManager *manger = [AFHTTPSessionManager sharedHttpSessionManager];
    [manger POST:API_DEL_NOTE_4ERVER parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
    }];
}
+(void)clearTrashWithParams:(NSDictionary *)dic success:(void(^)(NSDictionary *dic))success failure:(void (^)(NSError *error))failure{
    AFHTTPSessionManager *manger = [AFHTTPSessionManager sharedHttpSessionManager];
    [manger POST:API_CLEAR_TRASH parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
    }];
}
+(void)getTrashNotesWithParams:(NSDictionary *)dic success:(void(^)(NSDictionary *dic))success failure:(void (^)(NSError *error))failure{
    AFHTTPSessionManager *manger = [AFHTTPSessionManager sharedHttpSessionManager];
    [manger POST:API_GET_TRASH_NOTES parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
    }];
}
+(void)searchNoteWithParams:(NSDictionary *)dic success:(void(^)(NSDictionary *dic))success failure:(void (^)(NSError *error))failure{
    AFHTTPSessionManager *manger = [AFHTTPSessionManager sharedHttpSessionManager];
    [manger POST:API_SEARCH_NOTE parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
    }];
}
+(void)uploadAvtarWithParams:(NSDictionary *)dic success:(void(^)(NSDictionary *dic))success failure:(void (^)(NSError *error))failure{
    AFHTTPSessionManager *manger = [AFHTTPSessionManager sharedHttpSessionManager];
    [manger POST:API_UPLOAD_AVTAR parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
    }];
}
+(void)shareNoteWithParams:(NSDictionary *)dic success:(void(^)(NSDictionary *dic))success failure:(void (^)(NSError *error))failure{
    AFHTTPSessionManager *manger = [AFHTTPSessionManager sharedHttpSessionManager];
    [manger POST:API_SHARE_NOTE parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
    }];
}
+(void)getPenFriendsWithParams:(NSDictionary *)dic success:(void(^)(NSDictionary *dic))success failure:(void (^)(NSError *error))failure{
    AFHTTPSessionManager *manger = [AFHTTPSessionManager sharedHttpSessionManager];
    [manger POST:API_PEN_FRIENDS parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
    }];
}
+(void)searchUserWithParams:(NSDictionary *)dic success:(void(^)(NSDictionary *dic))success failure:(void (^)(NSError *error))failure{
    AFHTTPSessionManager *manger = [AFHTTPSessionManager sharedHttpSessionManager];
    [manger POST:API_SEARCH_USERS parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
    }];
}

+(void)focusWithParams:(NSDictionary *)dic success:(void(^)(NSDictionary *dic))success failure:(void (^)(NSError *error))failure{
    AFHTTPSessionManager *manger = [AFHTTPSessionManager sharedHttpSessionManager];
    [manger POST:API_FOCUS_USER parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
    }];
}

+(void)cancelFocusWithParams:(NSDictionary *)dic success:(void(^)(NSDictionary *dic))success failure:(void (^)(NSError *error))failure{
    AFHTTPSessionManager *manger = [AFHTTPSessionManager sharedHttpSessionManager];
    [manger POST:API_CANCEL_FOCUSED parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
    }];
}

+(void)getCodeWithParams:(NSDictionary *)dic success:(void(^)(NSDictionary *dic))success failure:(void (^)(NSError *error))failure{
    AFHTTPSessionManager *manger = [AFHTTPSessionManager sharedHttpSessionManager];
    [manger POST:API_GET_CODE parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
    }];
}

+(void)registerWithParams:(NSDictionary *)dic success:(void(^)(NSDictionary *dic))success failure:(void (^)(NSError *error))failure{
    AFHTTPSessionManager *manger = [AFHTTPSessionManager sharedHttpSessionManager];
    [manger POST:API_REGISTER parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [CJUser userWithDict:responseObject];
        success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
    }];
}
+(void)loginWithParams:(NSDictionary *)dic success:(void(^)(NSDictionary *dic))success failure:(void (^)(NSError *error))failure{
    AFHTTPSessionManager *manger = [AFHTTPSessionManager sharedHttpSessionManager];
    [manger POST:API_LOGIN parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, NSDictionary * _Nullable dic) {
        [CJUser userWithDict:dic];
        
        [CJTool catchAccountInfo2Preference:dic];
        NSNotification *noti = [NSNotification notificationWithName:LOGIN_ACCOUT_NOTI object:nil];
        [[NSNotificationCenter defaultCenter]postNotification:noti];
        success(dic);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
    }];
}
+(void)saveNoteWithParams:(NSDictionary *)dic success:(void(^)(NSDictionary *dic))success failure:(void (^)(NSError *error))failure{
    AFHTTPSessionManager *manger = [AFHTTPSessionManager sharedHttpSessionManager];
    [manger POST:API_SAVE_NOTE parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
    }];
}
+(void)moveNoteWithParams:(NSDictionary *)dic success:(void(^)(NSDictionary *dic))success failure:(void (^)(NSError *error))failure{
    AFHTTPSessionManager *manger = [AFHTTPSessionManager sharedHttpSessionManager];
    [manger POST:API_MOVE_NOTE parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(responseObject);
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTE_CHANGE_NOTI object:nil];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
    }];
}


+(void)moveNotesWithParams:(NSDictionary *)dic success:(void(^)(NSDictionary *dic))success failure:(void (^)(NSError *error))failure{
    AFHTTPSessionManager *manger = [AFHTTPSessionManager sharedHttpSessionManager];
    [manger POST:API_MOVE_NOTES parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(responseObject);
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTE_CHANGE_NOTI object:nil];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
    }];
}

+(void)addNoteWithParams:(NSDictionary *)dic success:(void(^)(NSDictionary *dic))success failure:(void (^)(NSError *error))failure{
    AFHTTPSessionManager *manger = [AFHTTPSessionManager sharedHttpSessionManager];
    [manger POST:API_ADD_NOTE parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(responseObject);
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTE_CHANGE_NOTI object:nil];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
    }];
}

+(void)deleteNoteWithParams:(NSDictionary *)dic success:(void(^)(NSDictionary *dic))success failure:(void (^)(NSError *error))failure{
    AFHTTPSessionManager *manger = [AFHTTPSessionManager sharedHttpSessionManager];
    [manger POST:API_DEL_NOTE parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(responseObject);
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTE_CHANGE_NOTI object:nil];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
    }];
}

+(void)deleteNotesWithParams:(NSDictionary *)dic success:(void(^)(NSDictionary *dic))success failure:(void (^)(NSError *error))failure{
    AFHTTPSessionManager *manger = [AFHTTPSessionManager sharedHttpSessionManager];
    [manger POST:API_DEL_NOTES parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(responseObject);
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTE_CHANGE_NOTI object:nil];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
    }];
}
+(void)bookDetailWithParams:(NSDictionary *)dic success:(void(^)(NSDictionary *dic))success failure:(void (^)(NSError *error))failure{
    AFHTTPSessionManager *manger = [AFHTTPSessionManager sharedHttpSessionManager];
    [manger POST:API_BOOK_DETAIL parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
    }];
}
+(void)getBooksAndNotesWithParams:(NSDictionary *)dic success:(void(^)(NSDictionary *))success failure:(void (^)(NSError *))failure{
    AFHTTPSessionManager *manger = [AFHTTPSessionManager sharedHttpSessionManager];
    [manger POST:API_GET_ALL_BOOKS_AND_NOTES parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
    }];
}
+(void)deleteBookWithParams:(NSDictionary *)dic success:(void(^)(NSDictionary *))success failure:(void (^)(NSError *))failure{
    AFHTTPSessionManager *manger = [AFHTTPSessionManager sharedHttpSessionManager];
    [manger POST:API_DEL_BOOK parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(responseObject);
        [[NSNotificationCenter defaultCenter] postNotificationName:BOOK_CHANGE_NOTI object:nil];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
    }];
}

+(void)renameBookWithParams:(NSDictionary *)dic success:(void(^)(NSDictionary *))success failure:(void (^)(NSError *))failure{
    AFHTTPSessionManager *manger = [AFHTTPSessionManager sharedHttpSessionManager];
    [manger POST:API_RENAME_BOOK parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(responseObject);
        [[NSNotificationCenter defaultCenter] postNotificationName:BOOK_CHANGE_NOTI object:nil];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
    }];
}

+(void)addBookWithParams:(NSDictionary *)dic success:(void(^)(NSDictionary *))success failure:(void (^)(NSError *))failure{
    AFHTTPSessionManager *manger = [AFHTTPSessionManager sharedHttpSessionManager];
    [manger POST:API_ADD_BOOK parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(responseObject);
        [[NSNotificationCenter defaultCenter] postNotificationName:BOOK_CHANGE_NOTI object:nil];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
    }];
}
@end
