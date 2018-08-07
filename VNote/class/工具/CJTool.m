//
//  Tool.m
//  VNote
//
//  Created by ccj on 2018/8/4.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import "CJTool.h"

@implementation CJTool
CJSingletonM(Tool)

-(void)catchAccountInfo2Preference:(NSDictionary *)dic{
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
@end
