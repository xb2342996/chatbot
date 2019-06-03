//
//  PlaylistCell.h
//  RelaxBot
//
//  Created by xiongbiao on 2019/4/6.
//  Copyright © 2019年 xiongbiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Playlist.h"
#import "Message.h"

NS_ASSUME_NONNULL_BEGIN

@protocol PlaylistCellDelegate <NSObject>
- (void)playlistPlayButtonClick:(NSString *)playUri totalTracks:(int)totalTracks;
@end

@interface PlaylistCell : UITableViewCell
@property (nonatomic, strong) Playlist *playlist;
@property (assign, nonatomic) enum MessageType messageType;
@property (nonatomic, weak) id <PlaylistCellDelegate> delegate;
@property (nonatomic, assign) NSInteger index;
@end

NS_ASSUME_NONNULL_END
