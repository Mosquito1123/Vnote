//
//  UIControl+CJCategory.m
//  百思不得姐
//
//  Created by ccj on 2017/5/10.
//  Copyright © 2017年 ccj. All rights reserved.
//

#import "UIControl+CJCategory.h"
#import <objc/runtime.h>
@implementation UIControl (didRespondTarget)

static const char *didRespondTargetKey="didRespondTargetKey";


-(void)cjRespondTargetForControlEvents:(UIControlEvents)events actionBlock:(void (^)(UIControl *control))block
{
    
    if(self.dictM==nil)
    {
        self.dictM=[NSMutableDictionary dictionary];
        
    }
    
    SEL sel = NULL;
    
    switch (events)
    {
        case UIControlEventTouchUpInside:
            sel=@selector(touchUpInside:);
            self.dictM[@"UIControlEventTouchUpInside"]=block;
            break;
        case UIControlEventEditingDidBegin:
            sel=@selector(editingDidBegin:);
            self.dictM[@"UIControlEventEditingDidBegin"]=block;
            break;
        case UIControlEventEditingChanged:
            sel=@selector(editingChanged:);
            self.dictM[@"UIControlEventEditingChanged"]=block;
            break;
        case UIControlEventEditingDidEnd:
            sel=@selector(editingDidEnd:);
            self.dictM[@"UIControlEventEditingDidEnd"]=block;
            break;
        case UIControlEventEditingDidEndOnExit:
            sel=@selector(editingDidEndOnExit:);
            self.dictM[@"UIControlEventEditingDidEndOnExit"]=block;
            break;
        default: break;
            
    }
    
    //当前的target就是被响应UIControll本身，让他来到这调用自己的方法buttonClick
    [self addTarget:self action:sel forControlEvents:events];
    
}
-(void)touchUpInside:(UIControl *)control
{
    void (^block)(UIControl *)=self.dictM[@"UIControlEventTouchUpInside"];
    
    if (!block)return;
    block(control);
}

-(void)editingDidBegin:(UIControl *)control
{
    void (^block)(UIControl *)=self.dictM[@"UIControlEventEditingDidBegin"];
    
    block(control);
}

-(void)editingChanged:(UIControl *)control
{
    void (^block)(UIControl *)=self.dictM[@"UIControlEventEditingChanged"];
    
    block(control);
}

-(void)editingDidEnd:(UIControl *)control
{
    void (^block)(UIControl *)=self.dictM[@"UIControlEventEditingDidEnd"];
    
    block(control);
}

-(void)editingDidEndOnExit:(UIControl *)control
{
    void (^block)(UIControl *)=self.dictM[@"UIControlEventEditingDidEndOnExit"];
    
    block(control);
}





-(NSMutableDictionary *)dictM
{
    return objc_getAssociatedObject(self, didRespondTargetKey);
    
}

-(void)setDictM:(NSMutableDictionary *)dictM
{
    objc_setAssociatedObject(self, didRespondTargetKey, dictM, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

}


@end
