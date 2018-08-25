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
+(void)catchNoteOrder2Plist:(NSString *)noteOrder;
+(NSString *)getNoteOrderFromPlist;

@end
