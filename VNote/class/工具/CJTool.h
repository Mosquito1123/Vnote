//
//  Tool.h
//  VNote
//
//  Created by ccj on 2018/8/4.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CJTool : NSObject
-(void)catchAccountInfo2Preference:(NSDictionary *)dic;

CJSingletonH(Tool)
@end
