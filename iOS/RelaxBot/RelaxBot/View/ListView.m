//
//  ListView.m
//  RelaxBot
//
//  Created by xiongbiao on 2019/4/7.
//  Copyright © 2019年 xiongbiao. All rights reserved.
//

#import "ListView.h"
#import "PlaylistCell.h"
#import <Masonry/Masonry.h>
#import <AFNetworking.h>
#import "Message.h"
#import "Config.h"
#import <MJExtension.h>
#import <DGActivityIndicatorView.h>

@interface ListView () <UITableViewDelegate, UITableViewDataSource, PlaylistCellDelegate>
@property (nonatomic, strong) UITableView *listTableView;
@property (nonatomic, strong) NSMutableArray *tracks;
@property (nonatomic, copy) NSString *uri;
@property (nonatomic, assign) enum MessageType *listType;
@property (nonatomic, strong) DGActivityIndicatorView *activityView;
@end

@implementation ListView


- (instancetype)init{
    if (self = [super init]) {
        self.backgroundColor = [UIColor colorWithWhite:0.4 alpha:0.8];
        [self addSubview:self.listTableView];
        [self addSubview:self.activityView];
    }
    return self;
}

- (void)setPlaylistDetail:(NSDictionary *)playlistDetail{
    _playlistDetail = playlistDetail;
    self.uri = playlistDetail[@"playlist_id"];
    [self requestData];
//    [self.listTableView reloadData];
}

- (void)requestData{
    [self showLoadingView];
    NSLog(@"发送一次消息");
    NSLog(@"%@", self.playlistDetail);
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:kPlaylistDetailUrl parameters:self.playlistDetail progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        Message *message = [Message mj_objectWithKeyValues:responseObject];
        Playlists *playlists = [Playlists mj_objectWithKeyValues:message.contents];
        self.tracks = playlists.playlists;
        NSLog(@"%lu", self.tracks.count);
        [self.listTableView reloadData];
        [self hiddenLoadingView];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self hiddenLoadingView];
    }];
}
- (void)showLoadingView{
    self.listTableView.hidden = YES;
    self.activityView.hidden = NO;
    [self.activityView startAnimating];
}
- (void)hiddenLoadingView{
    self.activityView.hidden = YES;
    [self.activityView stopAnimating];
    self.listTableView.hidden = NO;
}
- (void)layoutSubviews{
    [self.listTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.equalTo(self);
    }];
    [self.activityView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.tracks count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    PlaylistCell *cell = (PlaylistCell *)[tableView dequeueReusableCellWithIdentifier:@"trackCell" forIndexPath:indexPath];
    cell.playlist = self.tracks[indexPath.row];
    cell.index = indexPath.row + 1;
    return cell;
}
//- (void)playlistPlayButtonClick:(NSString *)playUri{
//    NSLog(@"%@", playUri);
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSLog(@"%@", self.uri);
    NSLog(@"%@", [NSString stringWithFormat:@"%ld", indexPath.row]);
    NSDictionary *dict = @{
                           @"uri" : self.uri,
                           @"index" : [NSString stringWithFormat:@"%ld", indexPath.row],
                           @"list_type" : self.playlistDetail[@"playlist_type"]
                           };
    [[NSNotificationCenter defaultCenter] postNotificationName:@"playPlaylist" object:self.tracks userInfo:dict];
}
- (UITableView *)listTableView{
    if (!_listTableView) {
        UITableView *tableView = [[UITableView alloc]init];
        tableView.backgroundColor = [UIColor clearColor];
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.hidden = YES;
        [tableView registerClass:[PlaylistCell class] forCellReuseIdentifier:@"trackCell"];
        self.listTableView = tableView;
        
    }
    return _listTableView;
}
- (DGActivityIndicatorView *)activityView{
    if (!_activityView) {
        DGActivityIndicatorView *activityView = [[DGActivityIndicatorView alloc]initWithType:DGActivityIndicatorAnimationTypeLineScale tintColor:systemColor size:50.0f];
        activityView.hidden = YES;
        self.activityView = activityView;
    }
    return _activityView;
}
@end
