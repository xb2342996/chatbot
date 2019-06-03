//
//  Track.h
//  RelaxBot
//
//  Created by xiongbiao on 2019/4/6.
//  Copyright © 2019年 xiongbiao. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

enum MusicInstructionType {
    MusicInstructionTypePlay = 1,
    MusicInstructionTypePause = 2,
    MusicInsturctionTypeNext = 3,
    MusicInsturctionTypePrevious = 4,
    MusicInsturctionTypeShuffle = 5,
    MusicInsturctionTypeRepeat = 6,
};

@interface Track : NSObject
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *uri;
@end

@interface Instruct : NSObject
@property (assign, nonatomic) enum MusicInstructionType type;
@end

NS_ASSUME_NONNULL_END
