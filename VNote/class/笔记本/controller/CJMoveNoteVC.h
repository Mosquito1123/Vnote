//
//  CJMoveNoteVC.h
//  VNote
//
//  Created by ccj on 2018/8/11.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CJMoveNoteVC : CJBaseVC

@property(nonatomic,strong) NSString *bookTitle;
@property(nonatomic,copy)void (^selectIndexPath)(NSString *book_uuid);
@end
