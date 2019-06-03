//
//  AppDelegate.m
//  RelaxBot
//
//  Created by xiongbiao on 2019/3/13.
//  Copyright © 2019年 xiongbiao. All rights reserved.
//

#import "AppDelegate.h"
#import "Controller/LoginViewController.h"
#import "Controller/ChatViewController.h"
#import "Controller/MusicController.h"
#import <Speech/Speech.h>
#import <SpotifyAuthentication/SpotifyAuthentication.h>
#import <SpotifyMetadata/SpotifyMetadata.h>
#import <SpotifyAudioPlayback/SpotifyAudioPlayback.h>
#import "Utilities/Config.h"


@interface AppDelegate ()
@property (nonatomic, strong) LoginViewController *loginViewController;
@property (nonatomic, strong) ChatViewController *chatViewController;
@property (nonatomic, strong) MusicController *musicController;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    
    SPTAuth *auth = [SPTAuth defaultInstance];
    auth.clientID = @kClientId;
    auth.redirectURL = [NSURL URLWithString:@kCallbackURL];
    auth.tokenSwapURL = [NSURL URLWithString:kTokenSwapServiceURL];
    auth.tokenRefreshURL = [NSURL URLWithString:kTokenRefreshServiceURL];
    auth.sessionUserDefaultsKey = @kSessionUserDefaultsKey;
    auth.requestedScopes = @[SPTAuthStreamingScope];
    
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    self.chatViewController = [ChatViewController new];
    self.musicController = [MusicController new];
    self.loginViewController = [LoginViewController new];
//    [self.loginViewController.view setBackgroundColor:[UIColor whiteColor]];
   
    [[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:254/255.0 green:202/255.0 blue:28/255.0 alpha:1]];
    self.window.rootViewController = self.loginViewController;
//    self.window.rootViewController = self.loginViewController;
    [self.window makeKeyAndVisible];
    // Override point for customization after application launch.
    
    return YES;
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    SPTAuth *auth = [SPTAuth defaultInstance];
    
    SPTAuthCallback authCallback = ^(NSError *error, SPTSession *session) {
        // This is the callback that'll be triggered when auth is completed (or fails).
        
        if (error) {
            NSLog(@"*** Auth error: %@", error);
        } else {
            auth.session = session;
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"sessionUpdated" object:self];
    };
    
    /*
     Handle the callback from the authentication service. -[SPAuth -canHandleURL:]
     helps us filter out URLs that aren't authentication URLs (i.e., URLs you use elsewhere in your application).
     */
    
    if ([auth canHandleURL:url]) {
        [auth handleAuthCallbackWithTriggeredAuthURL:url callback:authCallback];
        return YES;
    }
    
    return NO;
}
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
