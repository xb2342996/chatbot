//
//  TimeUtil.m
//  RelaxBot
//
//  Created by xiongbiao on 2019/3/18.
//  Copyright © 2019年 xiongbiao. All rights reserved.
//

#import "TimeUtil.h"



@implementation TimeUtil

+ (NSDateFormatter *)dateFormatter{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    return formatter;
}
+ (NSString *)currentDate{
    NSDateFormatter *formatter = [self dateFormatter];
    NSString *dateString = [formatter stringFromDate:[NSDate date]];
    return dateString;
}
+ (NSString *)musicTimeConverter:(NSTimeInterval)timeInterval
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"mm:ss";
    NSString *timeString = [formatter stringFromDate:date];
    return timeString;
}

+ (NSString *)compareDate:(NSString *)date{
    NSDateFormatter *formatter = [self dateFormatter];
    NSDate *currentDate = [NSDate date];
    NSDate *previousDate = [formatter dateFromString:date];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSCalendarUnit unit = [self calenderUnit];
    NSDateComponents *previousCp = [calendar components:unit fromDate:previousDate];
    NSDateComponents *currentCp = [calendar components:unit fromDate:currentDate];
    long year = currentCp.year - previousCp.year;
    long month = currentCp.month - previousCp.month;
    long day = currentCp.day - previousCp.day;
    NSString *timeString = @"";
    if (year == 0 && month == 0 && day == 0 ){
//        NSLog(@"时间");
        formatter.dateFormat = @"HH:mm";
        timeString = [formatter stringFromDate:previousDate];
    }else if (year == 0 && month == 0 && day == 1 ){
//        NSLog(@"昨天时间");
        formatter.dateFormat = @"HH:mm";
        timeString = [formatter stringFromDate:previousDate];
        timeString = [NSString stringWithFormat:@"Yesterday %@", timeString];
    }else if (year == 0 && month == 0 && day > 1 && day < 7){
//        NSLog(@"带星期的时间");
        formatter.dateFormat = @"eeee HH:mm";
        timeString = [formatter stringFromDate:previousDate];
    }else{
//        NSLog(@"带年份的时间");
        formatter.dateFormat = @"yyyy-MM-dd HH:mm";
        timeString = [formatter stringFromDate:previousDate];
    }
//    NSLog(@"%@", timeString);
    return timeString;
}
+ (NSCalendarUnit)calenderUnit{
    NSCalendarUnit unit = NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond|NSCalendarUnitMonth|NSCalendarUnitYear;
    return unit;
}
+ (BOOL)showTimeBetweenFromDate:(NSString *)fromDate toDate:(NSString *)toDate{
    NSDateFormatter *formatter = [self dateFormatter];
    NSDate *from = [formatter dateFromString:fromDate];
    NSDate *to = [formatter dateFromString:toDate];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSCalendarUnit unit = [self calenderUnit];
    NSDateComponents *previousCp = [calendar components:unit fromDate:from];
    NSDateComponents *currentCp = [calendar components:unit fromDate:to];
    long year = currentCp.year - previousCp.year;
    long month = currentCp.month - previousCp.month;
    long day = currentCp.day - previousCp.day;
    long hour = currentCp.hour - previousCp.hour;
    long minute = currentCp.minute - previousCp.minute;
    BOOL showTime = YES;
    if (year == 0 && month == 0 && day == 0 && hour == 0 && minute < 5){
        showTime = NO;
    }
    return showTime;
}
@end
