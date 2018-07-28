//
//  CJTextView.m
//  CJ微博
//
//  Created by ccj on 16/2/15.
//  Copyright © 2016年 ccj. All rights reserved.
//

#import "CJTextView.h"

@implementation CJTextView

-(void)awakeFromNib{
    [super awakeFromNib];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textDidChanged) name:UITextViewTextDidChangeNotification object:self];
}

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self=[super initWithFrame:frame]) {
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textDidChanged) name:UITextViewTextDidChangeNotification object:self];
    }
    return self;
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

-(void)textDidChanged
{
    [self setNeedsDisplay];
}

-(void)setPlaceholder:(NSString *)placeholder
{
    _placeholder=[placeholder copy];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    
    if (self.hasText) {
        return;
    }
    NSMutableDictionary *attrs=[[NSMutableDictionary alloc]init];
    attrs[NSFontAttributeName]=self.font;
    attrs[NSForegroundColorAttributeName]=[UIColor grayColor];
    CGRect placeholderRec=CGRectMake(5, 8, self.bounds.size.width-10, self.bounds.size.height-16);
    [self.placeholder drawInRect:placeholderRec withAttributes:attrs];
    
    
}


@end
