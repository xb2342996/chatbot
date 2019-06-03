//
//  MusicPlayerView.m
//  RelaxBot
//
//  Created by xiongbiao on 2019/3/27.
//  Copyright © 2019年 xiongbiao. All rights reserved.
//



#import "MusicPlayerView.h"
#import "Masonry/Masonry.h"
#import <SpotifyAuthentication/SpotifyAuthentication.h>
#import <SpotifyMetadata/SpotifyMetadata.h>
#import <SpotifyAudioPlayback/SpotifyAudioPlayback.h>
#import <SpotifyMetadata/SpotifyMetadata.h>
#import <AVFoundation/AVFoundation.h>
#import "TimeUtil.h"
#import <AFNetworking.h>
#import "Playlist.h"
#import "Config.h"
#import "Message.h"
#import <MJExtension.h>
#import <SDWebImage.h>




typedef enum : NSUInteger {
    PlayModeCycle = 1,
    PlayModeShuffle,
} PlayModeType;

@interface MusicPlayerView () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, weak) UIButton *playButton;
@property (nonatomic, weak) UIButton *nextButton;
@property (nonatomic, weak) UIButton *previousButton;
@property (nonatomic, weak) UIImageView *coverImageView;
@property (nonatomic, weak) UILabel *titleLabel;
@property (nonatomic, weak) UILabel *subTitleLabel;
@property (nonatomic, weak) UIButton *shuffleButton;
@property (nonatomic, weak) UIButton *playlistButton;
@property (nonatomic, weak) UISlider *progressSlider;
@property (nonatomic, weak) UILabel *startTimeLabel;
@property (nonatomic, weak) UILabel *endTimeLabel;
@property (nonatomic, assign) NSInteger playmode;
@property (nonatomic, copy) NSString *playUri;
@property (nonatomic) BOOL isChangingProgress;
@property (nonatomic, weak) UIButton *hiddenButton;
@property (nonatomic, weak) UITableView *playlistView;
@property (nonatomic, weak) UIView *backgroundView;
@property (nonatomic, weak) UIView *playlistContent;
@property (nonatomic, weak) UIButton *dismissButton;
@property (nonatomic, strong) NSMutableArray *lists;
@property (nonatomic, copy) NSString *currentUri;
@property (nonatomic, copy) NSString *currentListType;
@property (nonatomic, copy) NSString *currentSource;

@property (nonatomic, strong) SPTAudioStreamingController *player;
@end

@implementation MusicPlayerView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1];
        self.layer.cornerRadius = 10;
        self.layer.masksToBounds = YES;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playNotification:) name:@"playPlaylist" object:nil];
        
        UIImageView *coverImageView = [[UIImageView alloc]init];
        coverImageView.backgroundColor = [UIColor greenColor];
        coverImageView.layer.cornerRadius = 140;
        coverImageView.layer.masksToBounds = YES;
        UILabel *titleLabel = [[UILabel alloc]init];
//        titleLabel.backgroundColor = [UIColor blueColor];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.text = @"song title";
        [titleLabel setFont:[UIFont boldSystemFontOfSize:20]];
        UILabel *subTitleLabel = [[UILabel alloc]init];
