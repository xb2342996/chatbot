//
//  Regx.h
//  RelaxBot
//
//  Created by xiongbiao on 2019/4/19.
//  Copyright © 2019 xiongbiao. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Regx : NSObject
+ (BOOL)validateEmail:(NSString *)email;
+ (BOOL)checkPassword:(NSString *)password;
@end

NS_ASSUME_NONNULL_END
