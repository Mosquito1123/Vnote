//
//  CJPenNoteVC.h
//  VNote
//
//  Created by ccj on 2018/7/22.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CJNote;
@interface CJPenNoteVC : UIViewController
@property(nonatomic,strong) NSMutableArray<CJNote *> *notes;
@property(nonatomic,strong) NSString *bookTitle;
@property(nonatomic,strong) NSString *email;
@property(nonatomic,strong) NSString *book_uuid;
@end
