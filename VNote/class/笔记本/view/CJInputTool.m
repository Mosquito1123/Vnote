//
//  CJInputTool.m
//  VNote
//
//  Created by ccj on 2019/5/14.
//  Copyright © 2019 ccj. All rights reserved.
//

#import "CJInputTool.h"

@implementation CJInputTool

+(instancetype)xibWithInputTool{
    CJInputTool *v = [[[NSBundle mainBundle]loadNibNamed:@"CJInputTool" owner:nil options:nil]lastObject];
    return v;
}
@end
