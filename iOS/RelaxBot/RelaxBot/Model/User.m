//
//  User.m
//  RelaxBot
//
//  Created by xiongbiao on 2019/4/19.
//  Copyright © 2019 xiongbiao. All rights reserved.
//

#import "User.h"

@implementation User


static User * userManager = nil;
+(instancetype)allocWithZone:(struct _NSZone *)zone{
    static  dispatch_once_t once;
    dispatch_once(&once, ^{  //还有这里需要加&
        if (userManager == nil) {  //注意：这里不是if(userManager)
            userManager = [[super allocWithZone:zone] init];
            //为了保证属性的一致性，属性的初始化建议在这里执行
        }
    });
    return userManager;
}

+(User *)shareInstance{
    return [[self alloc] init];
}

+(void)clearUser{
    userManager = nil;
}
@end
