//
//  MusicController.m
//  RelaxBot
//
//  Created by xiongbiao on 2019/4/6.
//  Copyright © 2019年 xiongbiao. All rights reserved.
//

#import "MusicController.h"
#import <Masonry/Masonry.h>
#import <AFNetworking.h>
#import <MJExtension.h>
#import "Config.h"
#import "TimeUtil.h"
#import <DGActivityIndicatorView.h>
#import <youtube_ios_player_helper/YTPlayerView.h>

@interface MusicController () <UIScrollViewDelegate>
@end

@implementation MusicController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    DGActivityIndicatorView *activityView = [[DGActivityIndicatorView alloc]initWithType:DGActivityIndicatorAnimationTypeLineScale tintColor:[UIColor yellowColor] size:20.0f];
    [self.view addSubview:activityView];
    [activityView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.width.height.mas_equalTo(200);
    }];
    [activityView startAnimating];
//    YTPlayerView *view = [[YTPlayerView alloc]init];
//    view.frame = CGRectMake(0, 64, 240, 180);
//    [self.view addSubview:view];
//    [view loadWithVideoId:@"0LHxvxdRnYc"];
}

@end
