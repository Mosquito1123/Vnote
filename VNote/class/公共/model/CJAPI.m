//
//  CJAPI.m
//  VNote
//
//  Created by ccj on 2018/8/19.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import "CJAPI.h"

@implementation CJAPI{
    
}

+(void)requestWithAPI:(NSString *)api params:(NSDictionary *)params success:(void (^)(NSDictionary *))success failure:(void (^)(NSDictionary *))failure error:(void (^)(NSError *error))err{
    AFHTTPSessionManager *manger = [AFHTTPSessionManager sharedHttpSessionManager];
    [manger POST:api parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, NSDictionary *_Nullable dic) {
        if (![[dic allKeys] containsObject:@"status"]){
            [CJProgressHUD cjShowErrorWithPosition:CJProgressHUDPositionBothExist withText:@"参数错误!"];
            return ;
        }
        if ([dic[@"status"] integerValue] != 0){
            failure(dic);
            return;
        }
        // 来到这说明成功
        NSArray *normalApis = @[API_GET_BIND_EMAIL_CODE,API_REGISTER_TOURIST,API_GET_NOTICES,API_GET_ALL_BOOKS_AND_NOTES,API_BOOK_DETAIL,API_SAVE_NOTE,API_GET_CODE,API_CANCEL_FOCUSED,API_FOCUS_USER,API_SEARCH_USERS,API_PEN_FRIENDS,API_SHARE_NOTE,API_UPLOAD_AVTAR,API_SEARCH_NOTE,API_GET_TRASH_NOTES,API_CLEAR_TRASH,API_DEL_NOTE_4ERVER,API_RECENT_NOTES,API_CHANGE_CODE_STYLE,API_GET_ALL_TAGS,API_CHANGE_SEX,API_CHANGE_INTRODUCTION,API_FOLLOWS,API_CHANGE_NICKNAME];
        if ([api isEqualToString:API_BIND_EMAIL]){
            [CJUser userWithDict:dic];
            [CJTool deleteAccountInfoFromPrefrenceByNickname:[CJUser sharedUser].nickname];
            [CJTool catchAccountInfo2Preference:dic];
            [[NSNotificationCenter defaultCenter]postNotificationName:LOGIN_ACCOUT_NOTI object:nil];
            success(dic);
        }else if ([api isEqualToString:API_ADD_BOOK] || [api isEqualToString:API_RENAME_BOOK] || [api isEqualToString:API_DEL_BOOK]){
            success(dic);
            [[NSNotificationCenter defaultCenter] postNotificationName:BOOK_CHANGE_NOTI object:nil];
        }else if ([api isEqualToString:API_DEL_NOTES] || [api isEqualToString:API_DEL_NOTE] || [api isEqualToString:API_ADD_NOTE] || [api isEqualToString:API_MOVE_NOTES] || [api isEqualToString:API_MOVE_NOTE]){
            success(dic);
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTE_CHANGE_NOTI object:nil];
        }else if ([api isEqualToString:API_LOGIN] || [api isEqualToString:API_REGISTER]){
            [CJUser userWithDict:dic];
            [CJTool catchAccountInfo2Preference:dic];
            [[NSNotificationCenter defaultCenter]postNotificationName:LOGIN_ACCOUT_NOTI object:nil];
            success(dic);
        }else if ([normalApis containsObject:api]){
            success(dic);
        }else{
            
            [CJProgressHUD cjShowErrorWithPosition:CJProgressHUDPositionBothExist withText:@"参数错误!"];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (err){
            err(error);
        }
        
    }];
}

@end
