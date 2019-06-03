//
//  Playlist.h
//  RelaxBot
//
//  Created by xiongbiao on 2019/4/2.
//  Copyright © 2019年 xiongbiao. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Playlist : NSObject
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *uri;
@property (copy, nonatomic) NSString *image;
@property (copy, nonatomic) NSString *total;
@end

@interface Playlists : NSObject
@property (strong, nonatomic) NSMutableArray *playlists;
@end

NS_ASSUME_NONNULL_END
