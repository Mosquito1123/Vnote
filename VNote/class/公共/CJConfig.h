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
#import "CJRLMObject.h"
#import "CJTextView.h"
#import "CJBook.h"
#import "CJNote.h"
#import "CJBaseVC.h"
#import "CJTag.h"
#import "CJTool.h"
#import "CJDropViewCell.h"
#import <FDFullscreenPopGesture/UINavigationController+FDFullscreenPopGesture.h>
#import "CJSearchBar.h"
#import "CJPenFriend.h"
#import "CJMainNaVC.h"
#import "CJLeftXViewController.h"
#import "UIControl+CJCategory.h"
#import "AFHTTPSessionManager+AFHttpSessionCategory.h"
#import "CJAPI.h"
#import "CJConst.h"
#import "CJAppleSystem.h"
#import "NSDate+CJDateCategory.h"


#define HeadFontColor CJColorFromHex(0x6c6d71)
//#define MainBg CJColorFromHex(0xefeff3)// 背景色
#define MainBg [UIColor whiteColor]
#define SelectCellBg CJColorFromHex(0x054363)
#define BlueBg CJColorFromHex(0x127abd)
#define CopyColor CJColorFromHex(0x449475)
#define BUG 0

#if BUG
    #define HOST @"http://127.0.0.1:5000"
#else
    #define HOST @"https://www.wenote.net.cn"
#endif
#define PRIVACY @"https://www.wenote.net.cn/WeNote/privacy/"

#define QQGROUPID @"797923570"
#define NOTE_DETAIL_WEB_LINK(str) [NSString stringWithFormat:@"%@/WeNote/note_detail/%@", HOST,str]
#define API(str) [NSString stringWithFormat:@"%@/V/VNote/%s/", HOST,str]
// API
#define API_GET_ALL_BOOKS_AND_NOTES API("get_all_books_and_notes")
#define API_GET_ALL_BOOKS API("get_all_books")
#define API_GET_ALL_TAGS API("get_all_tags")
#define API_BOOK_DETAIL API("book_detail")
#define API_LOGIN API("login")
#define API_NOTE_DETAIL(uuid) [NSString stringWithFormat:@"%@/V/VNote/note_detail/%@/", HOST,uuid]
#define API_DEL_BOOK API("delete_book")
#define API_RENAME_BOOK API("rename_book")
#define IMG_URL(str) [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",HOST,str]]
#define API_PEN_FRIENDS API("pen_friends")
#define API_CANCEL_FOCUSED API("cancel_focused")
#define API_SEARCH_USERS API("search_user")
#define API_FOCUS_USER API("focus_user")
#define API_SHARE_NOTE API("share_note")
#define API_UPLOAD_AVTAR API("upload_avtar")
#define API_CLEAR_TRASH API("clear_trash")
#define API_GET_CODE API("get_code")
#define API_REGISTER API("register")
#define API_ADD_BOOK API("add_book")
#define API_ADD_NOTE API("add_note")
#define API_DEL_NOTE API("delete_note")
#define API_DEL_NOTES API("delete_notes")
#define API_MOVE_NOTE API("move_note")
#define API_MOVE_NOTES API("move_notes")
#define API_SAVE_NOTE API("save_note")
#define API_RECENT_NOTES API("recent_notes")
#define API_GET_TRASH_NOTES API("trash_notes")
#define API_SEARCH_NOTE API("search_note")
#define API_DEL_NOTE_4ERVER API("delete_note_4erver")
#define API_CHANGE_CODE_STYLE API("change_code_style")
#define API_CHANGE_SEX API("change_sex")
#define API_CHANGE_INTRODUCTION API("change_introduction")
#define API_FOLLOWS API("follows")
#define API_CHANGE_NICKNAME API("change_nickname")
#define API_GET_NOTICES API("notices")
#define API_REGISTER_TOURIST API("register_with_tourist")
#define API_GET_BIND_EMAIL_CODE API("get_code_bind_email")
#define API_BIND_EMAIL API("bind_email")

#define LOGIN_ACCOUT_NOTI @"LOGIN_ACCOUT_NOTI"
#define ACCOUNT_NUM_CHANGE_NOTI @"ACCOUNT_NUM_CHANGE_NOTI"
#define AVTAR_CLICK_NOTI @"AVTAR_CLICK_NOTI"

#define NOTE_CHANGE_NOTI @"NOTE_CHANGE_NOTI"
#define BOOK_CHANGE_NOTI @"BOOK_CHANGE_NOTI"
#define NOTE_ORDER_CHANGE_NOTI @"NOTE_ORDER_CHANGE_NOTI"
#define PEN_FRIEND_CHANGE_NOTI @"PEN_FRIEND_CHANGE_NOTI"
#define STATUS_FRAME_CHANGE_NOTI @"STATUS_FRAME_CHANGE_NOTI"
#define ROTATE_NOTI @"ROTATE_NOTI"
#define UPLOAD_AVTAR_NOTI @"UPLOAD_AVTAR_NOTI"
#define CHANGE_CLOSE_PEN_FRIENDS_FUNC_NOTI @"CHANGE_CLOSE_PEN_FRIENDS_FUNC_NOTI"

#define STATUSH [UIApplication sharedApplication].statusBarFrame.size.height

#define VERSION [[[NSBundle mainBundle] infoDictionary]objectForKey:@"CFBundleShortVersionString"]

#define IPHONE_X \
({BOOL isPhoneX = NO;\
if (@available(iOS 11.0, *)) {\
isPhoneX = [[UIApplication sharedApplication] delegate].window.safeAreaInsets.bottom > 0.0;\
}\
(isPhoneX);})


// 偏好设置key
#define ALL_ACCOUNT @"ALL_ACCOUNT"
#define SEARCH_RECORD @"SEARCH_RECORD"
#define TIME_OUT 10

#define POST_JS @"function my_post(path, params) {\
var method = \"POST\";\
var form = document.createElement(\"form\");\
form.setAttribute(\"method\", method);\
form.setAttribute(\"action\", path);\
for(var key in params){\
if (params.hasOwnProperty(key)) {\
var hiddenFild = document.createElement(\"input\");\
hiddenFild.setAttribute(\"type\", \"hidden\");\
hiddenFild.setAttribute(\"name\", key);\
hiddenFild.setAttribute(\"value\", params[key]);\
}\
form.appendChild(hiddenFild);\
}\
document.body.appendChild(form);\
form.submit();\
}"


#define APP_ID @"1459104946"
// iOS 11 以下的评价跳转
#define APP_OPEN_EVALUATE [NSString stringWithFormat:@"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@", APP_ID]
// iOS 11 的评价跳转
#define APP_OPEN_EVALUATE_AFTER_IOS11 [NSString stringWithFormat:@"itms-apps://itunes.apple.com/cn/app/id%@?mt=8&action=write-review", APP_ID]

#define ERRORMSG [CJProgressHUD cjShowErrorWithPosition:CJProgressHUDPositionBothExist withText:net101code];

#endif /* CJConfig_h */


