//
//  NSDateFormatter+CJDateFormatterCategory.h
//  sliderViewcontroller
//
//  Created by ccj on 2017/1/13.
//  Copyright © 2017年 ccj. All rights reserved.
//

#import <Foundation/Foundation.h>


/*
 a:    AM/PM
 A:    0~86399999 (Millisecond of Day)
 
 c/cc:    1~7 (Day of Week)
 ccc:    Sun/Mon/Tue/Wed/Thu/Fri/Sat
 cccc: Sunday/Monday/Tuesday/Wednesday/Thursday/Friday/Saturday
 
 d/dd:    天(月中的天),1~31/01~31
 D:    天(年中的天),1~366
 
 e:    1~7 (0 padded Day of Week)
 E~EEE:    Sun/Mon/Tue/Wed/Thu/Fri/Sat
 EEEE: Sunday/Monday/Tuesday/Wednesday/Thursday/Friday/Saturday
 
 F:    1~5 (0 padded Week of Month, first day of week = Monday)
 
 g:    Julian Day Number (number of days since 4713 BC January 1)
 G~GGG:    BC/AD (Era Designator Abbreviated)
 GGGG:    Before Christ/Anno Domini
 
 h/hh:   时,1~12/01~12
 H/HH:   时,0~23/00~23
 
 k/kk:   时,1~24/01~24
 K:    时,0~11/00~11
 
 L/LL:    月,1~12 (0 padded Month)
 LLL:    月,Jan/Feb/Mar/Apr/May/Jun/Jul/Aug/Sep/Oct/Nov/Dec
 LLLL:  月,January/February/March/April/May/June/July/August/September/October/November/December
 
 m/mm:   分,0~59/00~59
 MM:     月
 MMM:    简写Jan
 MMMM: 全称January
 
 
 
 s/ss:    秒,0~59/00~59
 S/SS/SSS:    毫秒,0~999/00~999/000~9999
 
 u:    (0 padded Year)
 
 v~vvv:    (General GMT Timezone Abbreviation)
 vvvv:    (General GMT Timezone Name)
 
 w:    1~53 (0 padded Week of Year, 1st day of week = Sunday, NB: 1st week of year starts from the last Sunday of last year)
 W:    1~5 (0 padded Week of Month, 1st day of week = Sunday)
 
 y/yyyy:    完整的年
 yy/yyy:    年的后2位
 
 
 z~zzz:    (Specific GMT Timezone Abbreviation)
 zzzz:    (Specific GMT Timezone Name)
 Z:    +0000 (RFC 822 Timezone)
 */


typedef NSString * CJDateFormatterIdentifier NS_EXTENSIBLE_STRING_ENUM;

/**常用的格式*/
FOUNDATION_EXPORT  CJDateFormatterIdentifier const cjFullTimeFormatter;
FOUNDATION_EXPORT  CJDateFormatterIdentifier const cjFullTimeNoMsecFormatter;
FOUNDATION_EXPORT  CJDateFormatterIdentifier const cjYearMonthDayFormatter;
FOUNDATION_EXPORT  CJDateFormatterIdentifier const cjHourMinSecMsecFormatter;
FOUNDATION_EXPORT  CJDateFormatterIdentifier const cjHourMinSecFormatter;

@interface NSDateFormatter (CJDateStringSwap)
+(NSDate *)cjStringToDateByString:(NSString *)string  formatter:(CJDateFormatterIdentifier )dateFormatter;

+(NSString *)cjDateToStringByDate:(NSDate *)date formatter:(CJDateFormatterIdentifier )dateFormatter;
@end

