//
//  PlaylistCell.m
//  RelaxBot
//
//  Created by xiongbiao on 2019/4/6.
//  Copyright © 2019年 xiongbiao. All rights reserved.
//

#import "PlaylistCell.h"
#import <Masonry/Masonry.h>
#import <SDWebImage.h>

@interface PlaylistCell ()
@property (copy, nonatomic) NSString *playlistUri;
@property (weak, nonatomic) UIImageView *coverView;
@property (weak, nonatomic) UILabel *title;
@property (weak, nonatomic) UIButton *playButton;
@property (weak, nonatomic) UIView *seperateLine;
@property (strong, nonatomic) UILabel *indexLabel;
@end

@implementation PlaylistCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    self.backgroundColor = [UIColor clearColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self addSubview:self.indexLabel];
    self.messageType = MessageTypeMusicTrack;
    return self;
}
- (void)setMessageType:(enum MessageType)messageType{
    _messageType = messageType;
}

- (void)setPlaylist:(Playlist *)playlist{
    _playlist = playlist;
    [self setupViewWithPlaylist:playlist];
}
- (void)setIndex:(NSInteger)index{
    self.indexLabel.text = [NSString stringWithFormat:@"%ld.", (long)index];
}
- (void)setupViewWithPlaylist:(Playlist *)playlist{
    self.playlistUri = playlist.uri;
    self.title.text = playlist.name;
    if (![playlist.image isEqualToString:@""] && self.messageType != MessageTypeMovie){
        [self.coverView sd_setImageWithURL:[NSURL URLWithString:playlist.image] placeholderImage:nil];
    }
}

- (void)playPlaylist:(UIButton *)playButton{
    
    if ([self.delegate respondsToSelector:@selector(playlistPlayButtonClick:totalTracks:)]) {
        [self.delegate playlistPlayButtonClick:self.playlistUri totalTracks:[self.playlist.total intValue]];
    }
}

- (UIImageView *)coverView{
    if (!_coverView) {
        UIImageView *coverView = [[UIImageView alloc]init];
        coverView.backgroundColor = [UIColor redColor];
        coverView.layer.cornerRadius = 5;
        coverView.layer.masksToBounds = YES;
        self.coverView = coverView;
        [self addSubview:self.coverView];
    }
    return _coverView;
}
- (UILabel *)title{
    if (!_title) {
        UILabel *title = [[UILabel alloc]init];
        
        title.textAlignment = NSTextAlignmentLeft;
        title.textColor = [UIColor whiteColor];
        title.font = [UIFont boldSystemFontOfSize:16];
//        title.backgroundColor = [UIColor yellowColor];
        self.title = title;
        [self addSubview:self.title];
    }
    return _title;
}
- (UILabel *)indexLabel{
    if (!_indexLabel) {
        UILabel *label = [[UILabel alloc]init];
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont boldSystemFontOfSize:16];
        self.indexLabel = label;
    }
    return _indexLabel;
}
- (UIView *)seperateLine{
    if (!_seperateLine) {
        UIView *line = [[UIView alloc]init];
        line.backgroundColor = [UIColor lightGrayColor];
        [self addSubview:line];
        self.seperateLine = line;
    }
    return _seperateLine;
}
- (UIButton *)playButton{
    if (!_playButton) {
        UIButton *playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [playButton setImage:[UIImage imageNamed:@"list_play"] forState:UIControlStateNormal];
//        playButton.backgroundColor = [UIColor blueColor];
        [playButton addTarget:self action:@selector(playPlaylist:) forControlEvents:UIControlEventTouchDown];
        self.playButton = playButton;
        [self addSubview:self.playButton];
    }
    return _playButton;
}
- (void)layoutSubviews{
    [self.indexLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.height.equalTo(self.coverView);
        make.left.equalTo(self.coverView.mas_right).offset(5);
    }];
    [self.title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.height.equalTo(self.coverView);
        make.left.equalTo(self.indexLabel.mas_right).offset(5);
        make.right.lessThanOrEqualTo(self.mas_right).offset(-49);
    }];
    if (self.messageType == MessageTypeMovieList || self.messageType == MessageTypeMusicTrack) {
        [self.coverView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(0);
            make.height.mas_equalTo(34);
            make.top.equalTo(self).offset(5);
            make.left.equalTo(self).offset(10);
        }];
    } else {
        [self.coverView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(34);
            make.top.equalTo(self).offset(5);
            make.left.equalTo(self).offset(10);
        }];
    }
    if (self.messageType == MessageTypeMusicPlaylist || self.messageType == MessageTypeMusicAlbum){
        [self.playButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self).offset(-10);
            make.top.equalTo(self).offset(5);
            make.bottom.equalTo(self).offset(-5);
            make.width.mas_equalTo(34);
        }];
    }else{
        [self.playButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self).offset(-10);
            make.top.equalTo(self).offset(5);
            make.bottom.equalTo(self).offset(-5);
            make.width.mas_equalTo(0);
        }];
    }
    [self.seperateLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.indexLabel);
        make.bottom.right.equalTo(self);
        make.height.mas_equalTo(0.5);
    }];
}
@end
