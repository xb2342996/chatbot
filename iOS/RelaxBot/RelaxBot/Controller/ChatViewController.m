//
//  ChatViewController.m
//  RelaxBot
//
//  Created by xiongbiao on 2019/3/13.
//  Copyright © 2019年 xiongbiao. All rights reserved.
//

#import "ChatViewController.h"
#import <Masonry/Masonry.h>
#import "ChatViewCell.h"
#import <AFNetworking.h>
#import "Message.h"
#import <MJExtension.h>
#import "TimeUtil.h"
#import <Speech/Speech.h>
#import <SpotifyAuthentication/SpotifyAuthentication.h>
#import <SpotifyMetadata/SpotifyMetadata.h>
#import <SpotifyAudioPlayback/SpotifyAudioPlayback.h>
#import <SpotifyMetadata/SpotifyMetadata.h>
#import <AVFoundation/AVFoundation.h>
#import "Config.h"
#import "BottomInputView.h"
#import "RecordNoticeView.h"
#import "MusicPlayerView.h"
#import "Playlist.h"
#import <HealthKit/HealthKit.h>
#import "HealthManager.h"
#import "ContainerView.h"
#import "Movie.h"
#import "MovieInfoView.h"
#import "Health.h"
#import "SettingViewController.h"
#import "ListSelection.h"

@interface ChatViewController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UINavigationBarDelegate, BottomInputViewDelegate, ChatCellDelegate,MusicViewDelegate, MovieInfoViewDelegate>
@property (nonatomic, weak) UITableView *chatTableView;
@property (nonatomic, weak) UIView *bottomView;
@property (nonatomic, weak) UITextField *textInputField;
@property (nonatomic, weak) UIButton *typeButton;
@property (nonatomic, weak) UIButton *voiceButton;
@property (nonatomic, weak) UIButton *musicButton;
@property (nonatomic, strong) NSMutableArray *chatMessages;
@property (nonatomic, assign) int buttonFlag;
@property (nonatomic, strong) AVAudioEngine *audioEngine;
@property (nonatomic, strong) SFSpeechRecognizer *speechRecognizer;
@property (nonatomic, strong) SFSpeechAudioBufferRecognitionRequest *recognitionRequest;
@property (nonatomic, assign) Boolean sendFlag;
@property (nonatomic, weak) RecordNoticeView *recordNoticeView;
@property (nonatomic, weak) BottomInputView *bottomInputView;
@property (nonatomic, weak) MusicPlayerView *musicPlayerView;
@property (nonatomic, strong) SPTAudioStreamingController *player;
@property (atomic, readwrite) BOOL firstLoad;
@property (atomic, readwrite) BOOL playerShow;
@property (atomic, readwrite) BOOL breakPlayingMusic;
@property (nonatomic, weak) ContainerView *containerView;
@property (atomic, readwrite) BOOL detailViewShow;
@property (nonatomic, strong) HealthManager *healthManager;
@property (nonatomic, weak) UIWindow *window;
@property (nonatomic, strong) UIView *dummyView;
@property (nonatomic, strong) MovieInfoView *movieInfoView;
@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupView];
    self.chatMessages = [NSMutableArray array];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(transformView:) name:UIKeyboardWillChangeFrameNotification object:nil];
    self.navigationItem.title = @"Chat Bot";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"setting"] style:UIBarButtonItemStylePlain target:self action:@selector(settingButtonClick)];
    [SFSpeechRecognizer requestAuthorization:^(SFSpeechRecognizerAuthorizationStatus status) {
    }];
    self.firstLoad = YES;
    self.breakPlayingMusic = NO;
    self.playerShow = NO;
    self.detailViewShow = NO;
    self.healthManager = [HealthManager shareHealthManager];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionUpdatedNotification:) name:@"sessionUpdated" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieInfoShowNotification:) name:@"movieInfoShowNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoShowNotification:) name:@"videoShowNotification" object:nil];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    SPTAuth *auth = [SPTAuth defaultInstance];

    if (auth.session == nil){
        NSLog(@"session is nil");
        [self authorization];
        return;
    }
    if ([auth.session isValid] && self.firstLoad) {
        NSLog(@"session valid");
        [self setPlayer];
        return;
    }

    if (auth.hasTokenRefreshService){
        NSLog(@"refresh token");
        [self renewTokenAndShowPlayer];
        return;
    }
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    for (UIView *view in self.view.subviews) {
        [view resignFirstResponder];
    }
    NSLog(@"hidden player");
    [self hiddenPlayer];
}
// spotify authorization
- (void)setPlayer{
    self.firstLoad = NO;
    [self.musicPlayerView handleNewSession];
}
- (void)hiddenPlayer{
    if (self.playerShow){
        self.musicPlayerView.hidden = YES;
        self.playerShow = NO;
    }
}
- (void)renewTokenAndShowPlayer{
    SPTAuth *auth = [SPTAuth defaultInstance];
    [auth renewSession:auth.session callback:^(NSError *error, SPTSession *session) {
        auth.session = session;
        if (error) {
            NSLog(@"*** Error renewing session: %@", error);
            return;
        }
        [self setPlayer];
    }];
}
- (void)authorization{
    SPTAuth *auth = [SPTAuth defaultInstance];
    
    if ([SPTAuth supportsApplicationAuthentication]) {
        [[UIApplication sharedApplication]openURL:[auth spotifyAppAuthenticationURL]];
    }else{
        NSLog(@"Please Download Spotify from AppStore");
    }
}

