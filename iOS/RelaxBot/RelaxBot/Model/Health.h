//
//  Health.h
//  RelaxBot
//
//  Created by xiongbiao on 2019/4/14.
//  Copyright © 2019 xiongbiao. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

enum HealthQueryType {
    HealthQueryTypeStepCount = 1,
    HealthQueryTypeWalkingDistance,
    HealthQueryTypeSleepAnalysis,
    HealthQueryTypeEnergyBurned,
    HealthQueryTypeHeartRate,
};

@interface Health : NSObject
@property (copy, nonatomic) NSString *start;
@property (copy, nonatomic) NSString *end;
@property (assign, nonatomic) enum HealthQueryType type;
@end

NS_ASSUME_NONNULL_END
