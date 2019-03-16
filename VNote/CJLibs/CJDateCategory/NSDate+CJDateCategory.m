//
//  NSDate+CJDateCategory.m
//  sliderViewcontroller
//
//  Created by ccj on 2017/1/13.
//  Copyright © 2017年 ccj. All rights reserved.
//

#import "NSDate+CJDateCategory.h"

@implementation NSDate (CJDateComponents)
@dynamic cjDaysInYear;
@dynamic cjDaysInMonth;
@dynamic cjDateComponents;
@dynamic cjFirstWeekdayInMonth;
@dynamic cjWeekday;
/*
 NSCalendarIdentifier:需要使用的日历算法
 NSCalendarIdentifierGregorian -- 公历
 NSCalendarIdentifierBuddhist -- 佛教日历
 NSCalendarIdentifierChinese -- 中国农历
 NSCalendarIdentifierHebrew -- 希伯来日历
 NSCalendarIdentifierIslamic -- 伊斯兰历
 NSCalendarIdentifierIslamicCivil -- 伊斯兰教日历
 NSCalendarIdentifierJapanese -- 日本日历
 NSCalendarIdentifierRepublicOfChina -- 中华民国日历（台湾）
 NSCalendarIdentifierPersian -- 波斯历
 NSCalendarIdentifierIndian -- 印度日历
 NSCalendarIdentifierISO8601 -- ISO8601
 
 
 
 NSCalendarUnit:需要拿到的数据
 NSCalendarUnitEra -- 纪元单位。对于NSGregorianCalendar(公历)来说，只有公元前(BC)和公元(AD)；而对于其它历法可能有很多，例如日本和历是以每一代君王统治来做计算。
 NSCalendarUnitYear -- 年单位。值很大，相当于经历了多少年，未来多少年。
 NSCalendarUnitMonth -- 月单位。范围为1-12
 NSCalendarUnitDay -- 天单位。范围为1-31
 NSCalendarUnitHour -- 小时单位。范围为0-24
 NSCalendarUnitMinute -- 分钟单位。范围为0-60
 NSCalendarUnitSecond -- 秒单位。范围为0-60
 NSCalendarUnitWeekday -- 星期单位，每周的7天。范围为1-7
 NSCalendarUnitWeekdayOrdinal -- 没完全搞清楚
 NSCalendarUnitQuarter -- 几刻钟，也就是15分钟。范围为1-4
 NSCalendarUnitWeekOfMonth -- 月包含的周数。最多为6个周
 NSCalendarUnitWeekOfYear -- 年包含的周数。最多为53个周
 NSCalendarUnitYearForWeekOfYear -- 没完全搞清楚
 NSCalendarUnitTimeZone -- 没完全搞清楚
 */

-(NSDateComponents *)cjDateComponents
{
   
    NSCalendar *greCal=[[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    return [greCal components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitWeekday | NSCalendarUnitWeekOfMonth | NSCalendarUnitWeekOfYear fromDate:self];
    
}


-(NSUInteger)cjDaysInMonth
{
    NSCalendar *greCal=[[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSRange range=[greCal rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:self];
    return range.length;
}

-(NSUInteger)cjDaysInYear
{
    NSCalendar *greCal=[[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSRange range=[greCal rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitYear forDate:self];
    return range.length;
}

-(NSUInteger)cjFirstWeekdayInMonth
{
    NSCalendar *greCal=[[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *dateComponents=[greCal components:NSCalendarUnitYear | NSCalendarUnitMonth fromDate:self];
    
    NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];//设定时间格式,这里可以设置成自己需要的格式
    NSDate *date =[dateFormat dateFromString:[NSString stringWithFormat:@"%ld-%ld-01",dateComponents.year,dateComponents.month]];
    return [greCal component:NSCalendarUnitWeekday fromDate:date];
    
}

-(NSUInteger)cjWeekday
{
    NSCalendar *greCal=[[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    return [greCal component:NSCalendarUnitWeekday fromDate:self];
}


+(NSString *)cjDateSince1970WithSecs:(NSString *)secs formatter:(NSString *)formatter{
    
    NSDate *date;
    NSDateFormatter *dateformatter=[[NSDateFormatter alloc]init];
    date = [NSDate dateWithTimeIntervalSince1970:[secs integerValue]];
    [dateformatter setDateFormat:formatter];
    return [dateformatter stringFromDate:date];
}
@end
