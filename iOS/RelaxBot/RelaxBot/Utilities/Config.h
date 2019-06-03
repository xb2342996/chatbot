//
//  Config.h
//  ChatDemo
//
//  Created by xiongbiao on 2019/3/24.
//  Copyright © 2019年 xiongbiao. All rights reserved.
//

#ifndef Config_h
#define Config_h

#define kServerUrl @"http://10.0.0.44:5000"
// Your client ID
#define kClientId "1861ba8bada044718fd946a732425af3"

// Your applications callback URL
#define kCallbackURL "relax-bot-demo://spotify-login-callback"

// The URL to your token swap endpoint
// If you don't provide a token swap service url the login will use implicit grant tokens, which means that your user will need to sign in again every time the token expires.

#define kTokenSwapServiceURL [kServerUrl stringByAppendingString:@"/swap"]

// The URL to your token refresh endpoint
// If you don't provide a token refresh service url, the user will need to sign in again every time their token expires.

#define kTokenRefreshServiceURL [kServerUrl stringByAppendingString:@"/refresh"]

#define kSessionUserDefaultsKey "SpotifySession"

#define kLoginUrl [kServerUrl stringByAppendingString:@"/login"]
#define kSignupUrl [kServerUrl stringByAppendingString:@"/register"]
#define kModifyUrl [kServerUrl stringByAppendingString:@"/modify_email"]
#define kMessageUrl [kServerUrl stringByAppendingString:@"/message"]
#define kMovieUrl [kServerUrl stringByAppendingString:@"/movie"]
#define kVideoUrl [kServerUrl stringByAppendingString:@"/video"]
#define kPlaylistUrl [kServerUrl stringByAppendingString:@"/playlists"]
#define kAlbumUrl [kServerUrl stringByAppendingString:@"/albums"]
#define kTopTenUrl [kServerUrl stringByAppendingString:@"/artist_top_song"]
#define kPlaylistDetailUrl [kServerUrl stringByAppendingString:@"/playlist_detail"]
#define kAlbumDetailUrl [kServerUrl stringByAppendingString:@"/album_detail"]
#define kRecommendationUrl [kServerUrl stringByAppendingString:@"/recommendation"]
#define kSwitchUrl [kServerUrl stringByAppendingString:@"/switch"]
#define kLikeUrl [kServerUrl stringByAppendingString:@"/like"]

#define systemColor [UIColor colorWithRed:254/255.0 green:202/255.0 blue:28/255.0 alpha:1]
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

#endif /* Config_h */
