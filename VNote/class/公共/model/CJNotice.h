//
//  CJNotice.h
//  VNote
//
//  Created by ccj on 2019/5/18.
//  Copyright © 2019 ccj. All rights reserved.
//

#import "CJRLMObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface CJNotice : CJNote
@property(nonatomic,strong)NSString *blank;
+(instancetype)noticeWithDict:(NSDictionary *)d;
@end

NS_ASSUME_NONNULL_END
