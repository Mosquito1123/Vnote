//
//  CJConfig.h
//  VNote
//
//  Created by ccj on 2018/6/2.
//  Copyright © 2018年 ccj. All rights reserved.
//

#ifndef CJConfig_h
#define CJConfig_h
#import "CJGlobal.h"
#import "UIView+CJViewExtension.h"
#import "MJRefresh.h"
#define MainColor CJColorFromHex(0x3b4559)
#define HeadFontColor CJColorFromHex(0x6c6d71)
#define MainBg CJColorFromHex(0xefeff3)


#define HOST @"http://127.0.0.1:5000"
// API
#define API_GET_ALL_BOOKS [NSString stringWithFormat:@"%@%@", HOST, @"/VNote/get_all_books/"]
#define API_GET_ALL_TAGS [NSString stringWithFormat:@"%@%@", HOST, @"/VNote/get_all_tags/"]
#define API_BOOK_DETAIL [NSString stringWithFormat:@"%@%@", HOST, @"/VNote/book_detail/"]
#define API_LOGIN [NSString stringWithFormat:@"%@%@", HOST, @"/VNote/login/"]
#define API_NOTE_DETAIL(uuid) [NSString stringWithFormat:@"%@%@%@", HOST, @"/VNote/note_detail/",uuid]
#endif /* CJConfig_h */
