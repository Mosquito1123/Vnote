//
//  CJBook.m
//  VNote
//
//  Created by ccj on 2018/6/3.
//  Copyright © 2018年 ccj. All rights reserved.
//

#import "CJNote.h"

@implementation CJNote
+(instancetype)noteWithDict:(NSDictionary *)dic{
    NSData *data;
    CJNote *note = [[CJNote alloc]init];
    note.book_uuid = dic[@"book_uuid"];
    note.content = dic[@"content"];
    note.created_at = dic[@"created_at"];
    note.updated_at = dic[@"updated_at"];
    note.title = dic[@"title"];
    data = [dic[@"tags"] dataUsingEncoding:NSUTF8StringEncoding];
    note.tags =[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    note.book_title = [dic objectForKey:@"book_title"];
    note.uuid = dic[@"uuid"];
    return note;
}
@end