//        subTitleLabel.backgroundColor = [UIColor purpleColor];
        subTitleLabel.textColor = [UIColor whiteColor];
        subTitleLabel.text = @"artist and album";
        [subTitleLabel setFont:[UIFont systemFontOfSize:16]];
        UIButton *playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [playButton setBackgroundImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
        [playButton addTarget:self action:@selector(playClick) forControlEvents:UIControlEventTouchDown];
        playButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        nextButton.backgroundColor = [UIColor yellowColor];
//        [nextButton setTitle:@"Next" forState:UIControlStateNormal];
        [nextButton setBackgroundImage:[UIImage imageNamed:@"next"] forState:UIControlStateNormal];
        [nextButton addTarget:self action:@selector(nextClick) forControlEvents:UIControlEventTouchDown];
        UIButton *previousButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        previousButton.backgroundColor = [UIColor brownColor];
//        [previousButton setTitle:@"Prev" forState:UIControlStateNormal];
        [previousButton setBackgroundImage:[UIImage imageNamed:@"previous"] forState:UIControlStateNormal];
        [previousButton addTarget:self action:@selector(previousClick) forControlEvents:UIControlEventTouchDown];
        UISlider *progressSlider = [[UISlider alloc]init];
        progressSlider.continuous = YES;
        [progressSlider setMaximumValue:1];
        [progressSlider setMinimumValue:0];
        progressSlider.tintColor = [UIColor whiteColor];
        [progressSlider addTarget:self action:@selector(progressTouchDown) forControlEvents:UIControlEventTouchDown];
        [progressSlider addTarget:self action:@selector(seekValueChanged) forControlEvents:UIControlEventTouchUpInside];
        [progressSlider setThumbImage:[UIImage imageNamed:@"thumb"] forState:UIControlStateNormal];
        UIButton *shuffleButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        shuffleButton.backgroundColor = [UIColor orangeColor];
//        [shuffleButton setTitle:@"shuffle" forState:UIControlStateNormal];
        [shuffleButton setBackgroundImage:[UIImage imageNamed:@"repeat"] forState:UIControlStateNormal];
        [shuffleButton addTarget:self action:@selector(playMode:) forControlEvents:UIControlEventTouchDown];
        UIButton *listButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [listButton setBackgroundImage:[UIImage imageNamed:@"playlist"] forState:UIControlStateNormal];
        [listButton addTarget:self action:@selector(playlistShow) forControlEvents:UIControlEventTouchDown];
        UILabel *startTimeLabel = [[UILabel alloc]init];
        startTimeLabel.text = @"00:00";
        startTimeLabel.textColor = [UIColor whiteColor];
        [startTimeLabel setFont:[UIFont systemFontOfSize:12]];
        UILabel *endTimeLabel = [[UILabel alloc]init];
        [endTimeLabel setFont:[UIFont systemFontOfSize:12]];
        endTimeLabel.text = @"00:00";
        endTimeLabel.textColor = [UIColor whiteColor];
        UIButton *hiddenButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [hiddenButton setBackgroundImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
        [hiddenButton addTarget:self action:@selector(dismissPlayer) forControlEvents:UIControlEventTouchDown];
        
        UITableView *tableView = [[UITableView alloc]init];
        tableView.backgroundColor = [UIColor whiteColor];
        
        tableView.dataSource = self;
        tableView.delegate = self;
        [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Playlist"];
        tableView.frame = CGRectMake(0, 0, kScreenWidth, 308);
        tableView.userInteractionEnabled = YES;
        
        UIView *backgroundView = [[UIView alloc]init];
        backgroundView.hidden = YES;
        backgroundView.backgroundColor = [UIColor colorWithWhite:0.3 alpha:0.7];
//        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissPlaylist)];
//        [backgroundView addGestureRecognizer:gesture];
        backgroundView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
        
        UIView *dummyView = [[UIView alloc]init];
//        dummyView.backgroundColor = [UIColor colorWithWhite:0.3 alpha:0.7];
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissPlaylist)];
        [dummyView addGestureRecognizer:gesture];
        dummyView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight - 363);
        
        UIView *playlistContent = [[UIView alloc]init];
        playlistContent.backgroundColor = [UIColor whiteColor];
        playlistContent.frame = CGRectMake(0, kScreenHeight, kScreenWidth, 363);
        
        UIButton *dismissButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [dismissButton setTitle:@"Close" forState:UIControlStateNormal];
        [dismissButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        dismissButton.titleLabel.font = [UIFont systemFontOfSize:20];

        [dismissButton addTarget:self action:@selector(dismissPlaylist) forControlEvents:UIControlEventTouchDown];
        dismissButton.frame = CGRectMake(0, 308, kScreenWidth, 55);
        
        self.dismissButton = dismissButton;
        self.playlistContent = playlistContent;
        self.backgroundView = backgroundView;
        self.playlistView = tableView;
        self.startTimeLabel = startTimeLabel;
        self.endTimeLabel = endTimeLabel;
        self.shuffleButton = shuffleButton;
        self.coverImageView = coverImageView;
        self.playButton = playButton;
        self.nextButton = nextButton;
        self.previousButton = previousButton;
        self.playlistButton = listButton;
        self.titleLabel = titleLabel;
        self.progressSlider = progressSlider;
        self.subTitleLabel = subTitleLabel;
        self.hiddenButton = hiddenButton;
        self.playmode = 1;
        self.playing = NO;
        
        [self addSubview:startTimeLabel];
        [self addSubview:endTimeLabel];
        [self addSubview:progressSlider];
        [self addSubview:shuffleButton];
        [self addSubview:titleLabel];
        [self addSubview:coverImageView];
        [self addSubview:playButton];
        [self addSubview:nextButton];
        [self addSubview:previousButton];
        [self addSubview:listButton];
        [self addSubview:subTitleLabel];
        [self addSubview:hiddenButton];
        [self addSubview:backgroundView];
        [playlistContent addSubview:self.playlistView];
        [backgroundView addSubview:self.playlistContent];
        [playlistContent addSubview:dismissButton];
        [backgroundView addSubview:dummyView];
    }
    return self;
}

