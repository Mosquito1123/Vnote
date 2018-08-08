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
#import "CJSingleton.h"
#import "CJUser.h"
#import <YYWebImage.h>
#import <AFNetworking.h>
#import <MJRefresh.h>
#import <Realm.h>
#import "CJProgressHUD.h"
#import "UIBarButtonItem+CJCategory.h"
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>
#import "CJTableView.h"
#import <Masonry.h>
#import "CJRefreshGif.h"
#import "CJTabBar.h"
#import "CJRlm.h"
#import "CJTextView.h"
#import "CJBook.h"
#import "CJNote.h"
#import "CJBaseVC.h"
#import "CJTag.h"
#import "DBHWindow.h"
#import "CJTool.h"
#import "CJDropView.h"
#import "CJDropViewCell.h"
#import <FDFullscreenPopGesture/UINavigationController+FDFullscreenPopGesture.h>
#define MainColor CJColorFromHex(0x3b4559)
#define HeadFontColor CJColorFromHex(0x6c6d71)
#define MainBg CJColorFromHex(0xefeff3)
#define SelectCellBg CJColorFromHex(0x054363)
#define BlueBg CJColorFromHex(0x127abd)
#define BUG 0

#if BUG
    #define HOST @"http://127.0.0.1:5000"
#else
    #define HOST @"http://60.205.219.56:5000"
#endif
// API
#define API_GET_ALL_BOOKS_AND_NOTES [NSString stringWithFormat:@"%@%@", HOST, @"/VNote/get_all_books_and_notes/"]
#define API_GET_ALL_BOOKS [NSString stringWithFormat:@"%@%@", HOST, @"/VNote/get_all_books/"]
#define API_GET_ALL_TAGS [NSString stringWithFormat:@"%@%@", HOST, @"/VNote/get_all_tags/"]
#define API_BOOK_DETAIL [NSString stringWithFormat:@"%@%@", HOST, @"/VNote/book_detail/"]
#define API_LOGIN [NSString stringWithFormat:@"%@%@", HOST, @"/VNote/login/"]
#define API_NOTE_DETAIL(uuid) [NSString stringWithFormat:@"%@%@%@", HOST, @"/VNote/note_detail/",uuid]
#define API_DEL_BOOK [NSString stringWithFormat:@"%@%@", HOST, @"/VNote/delete_book/"]
#define API_RENAME_BOOK [NSString stringWithFormat:@"%@%@", HOST, @"/VNote/rename_book/"]
#define IMG_URL(str) [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",HOST,str]]
#define API_PEN_FRIENDS [NSString stringWithFormat:@"%@%@", HOST, @"/VNote/pen_friends/"]
#define API_CANCEL_FOCUSED [NSString stringWithFormat:@"%@%@", HOST, @"/VNote/cancel_focused/"]
#define API_SEARCH_USERS [NSString stringWithFormat:@"%@%@", HOST, @"/VNote/search_user/"]
#define API_FOCUS_USER [NSString stringWithFormat:@"%@%@", HOST, @"/VNote/focus_user/"]
#define API_SHARE_NOTE [NSString stringWithFormat:@"%@%@", HOST, @"/VNote/share_note/"]
#define API_UPLOAD_AVTAR [NSString stringWithFormat:@"%@%@", HOST, @"/VNote/upload_avtar/"]
#define API_CLEAR_TRASH [NSString stringWithFormat:@"%@%@", HOST, @"/VNote/clear_trash/"]
#define API_GET_CODE [NSString stringWithFormat:@"%@%@", HOST, @"/VNote/get_code/"]
#define API_REGISTER [NSString stringWithFormat:@"%@%@", HOST, @"/VNote/register/"]
#define API_ADD_BOOK [NSString stringWithFormat:@"%@%@", HOST, @"/VNote/add_book/"]
#define API_ADD_NOTE [NSString stringWithFormat:@"%@%@", HOST, @"/VNote/add_note/"]

#define API_SAVE_NOTE [NSString stringWithFormat:@"%@%@", HOST, @"/VNote/save_note/"]
#define API_RECENT_NOTES [NSString stringWithFormat:@"%@%@", HOST, @"/VNote/recent_notes/"]
#define API_GET_TRASH_NOTES [NSString stringWithFormat:@"%@%@", HOST, @"/VNote/trash_notes/"]
// 切换账号的通知
#define CHANGE_ACCOUNT_NOTI @"changeAccountNoti"
#define LOGIN_ACCOUT_NOTI @"loginAccountNoti"
#define ACCOUNT_NUM_CHANGE_NOTI @"accountNumChangeNoti"

// 偏好设置key
#define ALL_ACCOUNT @"AllAccount"

#define MAXEXCURSION CJScreenWidth * 0.8
#define LEFTMAXWIDTH CJScreenHeight * 0.2

#endif /* CJConfig_h */


