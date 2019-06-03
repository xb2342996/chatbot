//
//  RecordNoticeView.m
//  RelaxBot
//
//  Created by xiongbiao on 2019/3/27.
//  Copyright © 2019年 xiongbiao. All rights reserved.
//

#import "RecordNoticeView.h"
#import <Masonry/Masonry.h>

@interface RecordNoticeView ()
@property (nonatomic, weak) UIImageView *recordBkg;
@property (nonatomic, weak) UILabel *recordLabel;
@end

@implementation RecordNoticeView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.hidden = YES;
        self.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.6];
        self.layer.cornerRadius = 10;
        self.layer.masksToBounds = YES;
        UIImageView *recordBkg = [UIImageView new];
        recordBkg.image = [UIImage imageNamed:@"RecordingBkg"];
        UILabel *recordLabel = [UILabel new];
        recordLabel.text = @"Swipe, Cancel";
        recordLabel.textAlignment = NSTextAlignmentCenter;
        recordLabel.layer.cornerRadius = 5;
        recordLabel.layer.masksToBounds = YES;
        recordLabel.textColor = [UIColor whiteColor];
        self.recordBkg = recordBkg;
        self.recordLabel = recordLabel;
        
        [self addSubview:recordBkg];
        [self addSubview:recordLabel];
    }
    return self;
}
- (void)recording{
    self.recordLabel.text = @"Swipe, Cancel";
    self.recordBkg.image = [UIImage imageNamed:@"RecordingBkg"];
}
- (void)recordButtonDragUp{
    self.recordLabel.text = @"Release, Cancel";
    self.recordLabel.backgroundColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.3];
    self.recordBkg.image = [UIImage imageNamed:@"RecordCancel"];
}
- (void)recordButtonDragDown{
    self.recordLabel.text = @"Swipe, Cancel";
    self.recordLabel.backgroundColor = [UIColor clearColor];
    self.recordBkg.image = [UIImage imageNamed:@"RecordingBkg"];
}
- (void)layoutSubviews{
    [self.recordBkg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.equalTo(self);
        
    }];
    [self.recordLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.right.equalTo(self).offset(-5);
        make.left.equalTo(self).offset(5);
        make.height.mas_equalTo(30);
    }];
}
@end
