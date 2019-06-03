//
//  Message.m
//  RelaxBot
//
//  Created by xiongbiao on 2019/3/18.
//  Copyright © 2019年 xiongbiao. All rights reserved.
//

#import "Message.h"

@implementation Message

- (instancetype)initWithMessage:(NSString *)message date:(NSString *)date messageType:(enum MessageType)type messageSource:(enum MessageSource)source{
    if (self = [super init]){
        self.message = message;
        self.date = date;
        self.type = type;
        self.source = source;
    }
    return self;
}
@end

