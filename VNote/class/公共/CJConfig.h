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
#import "CJTool.h"
#import "CJDropViewCell.h"
#import "CJBaseTableVC.h"
#import <FDFullscreenPopGesture/UINavigationController+FDFullscreenPopGesture.h>
#import "CJSearchBar.h"
#import "CJPenFriend.h"
#import "CJMainNaVC.h"
#import "CJLeftXViewController.h"
#import "UIControl+CJCategory.h"
#import "AFHTTPSessionManager+AFHttpSessionCategory.h"
#import "CJAPI.h"
#import "CJSlideViewController.h"

#define HeadFontColor CJColorFromHex(0x6c6d71)
#define MainBg CJColorFromHex(0xefeff3)// 背景色
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
#define API_NOTE_DETAIL(uuid) [NSString stringWithFormat:@"%@%@%@/", HOST, @"/VNote/note_detail/",uuid]
#define API_DEL_BOOK [NSString stringWithFormat:@"%@%@", HOST, @"/VNote/delete_book/"]
#define API_RENAME_BOOK [NSString stringWithFormat:@"%@%@", HOST, @"/VNote/rename_book/"]
#define IMG_URL(str) [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",HOST,str]]
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
#define API_DEL_NOTE [NSString stringWithFormat:@"%@%@", HOST, @"/VNote/delete_note/"]
#define API_DEL_NOTES [NSString stringWithFormat:@"%@%@", HOST, @"/VNote/delete_notes/"]
#define API_MOVE_NOTE [NSString stringWithFormat:@"%@%@", HOST, @"/VNote/move_note/"]
#define API_MOVE_NOTES [NSString stringWithFormat:@"%@%@", HOST, @"/VNote/move_notes/"]
#define API_SAVE_NOTE [NSString stringWithFormat:@"%@%@", HOST, @"/VNote/save_note/"]
#define API_RECENT_NOTES [NSString stringWithFormat:@"%@%@", HOST, @"/VNote/recent_notes/"]
#define API_GET_TRASH_NOTES [NSString stringWithFormat:@"%@%@", HOST, @"/VNote/trash_notes/"]
#define API_SEARCH_NOTE [NSString stringWithFormat:@"%@%@", HOST, @"/VNote/search_note/"]
#define API_DEL_NOTE_4ERVER [NSString stringWithFormat:@"%@%@", HOST, @"/VNote/delete_note_4erver/"]
#define API_CHANGE_CODE_STYLE [NSString stringWithFormat:@"%@%@", HOST, @"/VNote/change_code_style/"]
#define API_CHANGE_SEX [NSString stringWithFormat:@"%@%@", HOST, @"/VNote/change_sex/"]
#define API_CHANGE_INTRODUCTION [NSString stringWithFormat:@"%@%@", HOST, @"/VNote/change_introduction/"]
#define API_FOLLOWS [NSString stringWithFormat:@"%@%@", HOST, @"/VNote/follows/"]
#define API_CHANGE_NICKNAME [NSString stringWithFormat:@"%@%@", HOST, @"/VNote/change_nickname/"]

#define LOGIN_ACCOUT_NOTI @"LOGIN_ACCOUT_NOTI"
#define ACCOUNT_NUM_CHANGE_NOTI @"ACCOUNT_NUM_CHANGE_NOTI"
#define AVTAR_CLICK_NOTI @"AVTAR_CLICK_NOTI"

#define NOTE_CHANGE_NOTI @"NOTE_CHANGE_NOTI"
#define BOOK_CHANGE_NOTI @"BOOK_CHANGE_NOTI"
#define NOTE_ORDER_CHANGE_NOTI @"NOTE_ORDER_CHANGE_NOTI"


// 偏好设置key
#define ALL_ACCOUNT @"ALL_ACCOUNT"
#define SEARCH_RECORD @"SEARCH_RECORD"



#endif /* CJConfig_h */


