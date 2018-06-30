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
#import "CJFetchData.h"
#import "CJSingleton.h"
#import "CJUser.h"
#import "YYWebImage.h"
#define MainColor CJColorFromHex(0x3b4559)
#define HeadFontColor CJColorFromHex(0x6c6d71)
#define MainBg CJColorFromHex(0xefeff3)

#define BlueBg CJColorFromHex(0x127abd)


#define HOST @"http://127.0.0.1:5000"
// API
#define API_GET_ALL_BOOKS [NSString stringWithFormat:@"%@%@", HOST, @"/VNote/get_all_books/"]
#define API_GET_ALL_TAGS [NSString stringWithFormat:@"%@%@", HOST, @"/VNote/get_all_tags/"]
#define API_BOOK_DETAIL [NSString stringWithFormat:@"%@%@", HOST, @"/VNote/book_detail/"]
#define API_LOGIN [NSString stringWithFormat:@"%@%@", HOST, @"/VNote/login/"]
#define API_NOTE_DETAIL(uuid) [NSString stringWithFormat:@"%@%@%@", HOST, @"/VNote/note_detail/",uuid]
#define API_DEL_BOOK [NSString stringWithFormat:@"%@%@", HOST, @"/VNote/delete_book/"]
#define API_RENAME_BOOK [NSString stringWithFormat:@"%@%@", HOST, @"/VNote/rename_book/"]
#define IMG_URL(str) [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",HOST,str]]
#define API_PEN_FRIENDS [NSString stringWithFormat:@"%@%@", HOST, @"/VNote/pen_friends/"]

#endif /* CJConfig_h */


