//
//  ChatViewCell.m
//  RelaxBot
//
//  Created by xiongbiao on 2019/3/15.
//  Copyright © 2019年 xiongbiao. All rights reserved.
//

#import "ChatViewCell.h"
#import <Masonry/Masonry.h>
#import "UILabel+Extension.h"
#import "TimeUtil.h"
#import "DetailView.h"
#import <youtube_ios_player_helper/YTPlayerView.h>
#import "Video.h"
#import <MJExtension.h>

@interface ChatViewCell ()
@property (strong, nonatomic) UILabel_Extension *messageLabel;
@property (strong, nonatomic) UIImageView *iconView;
@property (strong, nonatomic) UILabel_Extension *timeLabel;
@property (strong, nonatomic) UITapGestureRecognizer *recognizer;
@property (strong, nonatomic) UILabel *notiLabel;
@property (strong, nonatomic) YTPlayerView *playerView;
@end

@implementation ChatViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style
                    reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor clearColor];
//        [self.contentView addSubview:self.iconView];
        [self.contentView addSubview:self.timeLabel];
        [self.contentView addSubview:self.messageLabel];
        [self.contentView addSubview:self.notiLabel];
        [self.contentView addSubview:self.playerView];
    }
    return self;
}

- (void)showMoreContent{
    if ([self.delegate respondsToSelector:@selector(messageViewClick:indexOfCell:messageType:)]) {
        [self.delegate messageViewClick:self.messageLabel indexOfCell:self.index messageType:self.message.type];
    }
}
- (void)setMessage:(Message *)message{
    _message = message;
    [self setupViewWithModel:message];
    [self layoutIfNeeded];
}

- (void)setIndex:(NSInteger)index{
    _index = index;
}

- (void)setupViewWithModel:(Message *)message{
    if (message.type == MessageTypeVideo) {
        
    }
    if (message.source == MessageSourceReceiver && (message.type == MessageTypeMusicPlaylist || message.type == MessageTypeMovie || message.type == MessageTypeMusicTrack || message.type == MessageTypeMovieList || message.type == MessageTypeMusicAlbum)){
        [self.messageLabel addGestureRecognizer:self.recognizer];
        self.messageLabel.userInteractionEnabled = YES;
        self.notiLabel.hidden = NO;
        [self.notiLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(20);
            make.top.equalTo(self.messageLabel.mas_top).offset(-5);
            make.right.equalTo(self.messageLabel.mas_right).offset(5);
        }];
    }else{
        self.messageLabel.userInteractionEnabled = NO;
        self.notiLabel.hidden = YES;
    }
    
    self.messageLabel.text = message.message;
    
    if (message.source == MessageSourceReceiver) {
        self.messageLabel.backgroundColor = [UIColor whiteColor];
        if (message.type == MessageTypeVideo) {
            Video *video = [Video mj_objectWithKeyValues:message.contents];
            NSLog(@"%@", video.videoId);
            [self.playerView loadWithVideoId:video.videoId];
            [self.playerView mas_remakeConstraints:^(MASConstraintMaker *make){
                make.left.equalTo(self.messageLabel);
                make.width.mas_equalTo(240);
                make.height.mas_equalTo(180);
                make.bottom.equalTo(self.contentView.mas_bottom).offset(-10);
            }];
            [self.messageLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.contentView).offset(10);
                make.top.equalTo(self.timeLabel.mas_bottom).offset(3);
                make.bottom.equalTo(self.playerView.mas_top);
            }];
        }else{
            [self.playerView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.messageLabel);
                make.width.mas_equalTo(0);
                make.height.mas_equalTo(0);
                make.bottom.equalTo(self.contentView.mas_bottom).offset(-10);
            }];
            [self.messageLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.contentView).offset(10);
                make.top.equalTo(self.timeLabel.mas_bottom).offset(3);
                make.bottom.equalTo(self.playerView.mas_top);
            }];
        }
    }else{
        [self.playerView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.messageLabel);
            make.width.mas_equalTo(0);
            make.height.mas_equalTo(0);
            make.bottom.equalTo(self.contentView.mas_bottom).offset(-10);
        }];
        self.messageLabel.backgroundColor = [UIColor colorWithRed:254/255.0 green:202/255.0 blue:28/255.0 alpha:1];
        [self.messageLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.contentView).offset(-10);
            make.top.equalTo(self.timeLabel.mas_bottom).offset(3);
            make.bottom.equalTo(self.playerView.mas_top);
        }];
        
    }
    if (message.showdate){
        self.timeLabel.text = [TimeUtil compareDate:message.date];
        [self.timeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(18);
            make.top.equalTo(self.contentView).offset(5);
            make.centerX.equalTo(self.contentView);
        }];
    }else{
        [self.timeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
            make.top.equalTo(self.contentView).offset(5);
            make.centerX.equalTo(self.contentView);
        }];
    }

}
- (void)layoutSubviews{
    [super layoutSubviews];
}

- (UIImageView *)iconView{
    if (!_iconView) {
        UIImageView *iconView = [[UIImageView alloc]init];
        iconView.backgroundColor = [UIColor purpleColor];
        [iconView setImage:[UIImage imageNamed:@"icon"]];
        iconView.layer.cornerRadius = 5;
        iconView.layer.masksToBounds = YES;
        self.iconView = iconView;
    }
    return _iconView;
}

- (UILabel_Extension *)timeLabel{
    if (!_timeLabel) {
        UILabel_Extension *timeLabel = [[UILabel_Extension alloc]init];
        timeLabel.edgeInsets = UIEdgeInsetsMake(0, 6, 0, 6);
        timeLabel.layer.cornerRadius = 3;
        timeLabel.layer.masksToBounds = YES;
        timeLabel.textAlignment = NSTextAlignmentCenter;
        timeLabel.font = [UIFont boldSystemFontOfSize:12];
        timeLabel.textColor = [UIColor lightGrayColor];
        timeLabel.backgroundColor = [UIColor clearColor];
        self.timeLabel = timeLabel;
    }
    return _timeLabel;
}
- (UILabel_Extension *)messageLabel{
    if (!_messageLabel) {
        UILabel_Extension *messageLabel = [[UILabel_Extension alloc]init];
        messageLabel.edgeInsets = UIEdgeInsetsMake(9, 15, 9, 15);
        messageLabel.textAlignment = NSTextAlignmentLeft;
        messageLabel.layer.cornerRadius = 5;
        messageLabel.layer.masksToBounds = YES;
        messageLabel.numberOfLines = 0;
        messageLabel.preferredMaxLayoutWidth = [UIScreen mainScreen].bounds.size.width - 59 * 2 ;
        messageLabel.font = [UIFont systemFontOfSize:17];
        self.messageLabel = messageLabel;
    }
    return _messageLabel;
}

- (UITapGestureRecognizer *)recognizer{
    if (!_recognizer) {
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showMoreContent)];
        recognizer.numberOfTapsRequired = 1;
        recognizer.cancelsTouchesInView = NO;
        self.recognizer = recognizer;
    }
    return _recognizer;
}
- (UILabel *)notiLabel{
    if (!_notiLabel) {
        UILabel *label = [[UILabel alloc]init];
        label.backgroundColor = [UIColor redColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = @"1";
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont boldSystemFontOfSize:15];
        label.hidden = YES;
        label.layer.cornerRadius = 10;
        label.layer.masksToBounds = YES;
        self.notiLabel = label;
        
    }
    return _notiLabel;
}

- (YTPlayerView *)playerView{
    if (!_playerView) {
        YTPlayerView *view = [[YTPlayerView alloc]init];
        self.playerView = view;
    }
    return _playerView;
}
@end