//-(void)setPlaying:(BOOL)playing{
//    self.playing = playing;
//}
-(void)updateUI {
    NSLog(@"update ui track:%@", self.player.metadata.currentTrack.uri);
    SPTAuth *auth = [SPTAuth defaultInstance];
    
    if (self.player.metadata == nil || self.player.metadata.currentTrack == nil) {
        self.coverImageView.image = nil;
        return;
    }
    
    self.titleLabel.text = self.player.metadata.currentTrack.name;
    self.endTimeLabel.text = [TimeUtil musicTimeConverter:self.player.metadata.currentTrack.duration];
    self.subTitleLabel.text = [NSString stringWithFormat:@"%@ - %@", self.player.metadata.currentTrack.artistName, self.player.metadata.currentTrack.albumName];
    
    NSLog(@"image url: %@", self.player.metadata.currentTrack.albumCoverArtURL);
    [self.coverImageView sd_setImageWithURL:[NSURL URLWithString:self.player.metadata.currentTrack.albumCoverArtURL]];
}
- (void)playlistShow{
    self.backgroundView.hidden = NO;
    [self layoutIfNeeded];
    [UIView animateWithDuration:0.25 animations:^{
        self.playlistContent.frame = CGRectMake(0, kScreenHeight-363, kScreenWidth, 363);
    } completion:^(BOOL finished) {
        
    }];
    
}
- (void)dismissPlayer{
    if ([self.delegate respondsToSelector:@selector(dismissButtonClick)]){
        [self.delegate dismissButtonClick];
    }
}
- (void)dismissPlaylist{
    [UIView animateWithDuration:0.25 animations:^{
        self.playlistContent.frame = CGRectMake(0, kScreenHeight, kScreenWidth, 363);
    } completion:^(BOOL finished) {
        self.backgroundView.hidden = YES;
    }];
}
- (void)setLists:(NSMutableArray *)lists{
    _lists = lists;
    [self.playlistView reloadData];
}
- (void)playNotification:(NSNotification *)noti{
    NSDictionary *dict = [noti userInfo];
    NSMutableArray *playlistArray = [noti object];
    self.lists = playlistArray;
    NSString *uri = [dict objectForKey:@"uri"];
    NSString *index = [dict objectForKey:@"index"];
    NSString *type = [dict objectForKey:@"list_type"];
//    NSLog(@"list length: %lu", (unsigned long)self.lists.count);
    NSLog(@"%@--%@--%@", uri, index, type);
    self.currentListType = type;
    self.currentUri = uri;
    [self playWithUri:uri index:[index integerValue]];
}
- (void)playWithUri:(NSString *)uri index:(NSInteger)index{
    
    [self.player playSpotifyURI:uri startingWithIndex:index startingWithPosition:0 callback:^(NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"*** failed to play: %@", error);
            return;
        }
        [self.player setRepeat:SPTRepeatContext callback:^(NSError * _Nullable error) {
            if (error != nil) {
                NSLog(@"error: %@", error);
            }
        }];
        [self.player setShuffle:NO callback:^(NSError * _Nullable error) {
            if (error != nil) {
                NSLog(@"error: %@", error);
            }
        }];
    }];


}
- (void)playClick{

    if (self.playUri != nil && ![self.playUri isEqualToString:@""]){
        [self.player setIsPlaying:!self.player.playbackState.isPlaying callback:nil];
    }
}

- (void)nextClick{
    if (self.player != nil) {
        [self.player skipNext:^(NSError * _Nullable error) {
            
        }];
    }
}
- (void)previousClick{
    if (self.player != nil){
        [self.player skipPrevious:^(NSError * _Nullable error) {
            
        }];
    }
}

