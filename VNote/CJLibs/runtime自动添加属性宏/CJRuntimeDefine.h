//
//  CJRuntimeDefine.h
//  百思不得姐
//
//  Created by ccj on 2017/5/15.
//  Copyright © 2017年 ccj. All rights reserved.
//

#ifndef CJRuntimeDefine_h
#define CJRuntimeDefine_h


#pragma -mark 动态生成分类的C属性
/**
 
 需要导入头文件: #import <objc/runtime.h>
 *******************************************************************************
 示例代码:
    @interface NSObject (MyAdd)
    @property (nonatomic, retain) CGPoint myPoint;
    @end
 
    #import <objc/runtime.h>
    @implementation NSObject (MyAdd)
    CJ_PROPERTY_CTYPE(myPoint, setMyPoint, CGPoint)
    @end
 */
#define CJ_DYNAMIC_PROPERTY_CTYPE(_getter_, _setter_, _type_) \
- (void)_setter_ : (_type_)object { \
    [self willChangeValueForKey:@#_getter_]; \
    NSValue *value = [NSValue value:&object withObjCType:@encode(_type_)]; \
    objc_setAssociatedObject(self, _cmd, value, OBJC_ASSOCIATION_RETAIN); \
    [self didChangeValueForKey:@#_getter_]; \
} \
- (_type_)_getter_ { \
    _type_ cValue = { 0 }; \
    NSValue *value = objc_getAssociatedObject(self, @selector(_setter_:)); \
    [value getValue:&cValue]; \
    return cValue; \
}

#pragma -mark 动态生成分类的对象属性
/**
 参数: _association_  ASSIGN / RETAIN / COPY / RETAIN_NONATOMIC / COPY_NONATOMIC
 需要导入头文件: #import <objc/runtime.h>
 *******************************************************************************
 示例代码:
    @interface NSObject (MyAdd)
    @property (nonatomic, retain) UIColor *myColor;
    @end
 
    #import <objc/runtime.h>
    @implementation NSObject (MyAdd)
    CJ_DYNAMIC_PROPERTY_OBJECT(myColor, setMyColor, RETAIN, UIColor *)
    @end
 注意：下面的_cmd实际就是set方法名
 */
#define CJ_DYNAMIC_PROPERTY_OBJECT(_getter_, _setter_, _association_, _type_) \
- (void)_setter_ : (_type_)object { \
    [self willChangeValueForKey:@#_getter_]; \
    objc_setAssociatedObject(self, cmd, object, OBJC_ASSOCIATION_ ## _association_); \
    [self didChangeValueForKey:@#_getter_]; \
} \
- (_type_)_getter_ { \
    return objc_getAssociatedObject(self, @selector(_setter_:)); \
}


#endif /* CJRuntimeDefine_h */
