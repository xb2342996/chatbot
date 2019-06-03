//
//  Message.h
//  RelaxBot
//
//  Created by xiongbiao on 2019/3/18.
//  Copyright © 2019年 xiongbiao. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

enum MessageType{
    MessageTypeText = 1,
    MessageTypeLight = 2,
    MessageTypeHealth = 3,
    MessageTypeMovie = 4,
    MessageTypeMovieList= 5,
    MessageTypeMusicTrack = 6,
    MessageTypeMusicAlbum = 7,
    MessageTypeMusicPlaylist = 8,
    MessageTypeListSelection = 9,
    MessageTypeMusicControl= 10,
    MessageTypeVideo = 11,
};
enum MessageSource{
    MessageSourceSender = 0,
    MessageSourceReceiver,
};

@interface Message : NSObject
@property (copy, nonatomic) NSString *message;
@property (copy, nonatomic) NSString *date;
@property (assign, nonatomic) BOOL showdate;
@property (assign, nonatomic) NSInteger status;
@property (assign, nonatomic) enum MessageType type;
@property (assign, nonatomic) enum MessageSource source;
@property (nonatomic, strong) NSDictionary *contents;


- (instancetype)initWithMessage:(NSString *)message date:(NSString *)date messageType:(enum MessageType)type messageSource:(enum MessageSource)source;
@end

NS_ASSUME_NONNULL_END
