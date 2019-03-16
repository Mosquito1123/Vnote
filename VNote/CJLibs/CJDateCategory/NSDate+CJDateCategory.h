//
//  NSDate+CJDateCategory.h
//  sliderViewcontroller
//
//  Created by ccj on 2017/1/13.
//  Copyright © 2017年 ccj. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (CJDateComponents)

/**将时间NSDate拿到年月日的具体信息，默认是以公历计算*/
@property(nonatomic,strong) NSDateComponents *cjDateComponents;

/**拿到某年某月的天数*/
@property(nonatomic,assign) NSUInteger cjDaysInMonth;

/**拿到某年的天数*/
@property(nonatomic,assign) NSUInteger cjDaysInYear;

/**拿到某年某月的第一天星期几*/
@property(nonatomic,assign)NSUInteger cjFirstWeekdayInMonth;


/**function:拿到具体时间的一天是星期几 */
@property(nonatomic,assign)NSUInteger cjWeekday;

+(NSString *)cjDateSince1970WithSecs:(id)secs formatter:(NSString *)formatter;

@end
