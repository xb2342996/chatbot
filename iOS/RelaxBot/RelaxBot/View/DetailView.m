//
//  DetailView.m
//  RelaxBot
//
//  Created by xiongbiao on 2019/4/7.
//  Copyright © 2019年 xiongbiao. All rights reserved.
//

#import "DetailView.h"
#import "PlaylistCell.h"
#import <Masonry/Masonry.h>
#import <MJExtension.h>
#import <AFNetworking.h>
#import "Config.h"
#import "Movie.h"
#import "Video.h"

@interface DetailView () <UITableViewDelegate, UITableViewDataSource, PlaylistCellDelegate>
@property (nonatomic, weak) UITableView *albumTableView;
@property (nonatomic, strong) NSMutableArray *playlists;
@property (nonatomic, assign) enum MessageType infoType;
@end

@implementation DetailView

- (instancetype)init{
    if (self = [super init]) {
        self.backgroundColor = [UIColor colorWithWhite:0.4 alpha:0.8];
    }
    return self;
}

- (void)setMessage:(Message *)message{
    _message = message;
    NSLog(@"%d", message.type);
    Playlists *playlists = [Playlists mj_objectWithKeyValues:message.contents];
    self.playlists = playlists.playlists;
    [self.albumTableView reloadData];
}
- (void)layoutSubviews{
    [self.albumTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.equalTo(self);
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.playlists count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    PlaylistCell *cell = (PlaylistCell *)[tableView dequeueReusableCellWithIdentifier:@"infoCell" forIndexPath:indexPath];
    cell.playlist = self.playlists[indexPath.row];
    cell.index = indexPath.row + 1;
    cell.messageType = self.message.type;
    cell.delegate = self;
    return cell;
}
- (void)playlistPlayButtonClick:(NSString *)playUri totalTracks:(int)totalTracks{
    NSLog(@"点击播放按钮 %@", playUri);
    NSLog(@"一共: %d", totalTracks);
    NSLog(@"随机: %d", arc4random_uniform(totalTracks));
    if (totalTracks != 0) {
        NSDictionary *dict = @{
                               @"uri" : playUri,
                               @"index" :[NSString stringWithFormat:@"%d", arc4random_uniform(totalTracks)],
                               @"list_type" : @(self.message.type)
                               };
        [[NSNotificationCenter defaultCenter] postNotificationName:@"playPlaylist" object:nil userInfo:dict];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    Playlist *playlist = self.playlists[indexPath.row];
    if (self.message.type == MessageTypeMusicPlaylist || self.message.type == MessageTypeMusicAlbum){
        if ([self.delegate respondsToSelector:@selector(selectDetailCellWithIndexPath:uri:)]) {
            [self.delegate selectDetailCellWithIndexPath:indexPath uri:playlist.uri];
        }
    } else if (self.message.type == MessageTypeMusicTrack){
        
        NSDictionary *dict = @{
                               @"uri" : playlist.uri,
                               @"index" : [NSString stringWithFormat:@"%ld", indexPath.row],
                               @"list_type" : @(self.message.type)
                               };
        [[NSNotificationCenter defaultCenter] postNotificationName:@"playPlaylist" object:nil userInfo:dict];
    } else if (self.message.type == MessageTypeMovieList){
        NSString *year = [playlist.name substringWithRange:NSMakeRange([playlist.name length] - 5, 4)];
        NSString *name = [playlist.name substringWithRange:NSMakeRange(0, [playlist.name length] - 7)];
        NSLog(@"moviename: %@, year: %@", name, year);
        if ([playlist.uri isEqualToString:@"trailer"]){
            NSDictionary *param = @{
                                    @"movie" : name,
                                    @"year" : year
                                    };
            AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
            [manager POST:kVideoUrl parameters:param progress:^(NSProgress * _Nonnull uploadProgress) {
                
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                Message *message = [Message mj_objectWithKeyValues:responseObject];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"videoShowNotification" object:message];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                
            }];
        }else{
            NSDictionary *param = @{
                                   @"movie" : name,
                                   @"type" : playlist.uri,
                                   @"year" : year
                                   };
            AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
            [manager POST:kMovieUrl parameters:param progress:^(NSProgress * _Nonnull uploadProgress) {
                
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                Message *message = [Message mj_objectWithKeyValues:responseObject];
                MovieInfo *movie = [MovieInfo mj_objectWithKeyValues:message.contents];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"movieInfoShowNotification" object:movie];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                
            }];
        }
    }
}

- (UITableView *)albumTableView{
    if (!_albumTableView) {
        UITableView *tableView = [[UITableView alloc]init];
        tableView.backgroundColor = [UIColor clearColor];
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.delegate = self;
        tableView.dataSource = self;
        [tableView registerClass:[PlaylistCell class] forCellReuseIdentifier:@"infoCell"];
        self.albumTableView = tableView;
        [self addSubview:self.albumTableView];
    }
    return _albumTableView;
}
- (NSMutableArray *)playlists{
    if (!_playlists) {
        _playlists = [NSMutableArray array];
    }
    return _playlists;
}
@end
