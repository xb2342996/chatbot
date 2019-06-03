//
//  ContentScrollView.m
//  RelaxBot
//
//  Created by xiongbiao on 2019/4/8.
//  Copyright © 2019年 xiongbiao. All rights reserved.
//

#import "ContentScrollView.h"
#import "DetailView.h"
#import "ListView.h"
#import <Masonry/Masonry.h>


#define ScreenWidth [UIApplication sharedApplication].keyWindow.frame.size.width

@interface ContentScrollView () <DetailViewDelegate>
@property (nonatomic, weak) DetailView *detailView;
@property (nonatomic, weak) ListView *listView;
@property (nonatomic, weak) UIView *view;
@end

@implementation ContentScrollView

- (instancetype)init{
    if (self = [super init]) {
        self.backgroundColor = [UIColor clearColor];
        self.pagingEnabled = YES;
        self.showsVerticalScrollIndicator   = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.contentSize = CGSizeMake(ScreenWidth * 2, 0);
        self.bounces = NO;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(detailViewHidden) name:@"detailViewHidden" object:nil];
    }
    return self;
}
- (void)setMessage:(Message *)message{
    _message = message;
    self.detailView.message = message;
}
- (void)layoutSubviews{
    self.detailView.frame = CGRectMake(5, 5, ScreenWidth - 10, 220);
    self.listView.frame = CGRectMake(ScreenWidth + 5, 5, ScreenWidth - 10, 220);
}
- (void)selectDetailCellWithIndexPath:(NSIndexPath *)indexPath uri:(NSString *)uri{
//    NSLog(@"%@", NSStringFromCGPoint(self.contentOffset));
    [self setContentOffset:CGPointMake(ScreenWidth, self.contentOffset.y) animated:YES];
    self.scrollEnabled = YES;
    self.listView.playlistDetail = @{
                                     @"playlist_id" : uri,
                                     @"playlist_type" : @(self.message.type)
                                     };

}
- (void)detailViewHidden{
    [self setContentOffset:CGPointMake(0, self.contentOffset.y) animated:NO];
    self.scrollEnabled = NO;
}
- (DetailView *)detailView{
    if (!_detailView) {
        DetailView *detailView = [[DetailView alloc]init];
        detailView.delegate = self;
        detailView.layer.cornerRadius = 12;
        detailView.layer.masksToBounds= YES;
        [self addSubview:detailView];
        self.detailView = detailView;
        
    }
    return _detailView;
}
- (ListView *)listView{
    if (!_listView) {
        ListView *listView = [[ListView alloc]init];
        listView.layer.cornerRadius = 12;
        listView.layer.masksToBounds= YES;
        self.listView = listView;
        [self addSubview:listView];
        
    }
    return _listView;
}
@end
