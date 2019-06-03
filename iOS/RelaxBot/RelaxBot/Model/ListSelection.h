//
//  ListSelection.h
//  RelaxBot
//
//  Created by xiongbiao on 2019/4/18.
//  Copyright © 2019 xiongbiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Message.h"
NS_ASSUME_NONNULL_BEGIN

@interface ListSelection : NSObject
@property (assign, nonatomic) enum MessageType type;
@property (assign, nonatomic) NSInteger number;
@property (copy, nonatomic) NSString *infotype;
@end

NS_ASSUME_NONNULL_END
