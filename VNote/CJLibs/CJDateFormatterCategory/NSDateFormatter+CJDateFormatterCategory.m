//
//  NSDateFormatter+CJDateFormatterCategory.m
//  sliderViewcontroller
//
//  Created by ccj on 2017/1/13.
//  Copyright © 2017年 ccj. All rights reserved.
//

#import "NSDateFormatter+CJDateFormatterCategory.h"
CJDateFormatterIdentifier const cjFullTimeFormatter=@"yyyy-MM-dd HH:mm:ss.SSS";//2017-01-01 14:08:45.789
CJDateFormatterIdentifier const cjFullTimeNoMsecFormatter=@"yyyy-MM-dd HH:mm:ss";
CJDateFormatterIdentifier const cjYearMonthDayFormatter=@"yyyy-MM-dd";
CJDateFormatterIdentifier const cjHourMinSecMsecFormatter=@"HH:mm:ss.SSS";
CJDateFormatterIdentifier const cjHourMinSecFormatter=@"HH:mm:ss";

@implementation NSDateFormatter (CJDateStringSwap)
+(NSDate *)cjStringToDateByString:(NSString *)string  formatter:(CJDateFormatterIdentifier )dateFormatter
{

    NSDateFormatter *formatter=[[self alloc]init];
    [formatter setDateFormat:dateFormatter];
    NSDate *date=[formatter dateFromString:string];
    return date;

}

+(NSString *)cjDateToStringByDate:(NSDate *)date formatter:(CJDateFormatterIdentifier )dateFormatter
{
    NSDateFormatter *formatter=[[self alloc]init];
    [formatter setDateFormat:dateFormatter];
    NSString *str=[formatter stringFromDate:date];
    return str;
}

@end
