//
//  HealthManager.h
//  HealthKitTest
//
//  Created by xiongbiao on 2019/3/31.
//  Copyright © 2019年 xiongbiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <HealthKit/HealthKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HealthManager : NSObject
@property (nonatomic) HKHealthStore * healthStore;
@property (nonatomic, readwrite, getter=isAuthorized) BOOL authorized;

+ (HealthManager *)shareHealthManager;
- (void)authorizeHealthKit:(void(^)(BOOL success, NSError *error))compltion;
- (void)getStepCountFrom:(NSString *)startDate endDate:(NSString *)endDate stepCount:(void(^)(double value, NSError *error))completion;
- (void)getSleepAnalysisFrom:(NSString *)startDate endDate:(NSString *)endDate sleepAnalysis:(void(^)(double value, NSError *error))completion;
- (void)getWalkingDistanceFrom:(NSString *)startDate endDate:(NSString *)endDate walkingDistance:(void(^)(double value, NSError *error))completion;
- (void)getEnergyFrom:(NSString *)startDate endDate:(NSString *)endDate energyBurned:(void(^)(double value, NSError *error))completion;
- (void)getHeartRateFrom:(NSString *)startDate endDate:(NSString *)endDate heartRate:(void(^)(int minValue, int maxValue, NSError *error))completion;
@end

NS_ASSUME_NONNULL_END