- (void)playMode:(UIButton *)button{
    if (self.player != nil){
        if (self.playmode < 2){
            self.playmode ++;
        }else{
            self.playmode = 1;
        }
    }
    switch (self.playmode) {
        case PlayModeCycle:
            [self.player setShuffle:NO callback:^(NSError * _Nullable error) {
                if (error != nil) {
                    NSLog(@"error: %@", error);
                }
            }];
            [button setBackgroundImage:[UIImage imageNamed:@"repeat"] forState:UIControlStateNormal];
            break;
        case PlayModeShuffle:
            [self.player setShuffle:YES callback:^(NSError * _Nullable error) {
                if (error != nil) {
                    NSLog(@"error: %@", error);
                }
            }];
            [button setBackgroundImage:[UIImage imageNamed:@"shuffle"] forState:UIControlStateNormal];
            break;
        default:
            break;
    }
}

// spotify session
-(void)handleNewSession {
    
    SPTAuth *auth = [SPTAuth defaultInstance];
    if (self.player == nil) {
        NSError *error = nil;
        self.player = [SPTAudioStreamingController sharedInstance];
        if ([self.player startWithClientId:auth.clientID audioController:nil allowCaching:YES error:&error]) {
            self.player.delegate = self;
            self.player.playbackDelegate = self;
            self.player.diskCache = [[SPTDiskCache alloc] initWithCapacity:1024 * 1024 * 64];
            [self.player loginWithAccessToken:auth.session.accessToken];
            
        } else {
            self.player = nil;
            [self closeSession];
        }
    }
}

- (void)closeSession {
    [SPTAuth defaultInstance].session = nil;
}


// audio streaming delegate
- (void)audioStreamingDidLogin:(SPTAudioStreamingController *)audioStreaming{
    NSLog(@"Login!");
    [self updateUI];
}

- (void)audioStreamingDidReconnect:(SPTAudioStreamingController *)audioStreaming{
    NSLog(@"Reconnect!");
}

- (void)audioStreaming:(SPTAudioStreamingController *)audioStreaming
     didChangePosition:(NSTimeInterval)position
{
    if (self.isChangingProgress) {
        return;
    }
    self.progressSlider.value = position/self.player.metadata.currentTrack.duration;
    self.startTimeLabel.text = [TimeUtil musicTimeConverter:position];
}
- (void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didReceiveMessage:(NSString *)message{
    
}
- (void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didReceiveError:(NSError *)error{
    NSLog(@"didReceiveError: %zd %@", error.code, error.localizedDescription);
    
    if (error.code == SPErrorNeedsPremium) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Premium account required" message:@"Premium account is required to showcase application functionality. Please login using premium account." preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction* action){
            [self closeSession];
        }]];
    }
}

