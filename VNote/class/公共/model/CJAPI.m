//
//  CJAPI.m
//  VNote
//
//  Created by ccj on 2018/8/19.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import "CJAPI.h"

@implementation CJAPI
+(void)changeNicknameWithParams:(NSDictionary *)dic success:(void(^)(NSDictionary *dic))success failure:(void (^)(NSError *error))failure{
    AFHTTPSessionManager *manger = [AFHTTPSessionManager sharedHttpSessionManager];
    [manger POST:API_CHANGE_NICKNAME parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
        [CJProgressHUD cjShowErrorWithPosition:CJProgressHUDPositionBothExist withText:@"网络不在状态!"];

    }];
}
+(void)getFollowsWithParams:(NSDictionary *)dic success:(void(^)(NSDictionary *dic))success failure:(void (^)(NSError *error))failure{
    AFHTTPSessionManager *manger = [AFHTTPSessionManager sharedHttpSessionManager];
    [manger POST:API_FOLLOWS parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
        [CJProgressHUD cjShowErrorWithPosition:CJProgressHUDPositionBothExist withText:@"网络不在状态!"];
    }];
}
+(void)changeIntroWithParams:(NSDictionary *)dic success:(void(^)(NSDictionary *dic))success failure:(void (^)(NSError *error))failure{
    AFHTTPSessionManager *manger = [AFHTTPSessionManager sharedHttpSessionManager];
    [manger POST:API_CHANGE_INTRODUCTION parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
        [CJProgressHUD cjShowErrorWithPosition:CJProgressHUDPositionBothExist withText:@"网络不在状态!"];

    }];
}
+(void)changeSexWithParams:(NSDictionary *)dic success:(void(^)(NSDictionary *dic))success failure:(void (^)(NSError *error))failure{
    AFHTTPSessionManager *manger = [AFHTTPSessionManager sharedHttpSessionManager];
    [manger POST:API_CHANGE_SEX parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
        [CJProgressHUD cjShowErrorWithPosition:CJProgressHUDPositionBothExist withText:@"网络不在状态!"];

    }];
}
+(void)getAllTagsWithParams:(NSDictionary *)dic success:(void(^)(NSDictionary *dic))success failure:(void (^)(NSError *error))failure{
    AFHTTPSessionManager *manger = [AFHTTPSessionManager sharedHttpSessionManager];
    [manger POST:API_GET_ALL_TAGS parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
        [CJProgressHUD cjShowErrorWithPosition:CJProgressHUDPositionBothExist withText:@"网络不在状态!"];

    }];
}
+(void)changeCodeStyleWithParams:(NSDictionary *)dic success:(void(^)(NSDictionary *dic))success failure:(void (^)(NSError *error))failure{
    AFHTTPSessionManager *manger = [AFHTTPSessionManager sharedHttpSessionManager];
    [manger POST:API_CHANGE_CODE_STYLE parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
        [CJProgressHUD cjShowErrorWithPosition:CJProgressHUDPositionBothExist withText:@"网络不在状态!"];

    }];
}
+(void)getRecentNotesWithParams:(NSDictionary *)dic success:(void(^)(NSDictionary *dic))success failure:(void (^)(NSError *error))failure{
    AFHTTPSessionManager *manger = [AFHTTPSessionManager sharedHttpSessionManager];
    [manger POST:API_RECENT_NOTES parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
        [CJProgressHUD cjShowErrorWithPosition:CJProgressHUDPositionBothExist withText:@"网络不在状态!"];

    }];
}
+(void)deleteNote4EverWithParams:(NSDictionary *)dic success:(void(^)(NSDictionary *dic))success failure:(void (^)(NSError *error))failure{
    AFHTTPSessionManager *manger = [AFHTTPSessionManager sharedHttpSessionManager];
    [manger POST:API_DEL_NOTE_4ERVER parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
        [CJProgressHUD cjShowErrorWithPosition:CJProgressHUDPositionBothExist withText:@"网络不在状态!"];

    }];
}
+(void)clearTrashWithParams:(NSDictionary *)dic success:(void(^)(NSDictionary *dic))success failure:(void (^)(NSError *error))failure{
    AFHTTPSessionManager *manger = [AFHTTPSessionManager sharedHttpSessionManager];
    [manger POST:API_CLEAR_TRASH parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
        [CJProgressHUD cjShowErrorWithPosition:CJProgressHUDPositionBothExist withText:@"网络不在状态!"];

    }];
}
+(void)getTrashNotesWithParams:(NSDictionary *)dic success:(void(^)(NSDictionary *dic))success failure:(void (^)(NSError *error))failure{
    AFHTTPSessionManager *manger = [AFHTTPSessionManager sharedHttpSessionManager];
    [manger POST:API_GET_TRASH_NOTES parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
        [CJProgressHUD cjShowErrorWithPosition:CJProgressHUDPositionBothExist withText:@"网络不在状态!"];

    }];
}
+(void)searchNoteWithParams:(NSDictionary *)dic success:(void(^)(NSDictionary *dic))success failure:(void (^)(NSError *error))failure{
    AFHTTPSessionManager *manger = [AFHTTPSessionManager sharedHttpSessionManager];
    [manger POST:API_SEARCH_NOTE parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
        [CJProgressHUD cjShowErrorWithPosition:CJProgressHUDPositionBothExist withText:@"网络不在状态!"];

    }];
}
+(void)uploadAvtarWithParams:(NSDictionary *)dic success:(void(^)(NSDictionary *dic))success failure:(void (^)(NSError *error))failure{
    AFHTTPSessionManager *manger = [AFHTTPSessionManager sharedHttpSessionManager];
    [manger POST:API_UPLOAD_AVTAR parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
        [CJProgressHUD cjShowErrorWithPosition:CJProgressHUDPositionBothExist withText:@"网络不在状态!"];

    }];
}
+(void)shareNoteWithParams:(NSDictionary *)dic success:(void(^)(NSDictionary *dic))success failure:(void (^)(NSError *error))failure{
    AFHTTPSessionManager *manger = [AFHTTPSessionManager sharedHttpSessionManager];
    [manger POST:API_SHARE_NOTE parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
        [CJProgressHUD cjShowErrorWithPosition:CJProgressHUDPositionBothExist withText:@"网络不在状态!"];

    }];
}
+(void)getPenFriendsWithParams:(NSDictionary *)dic success:(void(^)(NSDictionary *dic))success failure:(void (^)(NSError *error))failure{
    AFHTTPSessionManager *manger = [AFHTTPSessionManager sharedHttpSessionManager];
    [manger POST:API_PEN_FRIENDS parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
        [CJProgressHUD cjShowErrorWithPosition:CJProgressHUDPositionBothExist withText:@"网络不在状态!"];

    }];
}
+(void)searchUserWithParams:(NSDictionary *)dic success:(void(^)(NSDictionary *dic))success failure:(void (^)(NSError *error))failure{
    AFHTTPSessionManager *manger = [AFHTTPSessionManager sharedHttpSessionManager];
    [manger POST:API_SEARCH_USERS parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
        [CJProgressHUD cjShowErrorWithPosition:CJProgressHUDPositionBothExist withText:@"网络不在状态!"];

    }];
}