- (void)sessionUpdatedNotification:(NSNotification *)notification
{
    SPTAuth *auth = [SPTAuth defaultInstance];
    [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
    
    if (auth.session && [auth.session isValid]) {
        [self setPlayer];
    } else {
        NSLog(@"*** Failed to log in");
    }
}
- (void)movieInfoShowNotification:(NSNotification *)notification{
    MovieInfo *movie = [notification object];
    [self showMoiveInfoViewWithMovie:movie];
}
- (void)videoShowNotification:(NSNotification *)notification{
    Message *message = [notification object];
    message.date = [TimeUtil currentDate];
    [self showNewMessage:message];
}
- (void)hideKeyboard{
    [self.bottomInputView.textInputField resignFirstResponder];
    [self hiddenPlayer];
    [self hiddenDetailView];
}

-(void)transformView:(NSNotification *)aNSNotification
{
    //获取键盘弹出前的Rect
    NSValue *keyBoardBeginBounds=[[aNSNotification userInfo]objectForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect beginRect=[keyBoardBeginBounds CGRectValue];
    //获取键盘弹出后的Rect
    NSValue *keyBoardEndBounds=[[aNSNotification userInfo]objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect  endRect=[keyBoardEndBounds CGRectValue];
    //获取键盘位置变化前后纵坐标Y的变化值
    CGFloat deltaY=endRect.origin.y-beginRect.origin.y;

    //在0.25s内完成self.view的Frame的变化，等于是给self.view添加一个向上移动deltaY的动画
    [UIView animateWithDuration:0.25f animations:^{
        [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y+deltaY, self.view.frame.size.width, self.view.frame.size.height)];
    }];
}

// Audio recording

- (void)initEngine{
    
    if (!self.speechRecognizer) {
        NSLocale *locale = [NSLocale localeWithLocaleIdentifier:@"en"];
        self.speechRecognizer = [[SFSpeechRecognizer alloc]initWithLocale:locale];
    }
    if (!self.audioEngine) {
        self.audioEngine = [[AVAudioEngine alloc]init];
    }
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionMixWithOthers error:nil];
    [audioSession setActive:YES withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
    
    if (self.recognitionRequest) {
        [self.recognitionRequest endAudio];
        self.recognitionRequest = nil;
    }
    self.recognitionRequest = [[SFSpeechAudioBufferRecognitionRequest alloc]init];
    self.recognitionRequest.shouldReportPartialResults = NO;
    
    [self.speechRecognizer recognitionTaskWithRequest:self.recognitionRequest resultHandler:^(SFSpeechRecognitionResult * _Nullable result, NSError * _Nullable error) {
        NSLog(@"is final: %d  result: %@", result.isFinal, result.bestTranscription.formattedString);
        if (result.isFinal && self.sendFlag) {
            NSString *message = [NSString stringWithFormat:@"%@", result.bestTranscription.formattedString];
            [self processMessage:message type:MessageTypeText];
        }
    }];
}
- (void)releaseEngine{
    [[self.audioEngine inputNode] removeTapOnBus:0];
    [self.audioEngine stop];
    
    [self.recognitionRequest endAudio];
    self.recognitionRequest = nil;
}

// button click event
- (void)settingButtonClick{
    SettingViewController *settingController = [[SettingViewController alloc]init];
    [self.navigationController pushViewController:settingController animated:YES];
}
- (void)showMusicPlayer{
    if (self.detailViewShow){
        [self hiddenDetailView];
    }
    if (self.playerShow){
        self.musicPlayerView.hidden = YES;
        self.playerShow = NO;
    }else{
        self.musicPlayerView.hidden = NO;
        self.playerShow = YES;
        
        [self.musicPlayerView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.bottom.equalTo(self.musicButton);
        }];
        [self.window layoutIfNeeded];
        [UIView animateWithDuration:0.25 animations:^{
            [self.musicPlayerView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.right.top.bottom.equalTo(self.view);
            }];
            [self.window layoutIfNeeded];
        }];
    }
}

