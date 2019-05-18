//
//  CJNotice.m
//  VNote
//
//  Created by ccj on 2019/5/18.
//  Copyright © 2019 ccj. All rights reserved.
//

#import "CJNotice.h"

@implementation CJNotice
+(instancetype)noticeWithDict:(NSDictionary *)d{
    CJNotice *n = [CJNotice noteWithDict:d];
    n.blank = @"";
    return n;
    
}
@end
