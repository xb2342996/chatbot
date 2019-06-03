//
//  TimeUtil.h
//  RelaxBot
//
//  Created by xiongbiao on 2019/3/18.
//  Copyright © 2019年 xiongbiao. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TimeUtil : NSObject

+ (NSString *)musicTimeConverter:(NSTimeInterval)timeInterval;
+ (NSString *)currentDate;
+ (NSString *)compareDate:(NSString *)date;
+ (BOOL)showTimeBetweenFromDate:(NSString *)fromDate toDate:(NSString *)toDate;
@end

NS_ASSUME_NONNULL_END