- (void)audioStreamingDidLogout:(SPTAudioStreamingController *)audioStreaming{
    [self closeSession];
}
- (void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didStartPlayingTrack:(NSString *)trackUri{
    self.playUri = trackUri;
    [self updateUI];
    NSLog(@"Starting %@ ", trackUri);
    NSLog(@"metadata %@", self.player.metadata.currentTrack.uri);
//    NSLog(@"Source %@", self.player.metadata.currentTrack.playbackSourceUri);
    if ((self.lists.count == 0 || self.currentSource != self.player.metadata.currentTrack.playbackSourceUri) && [self.currentListType intValue] != MessageTypeMusicTrack){
        [self requestDataWithUri:self.player.metadata.currentTrack.playbackSourceUri];
        self.currentSource = self.player.metadata.currentTrack.playbackSourceUri;
    }
}
- (void)requestDataWithUri:(NSString *)uri{
    NSDictionary *param = @{
                            @"playlist_id": uri,
                            @"playlist_type": self.currentListType
                            };
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:kPlaylistDetailUrl parameters:param progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        Message *message = [Message mj_objectWithKeyValues:responseObject];
        Playlists *playlists = [Playlists mj_objectWithKeyValues:message.contents];
        self.lists = playlists.playlists;
        [self.playlistView reloadData];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}
- (void)audioStreaming:(SPTAudioStreamingController *)audioStreaming
   didStopPlayingTrack:(NSString *)trackUri{
//    NSLog(@"Finishing: %@", trackUri);
    self.startTimeLabel.text = self.endTimeLabel.text;
}
- (void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didChangePlaybackStatus:(BOOL)isPlaying{
//    NSLog(@"isPlaying=%d ", isPlaying);
    self.playing = isPlaying;
    if (isPlaying) {
        [self activateAudioSession];
        [self.playButton setBackgroundImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
    } else {
//        [self deactivateAudioSession];
        [self.playButton setBackgroundImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    }
}
-(void)audioStreaming:(SPTAudioStreamingController *)audioStreaming
    didChangeMetadata:(SPTPlaybackMetadata *)metadata {
    
}
-(void)audioStreaming:(SPTAudioStreamingController *)audioStreaming
didReceivePlaybackEvent:(SpPlaybackEvent)event withName:(NSString *)name {
    NSLog(@"didReceivePlaybackEvent: %zd %@", event, name);
}
- (void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didChangeRepeatStatus:(SPTRepeatMode)repeateMode{
    NSLog(@"Repeat Mode: %ld", repeateMode);
}
- (void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didChangeShuffleStatus:(BOOL)enabled{
    NSLog(@"Shuffled: %d", enabled);
}
- (void)audioStreamingDidSkipToNextTrack:(SPTAudioStreamingController *)audioStreaming{
    NSLog(@"next track: %@", self.player.metadata.currentTrack.uri);
}

/** Called when the audio streaming object requests playback skips to the previous track.
 @param audioStreaming The object that sent the message.
 */
- (void)audioStreamingDidSkipToPreviousTrack:(SPTAudioStreamingController *)audioStreaming{
    NSLog(@"privious track: %@", self.player.metadata.currentTrack.uri);
}
- (void)activateAudioSession
{
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionMixWithOthers error:nil];
    [[AVAudioSession sharedInstance] setActive:YES withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
}

- (void)deactivateAudioSession
{
    [[AVAudioSession sharedInstance] setActive:NO error:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.lists count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Playlist"];
    Playlist *playlist = self.lists[indexPath.row];
    cell.textLabel.text = playlist.name;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSLog(@"click!");
    [self playWithUri:self.currentUri index:indexPath.row];
}
- (void)progressTouchDown{
    self.isChangingProgress = YES;
}

- (void)seekValueChanged{
    self.isChangingProgress = NO;
    NSUInteger dest = self.player.metadata.currentTrack.duration * self.progressSlider.value;
    [self.player seekTo:dest callback:^(NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"error: %@", error);
        }
    }];
}
- (void)layoutSubviews{
    [self.startTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.progressSlider.mas_bottom).offset(10);
        make.left.equalTo(self.progressSlider.mas_left);
    }];
    [self.endTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.progressSlider.mas_bottom).offset(10);
        make.right.equalTo(self.progressSlider.mas_right);
    }];
    
    [self.coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mas_centerX);
        make.centerY.equalTo(self.mas_centerY).offset(-90);
        make.width.height.mas_equalTo(280);
    }];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.coverImageView.mas_bottom).offset(50);
        make.left.equalTo(self).offset(30);
        make.height.mas_equalTo(40);
    }];
    [self.progressSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.subTitleLabel.mas_bottom).offset(25);
        make.left.equalTo(self.coverImageView).offset(-10);
        make.right.equalTo(self.coverImageView).offset(10);
        make.height.mas_equalTo(15);
    }];
    [self.playButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.width.mas_equalTo(66);
        make.height.mas_equalTo(66);
        make.top.equalTo(self.startTimeLabel.mas_bottom).offset(15);
    }];
    [self.nextButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.playButton);
        make.width.mas_equalTo(66);
        make.height.mas_equalTo(66);
        make.left.equalTo(self.playButton.mas_right).offset(10);
    }];
    [self.previousButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.playButton);
        make.width.mas_equalTo(66);
        make.height.mas_equalTo(66);
        make.right.equalTo(self.playButton.mas_left).offset(-10);
    }];
    [self.shuffleButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.playButton);
        make.width.mas_equalTo(44);
        make.height.mas_equalTo(44);
        make.right.equalTo(self.previousButton.mas_left).offset(-10);
    }];
    [self.playlistButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.playButton);
        make.width.mas_equalTo(44);
        make.height.mas_equalTo(44);
        make.left.equalTo(self.nextButton.mas_right).offset(10);
    }];
    [self.subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom);
        make.left.equalTo(self.titleLabel);
        make.height.mas_equalTo(32);
    }];
    [self.hiddenButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(40);
        make.left.equalTo(self).offset(20);
        make.width.mas_equalTo(20);
        make.height.mas_equalTo(20);
    }];
    [self.backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];

}

@end
