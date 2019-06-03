//
//  MusicPlayerView.h
//  RelaxBot
//
//  Created by xiongbiao on 2019/3/27.
//  Copyright © 2019年 xiongbiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpotifyAudioPlayback/SpotifyAudioPlayback.h>
NS_ASSUME_NONNULL_BEGIN

@protocol MusicViewDelegate <NSObject>
-(void)dismissButtonClick;
@end

@interface MusicPlayerView : UIView <SPTAudioStreamingDelegate, SPTAudioStreamingPlaybackDelegate>
@property (nonatomic, readwrite, getter=isPlaying) BOOL playing;
@property (nonatomic, weak) id <MusicViewDelegate> delegate;
- (void)playClick;
- (void)playWithUri:(NSString *)uri index:(NSInteger)index;
- (void)handleNewSession;
@end



NS_ASSUME_NONNULL_END