// send message request

- (void)processMessage:(NSString *)messageText type:(enum MessageType)type{

    Message *message = [[Message alloc]initWithMessage:messageText date:[TimeUtil currentDate]  messageType:MessageTypeText messageSource:MessageSourceSender];
    [self timeDisplayWithMessage:message];
    [self.chatMessages addObject:message];
    [self.chatTableView reloadData];
    [self scrollToBottom];
    [self sendRequestWithMessage:messageText];
}

- (void)sendRequestWithMessage:(NSString *)message{
//    NSString *username = [SPTAuth defaultInstance].session.canonicalUsername;
    self.navigationItem.title = @"Bot is Typing...";
    NSDictionary *param = @{
                            @"content" : message
                            };
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:kMessageUrl parameters:param progress:^(NSProgress * _Nonnull uploadProgress) {

    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable response) {
        self.navigationItem.title = @"Chat Bot";
        Message *message = [Message mj_objectWithKeyValues:response];
        message.date = [TimeUtil currentDate];
        NSLog(@"%@", response);
        if (message.type == MessageTypeHealth){
            [self showHealthInfomationWithMessage:message];
        }else if (message.type == MessageTypeListSelection){
            ListSelection *selection = [ListSelection mj_objectWithKeyValues:message.contents];
            NSLog(@"select list type : %d, select number: %ld", selection.type, (long)selection.number);
            NSLog(@"message type %d", self.containerView.message.type);
            Playlists *playlists = [Playlists mj_objectWithKeyValues:self.containerView.message.contents];
            Playlist *playlist = playlists.playlists[selection.number - 1];
            if (self.containerView.message.type == MessageTypeMusicPlaylist || self.containerView.message.type == MessageTypeMusicAlbum){
                if (playlist.total != 0) {
                    NSDictionary *dict = @{
                                           @"uri" : playlist.uri,
                                           @"index" : @(arc4random_uniform([playlist.total intValue])),
                                           @"list_type" : @(MessageTypeMusicPlaylist)
                                           };
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"playPlaylist" object:nil userInfo:dict];
                }
            } else if (self.containerView.message.type == MessageTypeMusicTrack){
                NSDictionary *dict = @{
                                       @"uri" : playlist.uri,
                                       @"index" : @(0),
                                       @"list_type" : @(MessageTypeMusicTrack)
                                       };
                [[NSNotificationCenter defaultCenter] postNotificationName:@"playPlaylist" object:nil userInfo:dict];
            } else if (self.containerView.message.type == MessageTypeMovieList){
                if ([selection.infotype isEqualToString:@"trailer"]){
                    [self requestVideo:playlist];
                } else {
                    [self requestMovieInfo:playlist];
                }
            }
        }else{
            [self showNewMessage:message];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"fail to connect to server. %ld", (long)error.code);
        self.navigationItem.title = @"RelaxBot";
        Message *message = [[Message alloc]initWithMessage:@"You have disconnect to Server" date:[TimeUtil currentDate] messageType:MessageTypeText messageSource:MessageSourceReceiver];
        [self showNewMessage:message];
    }];
}
- (void)requestVideo:(Playlist *)playlist{
    NSString *year = [playlist.name substringWithRange:NSMakeRange([playlist.name length] - 5, 4)];
    NSString *name = [playlist.name substringWithRange:NSMakeRange(0, [playlist.name length] - 6)];
    NSLog(@"moviename: %@, year: %@", name, year);
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSDictionary *param = @{
                            @"movie" : name,
                            @"year" : year
                            };
    [manager POST:kVideoUrl parameters:param progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        Message *message = [Message mj_objectWithKeyValues:responseObject];
        message.date = [TimeUtil currentDate];
        [self showNewMessage:message];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}
- (void)requestMovieInfo:(Playlist *)playlist{
    NSString *year = [playlist.name substringWithRange:NSMakeRange([playlist.name length] - 5, 4)];
    NSString *name = [playlist.name substringWithRange:NSMakeRange(0, [playlist.name length] - 6)];
    NSLog(@"moviename: %@, year: %@", name, year);
    NSDictionary *param = @{
                            @"movie" : name,
                            @"type" : playlist.uri,
                            @"year" : year
                            };
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:kMovieUrl parameters:param progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        Message *message = [Message mj_objectWithKeyValues:responseObject];
        message.date = [TimeUtil currentDate];
        MovieInfo *movie = [MovieInfo mj_objectWithKeyValues:message.contents];
        [self showNewMessage:message];
        [self showMoiveInfoViewWithMovie:movie];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}
- (void)timeDisplayWithMessage:(Message *)message{
    if ([self.chatMessages count] != 0){
        Message *lastMessage = [self.chatMessages lastObject];
        message.showdate = [TimeUtil showTimeBetweenFromDate:lastMessage.date toDate:message.date];
    }else{
        message.showdate = YES;
    }
}
- (void)showNewMessage:(Message *)message{
    [self timeDisplayWithMessage:message];
    [self.chatMessages addObject:message];
    [self.chatTableView reloadData];
    [self scrollToBottom];
}
// bottomView delegate

- (void)bottomInputTextFieldShouldReturn:(UITextField *)textField{
    [self processMessage:textField.text type:MessageTypeText];
    textField.text = @"";
}

- (void)recordButtonTouchDown:(UIButton *)recordButton {
    
    if (SFSpeechRecognizer.authorizationStatus != SFSpeechRecognizerAuthorizationStatusAuthorized) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Speech Recognition" message:@"Your Speech Recognition Function is Closed.\nPlease Go Setting Open Speech Recognition!" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *goSetting = [UIAlertAction actionWithTitle:@"Go Setting" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            if([[UIApplication sharedApplication] openURL:url]) {
                [[UIApplication sharedApplication] openURL:url];
            }
        }];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [alert dismissViewControllerAnimated:YES completion:nil];
        }];
        [alert addAction:goSetting];
        [alert addAction:cancel];
        [self presentViewController:alert animated:YES completion:nil];
    }else{
        if (self.musicPlayerView.playing){
            [self.musicPlayerView playClick];
            self.breakPlayingMusic = YES;
        }
        self.recordNoticeView.hidden = NO;
        [self.recordNoticeView recording];
        [self initEngine];
        
        AVAudioFormat *recordingFormat = [[self.audioEngine inputNode] outputFormatForBus:0];
        [[self.audioEngine inputNode] installTapOnBus:0 bufferSize:1024 format:recordingFormat block:^(AVAudioPCMBuffer * _Nonnull buffer, AVAudioTime * _Nonnull when) {
            [self.recognitionRequest appendAudioPCMBuffer:buffer];
        }];
        [self.audioEngine prepare];
        [self.audioEngine startAndReturnError:nil];
        
        [recordButton setBackgroundImage:[UIImage imageNamed:@"VoiceInputHL"] forState:UIControlStateNormal];
    }
}
- (void)recordButtonRelease{

    [self releaseEngine];
    self.recordNoticeView.hidden = YES;
    if (self.breakPlayingMusic){
        [self.musicPlayerView playClick];
        self.breakPlayingMusic = NO;
    }
}
- (void)recordButtonReleaseInside:(UIButton *)recordButton{
    self.sendFlag = true;
    [recordButton setBackgroundImage:[UIImage imageNamed:@"VoiceInput"] forState:UIControlStateNormal];
    [self recordButtonRelease];
}
- (void)recordButtonReleaseOutside:(UIButton *)recordButton{
    self.sendFlag =false;
    [self recordButtonRelease];
}
- (void)recordButtonDragUp:(UIButton *)recordButton{
    [self.recordNoticeView recordButtonDragUp];
}
- (void)recordButtonDragDown:(UIButton *)recordButton{
    [self.recordNoticeView recordButtonDragDown];
}
- (void)hiddenDetailView{
    [UIView animateWithDuration:0.4 animations:^{
        [self.containerView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.containerView.hidden = YES;
        self.detailViewShow = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"detailViewHidden" object:nil];
    }];
}
- (void)dismissButtonClick{

    [UIView animateWithDuration:0.25 animations:^{
        [self.musicPlayerView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.bottom.equalTo(self.musicButton);
        }];
        [self.window layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.musicPlayerView.hidden = YES;
        self.playerShow = NO;
    }];
    
}
- (void)dismissMovieInfoClick{
    self.dummyView.hidden = YES;
    self.detailViewShow = NO;
}
- (void)showMoiveInfoViewWithMovie:(MovieInfo *)movie{
    [self.dummyView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.window);
    }];
    
    [self.movieInfoView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(56);
        make.left.equalTo(self.view).offset(8);
        make.right.equalTo(self.view).offset(-8);
        make.height.mas_equalTo(600);
    }];
    [self.window layoutIfNeeded];
    self.movieInfoView.movieInfo = movie;
    self.dummyView.hidden = NO;
}
- (void)messageViewClick:(UILabel *)messageLabel indexOfCell:(NSInteger)index messageType:(enum MessageType)type{
//    NSLog(@"%ld", index);
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
//    CGRect rect = [messageLabel convertRect:messageLabel.frame toView:window];
    if (type == MessageTypeMovie){
        Message *message = self.chatMessages[index];
        MovieInfo *movie = [MovieInfo mj_objectWithKeyValues:message.contents];
        [self showMoiveInfoViewWithMovie:movie];
    }else{
        if (self.detailViewShow){
            [self hiddenDetailView];
        }else{
            self.containerView.message = self.chatMessages[index];
            self.containerView.hidden = NO;
            self.detailViewShow = YES;
            int height = 44 * 5 + 10;
//            if ((rect.origin.y + messageLabel.frame.size.height) < window.frame.size.height / 2) {
//                [self.containerView mas_remakeConstraints:^(MASConstraintMaker *make) {
//                    make.height.mas_equalTo(0);
//                    make.left.mas_equalTo(0);
//                    make.width.mas_equalTo(self.view.frame.size.width);
//                    make.top.equalTo(messageLabel.mas_bottom);
//                }];
//            }else{
//                [self.containerView mas_remakeConstraints:^(MASConstraintMaker *make) {
//                    make.height.mas_equalTo(0);
//                    make.left.mas_equalTo(0);
//                    make.width.mas_equalTo(self.view.frame.size.width);
//                    make.bottom.equalTo(messageLabel.mas_top);
//                }];
//            }
            [self.containerView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(0);
                make.left.mas_equalTo(0);
                make.width.mas_equalTo(self.view.frame.size.width);
                make.top.equalTo(self.view.mas_top).offset(64);
            }];
            [self.view layoutIfNeeded];
            [UIView animateWithDuration:0.4 animations:^{
                [self.containerView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.height.mas_equalTo(height);
                }];
                [self.view layoutIfNeeded];
            }];
        }
    }
}

