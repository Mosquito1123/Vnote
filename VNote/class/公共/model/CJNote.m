//
//  CJBook.m
//  VNote
//
//  Created by ccj on 2018/6/3.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import "CJNote.h"
#import "CJBook.h"
@implementation CJNote
+(instancetype)noteWithDict:(NSDictionary *)dic{
    
    CJNote *note = [[CJNote alloc]init];
    note.book_uuid = dic[@"book_uuid"];
    note.created_at = dic[@"created_at"];
    note.updated_at = dic[@"updated_at"];
    note.title = dic[@"title"];
    note.tags = dic[@"tags"];
    note.uuid = dic[@"uuid"];
    return note;
}
@end
