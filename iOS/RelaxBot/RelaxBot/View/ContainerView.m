//
//  ContainerView.m
//  RelaxBot
//
//  Created by xiongbiao on 2019/4/8.
//  Copyright © 2019年 xiongbiao. All rights reserved.
//

#import "ContainerView.h"
#import "ContentScrollView.h"
#import <Masonry/Masonry.h>

@interface ContainerView () <UIScrollViewDelegate>
@property (nonatomic, weak) ContentScrollView *contentScrollView;
@end
@implementation ContainerView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}
- (void)setMessage:(Message *)message{
    _message = message;
    self.contentScrollView.message = message;
}

- (void)layoutSubviews{
    [self.contentScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.equalTo(self);
    }];
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
//    NSLog(@"%@", NSStringFromCGPoint(scrollView.contentOffset));
    if (scrollView.contentOffset.x == 0){
        scrollView.scrollEnabled = NO;
    }else{
        scrollView.scrollEnabled = YES;
    }
}
- (ContentScrollView *)contentScrollView{
    if (!_contentScrollView) {
        ContentScrollView *scrollView = [[ContentScrollView alloc]init];
        scrollView.delegate = self;
        self.contentScrollView = scrollView;
        [self addSubview:self.contentScrollView];
    }
    return _contentScrollView;
}
@end
