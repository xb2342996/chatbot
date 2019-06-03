//
//  ChatViewController.h
//  RelaxBot
//
//  Created by xiongbiao on 2019/3/13.
//  Copyright © 2019年 xiongbiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpotifyAudioPlayback/SpotifyAudioPlayback.h>

NS_ASSUME_NONNULL_BEGIN

@interface ChatViewController : UIViewController <SPTAudioStreamingDelegate, SPTAudioStreamingPlaybackDelegate>

@end

NS_ASSUME_NONNULL_END
