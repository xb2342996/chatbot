//
//  User.h
//  RelaxBot
//
//  Created by xiongbiao on 2019/4/19.
//  Copyright © 2019 xiongbiao. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface User : NSObject
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *email;

+(User *)shareInstance;
+(void)clearUser;
@end

NS_ASSUME_NONNULL_END
