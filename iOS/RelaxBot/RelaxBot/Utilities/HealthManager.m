//
//  HealthManager.m
//  HealthKitTest
//
//  Created by xiongbiao on 2019/3/31.
//  Copyright © 2019年 xiongbiao. All rights reserved.
//

#import "HealthManager.h"
#import <UIKit/UIDevice.h>

@implementation HealthManager

+ (HealthManager *)shareHealthManager{
    static HealthManager *healthManager = nil;
    static dispatch_once_t onePredicate;
    dispatch_once(&onePredicate, ^{
        healthManager = [[HealthManager alloc]init];
    });
    return healthManager;
}

- (instancetype)init{
    if (self = [super init]) {
        self.healthStore = [[HKHealthStore alloc]init];
    }
    return self;
}

- (void)authorizeHealthKit:(void(^)(BOOL success, NSError *error))compltion
{

    if (![HKHealthStore isHealthDataAvailable]) {
        NSError *error = [NSError errorWithDomain: @"com.raywenderlich.tutorials.healthkit" code: 2 userInfo: [NSDictionary dictionaryWithObject:@"HealthKit is not available in th is Device"                                                                      forKey:NSLocalizedDescriptionKey]];
        if (compltion != nil) {
            compltion(false, error);
        }
        return;
    }
    if ([HKHealthStore isHealthDataAvailable]) {
        if(self.healthStore == nil){
            self.healthStore = [[HKHealthStore alloc] init];
        }
        NSSet *readDataTypes = [self readDataType];
        [self.healthStore requestAuthorizationToShareTypes:nil readTypes:readDataTypes completion:^(BOOL success, NSError *error) {
            
            if (compltion != nil) {
                compltion (success, error);
            }
        }];
    } else {
        compltion(false, nil);
    }
    
}

- (NSSet *)readDataType{
    HKQuantityType *stepCountQuantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    HKQuantityType *walkDistanceQuantityType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning];
    
    HKQuantityType *activeEnergyBurnQuantityType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned];
    HKQuantityType *heartQuantityType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
    HKCategoryType *sleepCategoryType = [HKCategoryType categoryTypeForIdentifier:HKCategoryTypeIdentifierSleepAnalysis];
    
    return [NSSet setWithObjects:stepCountQuantityType, walkDistanceQuantityType, activeEnergyBurnQuantityType, heartQuantityType, sleepCategoryType, nil];
}

+ (NSPredicate *)predicateForSamplesTodayWithStartDate:(NSString *)startDateS endDate:(NSString *)endDateS {
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSDate *startDate = [formatter dateFromString:startDateS];
    NSDate *endDate = [formatter dateFromString:endDateS];
    NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:startDate endDate:endDate options:HKQueryOptionNone];
    NSLog(@"start date: %@", startDate);
    NSLog(@"end date: %@", endDate);
    return predicate;
}

- (void)getStepCountFrom:(NSString *)startDate endDate:(NSString *)endDate stepCount:(void(^)(double value, NSError *error))completion{
    HKSampleType *sampleType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    NSSortDescriptor *start = [NSSortDescriptor sortDescriptorWithKey:HKSampleSortIdentifierStartDate ascending:NO];
    NSSortDescriptor *end = [NSSortDescriptor sortDescriptorWithKey:HKSampleSortIdentifierEndDate ascending:NO];
    
    NSPredicate *predicate = [HealthManager predicateForSamplesTodayWithStartDate:startDate endDate:endDate];
    
    HKSampleQuery *sampleQuery = [[HKSampleQuery alloc]initWithSampleType:sampleType predicate:predicate limit:0 sortDescriptors:@[start,end] resultsHandler:^(HKSampleQuery * _Nonnull query, NSArray<__kindof HKSample *> * _Nullable results, NSError * _Nullable error) {
        
        if (error) {
            completion(0, error);
        }else{
//            NSLog(@"%@", results);
            NSInteger totleSteps = 0;
            for(HKQuantitySample *quantitySample in results)
            {
                HKQuantity *quantity = quantitySample.quantity;
                HKUnit *heightUnit = [HKUnit countUnit];
                double usersHeight = [quantity doubleValueForUnit:heightUnit];
                totleSteps += usersHeight;
            }
            NSLog(@"当天行走步数 = %ld",(long)totleSteps);
            completion(totleSteps, error);
        }
    }];
    [self.healthStore executeQuery:sampleQuery];
}

- (void)getWalkingDistanceFrom:(NSString *)startDate endDate:(NSString *)endDate walkingDistance:(void(^)(double value, NSError *error))completion{
    
    NSSortDescriptor *start = [NSSortDescriptor sortDescriptorWithKey:HKSampleSortIdentifierStartDate ascending:NO];
    NSSortDescriptor *end = [NSSortDescriptor sortDescriptorWithKey:HKSampleSortIdentifierEndDate ascending:NO];
    
    NSPredicate *predicate = [HealthManager predicateForSamplesTodayWithStartDate:startDate endDate:endDate];
    
    HKSampleType *walkingDistanceType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning];
    HKSampleQuery *walkingDistanceQuery = [[HKSampleQuery alloc]initWithSampleType:walkingDistanceType predicate:predicate limit:0 sortDescriptors:@[start,end] resultsHandler:^(HKSampleQuery * _Nonnull query, NSArray<__kindof HKSample *> * _Nullable results, NSError * _Nullable error) {
        
        if (error) {
            completion(0, error);
        }else{
            //设置一个int型变量来作为步数统计
            double totleSteps = 0;
            for(HKQuantitySample *quantitySample in results)
            {
                HKQuantity *quantity = quantitySample.quantity;
                HKUnit *distanceUnit = [HKUnit meterUnitWithMetricPrefix:HKMetricPrefixKilo];
                double usersHeight = [quantity doubleValueForUnit:distanceUnit];
                totleSteps += usersHeight;
            }
            NSLog(@"当天行走距离 = %.2f",totleSteps);
            completion(totleSteps, error);
        }
    }];
    [self.healthStore executeQuery:walkingDistanceQuery];
}