+(void)focusWithParams:(NSDictionary *)dic success:(void(^)(NSDictionary *dic))success failure:(void (^)(NSError *error))failure{
    AFHTTPSessionManager *manger = [AFHTTPSessionManager sharedHttpSessionManager];
    [manger POST:API_FOCUS_USER parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
        [CJProgressHUD cjShowErrorWithPosition:CJProgressHUDPositionBothExist withText:@"网络不在状态!"];

    }];
}

+(void)cancelFocusWithParams:(NSDictionary *)dic success:(void(^)(NSDictionary *dic))success failure:(void (^)(NSError *error))failure{
    AFHTTPSessionManager *manger = [AFHTTPSessionManager sharedHttpSessionManager];
    [manger POST:API_CANCEL_FOCUSED parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
        [CJProgressHUD cjShowErrorWithPosition:CJProgressHUDPositionBothExist withText:@"网络不在状态!"];

    }];
}

+(void)getCodeWithParams:(NSDictionary *)dic success:(void(^)(NSDictionary *dic))success failure:(void (^)(NSError *error))failure{
    AFHTTPSessionManager *manger = [AFHTTPSessionManager sharedHttpSessionManager];
    [manger POST:API_GET_CODE parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
        [CJProgressHUD cjShowErrorWithPosition:CJProgressHUDPositionBothExist withText:@"网络不在状态!"];

    }];
}

+(void)registerWithParams:(NSDictionary *)dic success:(void(^)(NSDictionary *dic))success failure:(void (^)(NSError *error))failure{
    AFHTTPSessionManager *manger = [AFHTTPSessionManager sharedHttpSessionManager];
    [manger POST:API_REGISTER parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [CJUser userWithDict:responseObject];
        [CJTool catchAccountInfo2Preference:dic];
        NSNotification *noti = [NSNotification notificationWithName:LOGIN_ACCOUT_NOTI object:nil];
        [[NSNotificationCenter defaultCenter]postNotification:noti];
        success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
        [CJProgressHUD cjShowErrorWithPosition:CJProgressHUDPositionBothExist withText:@"网络不在状态!"];

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
        [CJProgressHUD cjShowErrorWithPosition:CJProgressHUDPositionBothExist withText:@"网络不在状态!"];

        
    }];
}
+(void)saveNoteWithParams:(NSDictionary *)dic success:(void(^)(NSDictionary *dic))success failure:(void (^)(NSError *error))failure{
    AFHTTPSessionManager *manger = [AFHTTPSessionManager sharedHttpSessionManager];
    [manger POST:API_SAVE_NOTE parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
        [CJProgressHUD cjShowErrorWithPosition:CJProgressHUDPositionBothExist withText:@"网络不在状态!"];

    }];
}
+(void)moveNoteWithParams:(NSDictionary *)dic success:(void(^)(NSDictionary *dic))success failure:(void (^)(NSError *error))failure{
    AFHTTPSessionManager *manger = [AFHTTPSessionManager sharedHttpSessionManager];
    [manger POST:API_MOVE_NOTE parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(responseObject);
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTE_CHANGE_NOTI object:nil];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
        [CJProgressHUD cjShowErrorWithPosition:CJProgressHUDPositionBothExist withText:@"网络不在状态!"];

    }];
}