// Tableview datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.chatMessages.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChatViewCell *cell = (ChatViewCell *)[tableView dequeueReusableCellWithIdentifier:@"ChatCell" forIndexPath:indexPath];
    cell.message = self.chatMessages[indexPath.row];
    cell.index = indexPath.row;
    cell.delegate = self;
    return cell;
}

- (void)scrollToBottom{
    [self.chatTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.chatMessages.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}
- (void)showHealthInfomationWithMessage:(Message *)message{
    Health *health = [Health mj_objectWithKeyValues:message.contents];
    
    health.start = [NSString stringWithFormat:@"%@ 00:00:00", health.start];
    health.end = [NSString stringWithFormat:@"%@ 23:59:59", health.end];
    switch (health.type) {
        case HealthQueryTypeHeartRate:{
            [self.healthManager authorizeHealthKit:^(BOOL success, NSError * _Nonnull error) {
                if (success) {
                    [self.healthManager getHeartRateFrom:health.start endDate:health.end heartRate:^(int minValue, int maxValue, NSError * _Nonnull error) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            message.message = [NSString stringWithFormat:@"%@,\nMax：%d，Min：%d", message.message, maxValue, minValue];
                            [self showNewMessage:message];
                        });
                    }];
                }else{}
            }];
            break;
        }
        case HealthQueryTypeStepCount:{
            [self.healthManager authorizeHealthKit:^(BOOL success, NSError * _Nonnull error) {
                if (success) {
                    [self.healthManager getStepCountFrom:health.start endDate:health.end stepCount:^(double value, NSError * _Nonnull error) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            message.message = [NSString stringWithFormat:@"%@,\nYou have walked %d steps", message.message, (int)value];
                            [self showNewMessage:message];
                        });
                    }];
                }else{}
            }];
            break;
        }
        case HealthQueryTypeEnergyBurned:{
            [self.healthManager authorizeHealthKit:^(BOOL success, NSError * _Nonnull error) {
                if (success) {
                    [self.healthManager getEnergyFrom:health.start endDate:health.end energyBurned:^(double value, NSError * _Nonnull error) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            message.message = [NSString stringWithFormat:@"%@,\nYou have burned %.2f Calorie", message.message, value];
                            [self showNewMessage:message];
                        });
                    }];
                }else{}
            }];
            break;
        }
        case HealthQueryTypeWalkingDistance:{
            [self.healthManager authorizeHealthKit:^(BOOL success, NSError * _Nonnull error) {
                if (success) {
                    [self.healthManager getWalkingDistanceFrom:health.start endDate:health.end walkingDistance:^(double value, NSError * _Nonnull error) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            message.message = [NSString stringWithFormat:@"%@,\nYou have walked %.2f km", message.message, value];
                            [self showNewMessage:message];
                        });
                    }];
                }else{}
            }];
            break;
        }
        case HealthQueryTypeSleepAnalysis:{
            [self.healthManager authorizeHealthKit:^(BOOL success, NSError * _Nonnull error) {
                if (success) {
                    [self.healthManager getSleepAnalysisFrom:health.start endDate:health.end sleepAnalysis:^(double value, NSError * _Nonnull error) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            [self showNewMessage:message];
                        });
                    }];
                }else{}
            }];
            break;
        }
        default:
            NSLog(@"Unknown type");
            break;
    }
}
// layout
- (void)setupView{
    
    BottomInputView *bottomView = [[BottomInputView alloc]init];
    bottomView.delegate = self;
    self.bottomInputView = bottomView;
    
    UITableView *chatTableView = [[UITableView alloc]init];
    [chatTableView registerClass:[ChatViewCell class] forCellReuseIdentifier:@"ChatCell"];
    chatTableView.delegate = self;
    chatTableView.dataSource = self;
    chatTableView.estimatedRowHeight = 44;
    chatTableView.allowsSelection = NO;
    chatTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    chatTableView.backgroundColor =  [UIColor colorWithRed:243/255.0 green:243/255.0 blue:243/255.0 alpha:1];
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    gestureRecognizer.numberOfTapsRequired = 1;
    gestureRecognizer.cancelsTouchesInView = NO;
    [chatTableView addGestureRecognizer:gestureRecognizer];
    self.chatTableView = chatTableView;
    
    RecordNoticeView *recordNoticeView = [[RecordNoticeView alloc]init];
    self.recordNoticeView = recordNoticeView;

    UIButton *musicButton = [UIButton buttonWithType:UIButtonTypeCustom];

    [musicButton setBackgroundColor:[UIColor colorWithRed:254/255.0 green:202/255.0 blue:28/255.0 alpha:1]];
    musicButton.layer.cornerRadius = 25;
    musicButton.layer.masksToBounds = YES;
    [musicButton setImage:[UIImage imageNamed:@"musicShow"] forState:UIControlStateNormal];
    [musicButton addTarget:self action:@selector(showMusicPlayer) forControlEvents:UIControlEventTouchDown];
    self.musicButton = musicButton;
    
    MusicPlayerView *musicPlayerView = [[MusicPlayerView alloc]init];
    musicPlayerView.delegate = self;
    self.musicPlayerView = musicPlayerView;
    musicPlayerView.hidden = YES;
    
    [self.view addSubview:bottomView];
    [self.view addSubview:chatTableView];
    [self.view addSubview:recordNoticeView];
    [self.view addSubview:musicButton];
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    self.window = window;
    NSLog(@"%@", window);
    [window addSubview:self.musicPlayerView];
    [window addSubview:self.dummyView];
    [self.dummyView addSubview:self.movieInfoView];
    
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.height.mas_equalTo(66);
    }];
    [chatTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.bottom.equalTo(bottomView.mas_top);
    }];
    [recordNoticeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.width.height.mas_equalTo(150);
    }];
    [musicButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view).offset(-20);
        make.bottom.equalTo(bottomView.mas_top).offset(-20);
        make.width.height.mas_equalTo(50);
    }];

}
- (ContainerView *)containerView{
    if (!_containerView) {
        ContainerView *view = [[ContainerView alloc]init];
        self.containerView = view;
        view.hidden = YES;
        [self.view addSubview:self.containerView];
    }
    return _containerView;
}
- (MovieInfoView *)movieInfoView{
    if (!_movieInfoView){
        MovieInfoView *view = [[MovieInfoView alloc]init];
        self.movieInfoView = view;
        view.delegate = self;
    }
    return _movieInfoView;
}
- (UIView *)dummyView{
    if (!_dummyView) {
        UIView *view = [UIView new];
        view.backgroundColor = [UIColor colorWithWhite:0.3 alpha:0.7];
        view.hidden = YES;
        self.dummyView = view;
    }
    return _dummyView;
}
@end