- (void)getEnergyFrom:(NSString *)startDate endDate:(NSString *)endDate energyBurned:(void(^)(double value, NSError *error))completion{
    
    NSSortDescriptor *start = [NSSortDescriptor sortDescriptorWithKey:HKSampleSortIdentifierStartDate ascending:NO];
    NSSortDescriptor *end = [NSSortDescriptor sortDescriptorWithKey:HKSampleSortIdentifierEndDate ascending:NO];
    
    NSPredicate *predicate = [HealthManager predicateForSamplesTodayWithStartDate:startDate endDate:endDate];
    
    HKSampleType *energyBurnedType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned];
    HKSampleQuery *walkingDistanceQuery = [[HKSampleQuery alloc]initWithSampleType:energyBurnedType predicate:predicate limit:0 sortDescriptors:@[start,end] resultsHandler:^(HKSampleQuery * _Nonnull query, NSArray<__kindof HKSample *> * _Nullable results, NSError * _Nullable error) {
        
        if (error) {
            completion(0, error);
        }else{
            //设置一个int型变量来作为步数统计
            double totalCalorie = 0;
            for(HKQuantitySample *quantitySample in results)
            {
                HKQuantity *quantity = quantitySample.quantity;
                HKUnit *energyUnit = [HKUnit kilocalorieUnit];
                double CalorieBurned = [quantity doubleValueForUnit:energyUnit];
                totalCalorie += CalorieBurned;
            }
            NSLog(@"当天燃烧卡路里 = %.2f",totalCalorie);
            completion(totalCalorie, error);
        }
    }];
    [self.healthStore executeQuery:walkingDistanceQuery];
}
- (void)getHeartRateFrom:(NSString *)startDate endDate:(NSString *)endDate heartRate:(void(^)(int minValue, int maxValue, NSError *error))completion{
    
    NSSortDescriptor *start = [NSSortDescriptor sortDescriptorWithKey:HKSampleSortIdentifierStartDate ascending:NO];
    NSSortDescriptor *end = [NSSortDescriptor sortDescriptorWithKey:HKSampleSortIdentifierEndDate ascending:NO];
    
    NSPredicate *predicate = [HealthManager predicateForSamplesTodayWithStartDate:startDate endDate:endDate];
    
    HKSampleType *heartRateType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
    HKSampleQuery *heartRateQuery = [[HKSampleQuery alloc]initWithSampleType:heartRateType predicate:predicate limit:0 sortDescriptors:@[start,end] resultsHandler:^(HKSampleQuery * _Nonnull query, NSArray<__kindof HKSample *> * _Nullable results, NSError * _Nullable error) {
        
        if (error) {
            completion(0, 0, error);
        }else{
            //设置一个int型变量来作为步数统计

            double maxHeartRate = 0;
            double minHeartRate = 999;
            for(HKQuantitySample *quantitySample in results)
            {
                HKQuantity *quantity = quantitySample.quantity;
                HKUnit *heartRateUnit = [HKUnit unitFromString:@"count/min"];
                double heartRate = [quantity doubleValueForUnit:heartRateUnit];
                if (heartRate > maxHeartRate){
                    maxHeartRate = heartRate;
                }
                if (heartRate < minHeartRate) {
                    minHeartRate = heartRate;
                }
            }
            NSLog(@"Your heart rate is between: %d - %d count/min", (int)minHeartRate, (int)maxHeartRate);
            completion((int)minHeartRate, (int)maxHeartRate, error);
        }
    }];
    [self.healthStore executeQuery:heartRateQuery];
}

- (void)getSleepAnalysisFrom:(NSString *)startDate endDate:(NSString *)endDate sleepAnalysis:(void(^)(double value, NSError *error))completion{
    
    NSSortDescriptor *start = [NSSortDescriptor sortDescriptorWithKey:HKSampleSortIdentifierStartDate ascending:NO];
    NSSortDescriptor *end = [NSSortDescriptor sortDescriptorWithKey:HKSampleSortIdentifierEndDate ascending:NO];
    
    NSPredicate *predicate = [HealthManager predicateForSamplesTodayWithStartDate:startDate endDate:endDate];
    
    HKSampleType *sleepType = [HKQuantityType categoryTypeForIdentifier:HKCategoryTypeIdentifierSleepAnalysis];
    HKSampleQuery *sleepQuery = [[HKSampleQuery alloc]initWithSampleType:sleepType predicate:predicate limit:0 sortDescriptors:@[start,end] resultsHandler:^(HKSampleQuery * _Nonnull query, NSArray<__kindof HKSample *> * _Nullable results, NSError * _Nullable error) {
        
        if (error) {
            completion(0, error);
        }else{
            NSInteger totleSleep = 0;
            for (HKCategorySample *sample in results) {//0：卧床时间 1：睡眠时间  2：清醒状态
//                NSLog(@"=======%@=======%ld",sample, sample.value);
                if (sample.value == 1) {
                    NSTimeInterval i = [sample.endDate timeIntervalSinceDate:sample.startDate];
                    totleSleep += i;
                }
            }
            NSLog(@"睡眠分析：%.2f",totleSleep/3600.0);
            completion(totleSleep/3600.0, error);
        }
    }];
    
    [self.healthStore executeQuery:sleepQuery];
}
@end
