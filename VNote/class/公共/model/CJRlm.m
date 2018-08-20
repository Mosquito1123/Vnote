//
//  CJRlm.m
//  VNote
//
//  Created by ccj on 2018/7/22.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import "CJRlm.h"

@implementation CJRlm
+(RLMRealm *)cjRlmWithName:(NSString *)name{
    NSString *realmName;
    if ([name containsString:@"@"]){
        NSRange range = [name rangeOfString:@"@"];
        realmName = [name substringWithRange:NSMakeRange(0, range.location)];
        
    }else{
        realmName = name;
    }
    [CJRlm mkdirWithName:realmName];
    RLMRealmConfiguration *config = [RLMRealmConfiguration defaultConfiguration];
    config.fileURL = [[[config.fileURL URLByDeletingLastPathComponent] URLByAppendingPathComponent:realmName] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.realm",realmName]];
    RLMRealm *rlm = [RLMRealm realmWithConfiguration:config error:nil];
    return rlm;
}

+(void)mkdirWithName:(NSString *)name{
    NSString * docsdir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *dataFilePath = [docsdir stringByAppendingPathComponent:name];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    BOOL isDir = NO;
    
    // fileExistsAtPath 判断一个文件或目录是否有效，isDirectory判断是否一个目录
    BOOL existed = [fileManager fileExistsAtPath:dataFilePath isDirectory:&isDir];
    
    if (!(isDir && existed)) {
        // 在Document目录下创建一个archiver目录
        [fileManager createDirectoryAtPath:dataFilePath withIntermediateDirectories:YES attributes:nil error:nil];
    }

}

+(RLMRealm *)shareRlm{
    CJUser *user = [CJUser sharedUser];
    RLMRealm *rlm = [CJRlm cjRlmWithName:user.email];
    return rlm;
}

+(void)deleteObject:(RLMObject *)obj{
    RLMRealm *rlm = [CJRlm shareRlm];
    [rlm beginWriteTransaction];
    [rlm deleteObject:obj];
    [rlm commitWriteTransaction];
}

+(void)deleteObjects:(id<NSFastEnumeration>)objects{
    RLMRealm *rlm = [CJRlm shareRlm];
    [rlm beginWriteTransaction];
    [rlm deleteObjects:objects];
    [rlm commitWriteTransaction];
}
+(void)addObject:(RLMObject *)obj{
    RLMRealm *rlm = [CJRlm shareRlm];
    [rlm beginWriteTransaction];
    [rlm addObject:obj];
    [rlm commitWriteTransaction];
}

+(void)addObjects:(id<NSFastEnumeration>)objects{
    RLMRealm *rlm = [CJRlm shareRlm];
    [rlm beginWriteTransaction];
    [rlm addObjects:objects];
    [rlm commitWriteTransaction];
}

@end