+(void)moveNotesWithParams:(NSDictionary *)dic success:(void(^)(NSDictionary *dic))success failure:(void (^)(NSError *error))failure{
    AFHTTPSessionManager *manger = [AFHTTPSessionManager sharedHttpSessionManager];
    [manger POST:API_MOVE_NOTES parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(responseObject);
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTE_CHANGE_NOTI object:nil];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
        [CJProgressHUD cjShowErrorWithPosition:CJProgressHUDPositionBothExist withText:@"网络不在状态!"];

    }];
}

+(void)addNoteWithParams:(NSDictionary *)dic success:(void(^)(NSDictionary *dic))success failure:(void (^)(NSError *error))failure{
    AFHTTPSessionManager *manger = [AFHTTPSessionManager sharedHttpSessionManager];
    [manger POST:API_ADD_NOTE parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(responseObject);
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTE_CHANGE_NOTI object:nil];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
        [CJProgressHUD cjShowErrorWithPosition:CJProgressHUDPositionBothExist withText:@"网络不在状态!"];

    }];
}

+(void)deleteNoteWithParams:(NSDictionary *)dic success:(void(^)(NSDictionary *dic))success failure:(void (^)(NSError *error))failure{
    AFHTTPSessionManager *manger = [AFHTTPSessionManager sharedHttpSessionManager];
    [manger POST:API_DEL_NOTE parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(responseObject);
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTE_CHANGE_NOTI object:nil];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
        [CJProgressHUD cjShowErrorWithPosition:CJProgressHUDPositionBothExist withText:@"网络不在状态!"];

    }];
}

+(void)deleteNotesWithParams:(NSDictionary *)dic success:(void(^)(NSDictionary *dic))success failure:(void (^)(NSError *error))failure{
    AFHTTPSessionManager *manger = [AFHTTPSessionManager sharedHttpSessionManager];
    [manger POST:API_DEL_NOTES parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(responseObject);
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTE_CHANGE_NOTI object:nil];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
        [CJProgressHUD cjShowErrorWithPosition:CJProgressHUDPositionBothExist withText:@"网络不在状态!"];

    }];
}
+(void)bookDetailWithParams:(NSDictionary *)dic success:(void(^)(NSDictionary *dic))success failure:(void (^)(NSError *error))failure{
    AFHTTPSessionManager *manger = [AFHTTPSessionManager sharedHttpSessionManager];
    [manger POST:API_BOOK_DETAIL parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
        [CJProgressHUD cjShowErrorWithPosition:CJProgressHUDPositionBothExist withText:@"网络不在状态!"];

    }];
}
+(void)getBooksAndNotesWithParams:(NSDictionary *)dic success:(void(^)(NSDictionary *))success failure:(void (^)(NSError *))failure{
    AFHTTPSessionManager *manger = [AFHTTPSessionManager sharedHttpSessionManager];
    [manger POST:API_GET_ALL_BOOKS_AND_NOTES parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
        [CJProgressHUD cjShowErrorWithPosition:CJProgressHUDPositionBothExist withText:@"网络不在状态!"];

    }];
}
+(void)deleteBookWithParams:(NSDictionary *)dic success:(void(^)(NSDictionary *))success failure:(void (^)(NSError *))failure{
    AFHTTPSessionManager *manger = [AFHTTPSessionManager sharedHttpSessionManager];
    [manger POST:API_DEL_BOOK parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(responseObject);
        [[NSNotificationCenter defaultCenter] postNotificationName:BOOK_CHANGE_NOTI object:nil];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
        [CJProgressHUD cjShowErrorWithPosition:CJProgressHUDPositionBothExist withText:@"网络不在状态!"];

    }];
}

+(void)renameBookWithParams:(NSDictionary *)dic success:(void(^)(NSDictionary *))success failure:(void (^)(NSError *))failure{
    AFHTTPSessionManager *manger = [AFHTTPSessionManager sharedHttpSessionManager];
    [manger POST:API_RENAME_BOOK parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(responseObject);
        [[NSNotificationCenter defaultCenter] postNotificationName:BOOK_CHANGE_NOTI object:nil];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
        [CJProgressHUD cjShowErrorWithPosition:CJProgressHUDPositionBothExist withText:@"网络不在状态!"];

    }];
}

+(void)addBookWithParams:(NSDictionary *)dic success:(void(^)(NSDictionary *))success failure:(void (^)(NSError *))failure{
    AFHTTPSessionManager *manger = [AFHTTPSessionManager sharedHttpSessionManager];
    [manger POST:API_ADD_BOOK parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(responseObject);
        [[NSNotificationCenter defaultCenter] postNotificationName:BOOK_CHANGE_NOTI object:nil];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
        [CJProgressHUD cjShowErrorWithPosition:CJProgressHUDPositionBothExist withText:@"网络不在状态!"];

    }];
}
@end
