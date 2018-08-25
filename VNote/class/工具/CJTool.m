//
//  Tool.m
//  VNote
//
//  Created by ccj on 2018/8/4.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import "CJTool.h"
NSString *NoteOrderTypeUp = @"标题↑";
NSString *NoteOrderTypeDown = @"标题↓";

@implementation CJTool

+(void)catchAccountInfo2Preference:(NSDictionary *)dic{
    // 查看当前账号是否在当前存储中
    NSUserDefaults *userD = [NSUserDefaults standardUserDefaults];
    NSMutableArray *arrayM = [NSMutableArray arrayWithArray:[userD objectForKey:ALL_ACCOUNT]];
    if (!arrayM || !arrayM.count) {
        // 来到这说明没有存储过
        NSMutableArray *array = [NSMutableArray arrayWithObject:dic];
        [userD setObject:array forKey:ALL_ACCOUNT];
        [userD synchronize];
        return;
    }
    __block int flag = 0;
    [arrayM enumerateObjectsUsingBlock:^(NSDictionary *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([dic[@"email"] isEqualToString:obj[@"email"]]){
            arrayM[idx] = dic;
            flag = 1;
            *stop = YES;
        }
    }];
    if (flag == 0){
        [arrayM addObject:dic];
    }
    [userD setObject:arrayM forKey:ALL_ACCOUNT];
    [userD synchronize];
    
}

+(void)catchNoteOrder2Plist:(NSString *)noteOrder{
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [path objectAtIndex:0];
    NSString *fileName = [docPath stringByAppendingPathComponent:@"noteOrder.plist"];
    NSLog(@"%@",fileName);
    NSMutableDictionary *d = [NSMutableDictionary dictionaryWithContentsOfFile:fileName];
    if (!d){
        d = [NSMutableDictionary dictionary];
    }
    NSString *key = [CJUser sharedUser].email;
    d[key] = noteOrder;
    [d writeToFile:fileName atomically:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTE_ORDER_CHANGE_NOTI object:nil];
}

+(NSString *)getNoteOrderFromPlist{
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [path objectAtIndex:0];
    NSString *fileName = [docPath stringByAppendingPathComponent:@"noteOrder.plist"];
    NSDictionary *d = [NSDictionary dictionaryWithContentsOfFile:fileName];
    NSString *key = [CJUser sharedUser].email;
    if (![d.allKeys containsObject:key]) return NoteOrderTypeUp;
    return d[key];
}



@end
