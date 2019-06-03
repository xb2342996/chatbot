//
//  ContentScrollView.h
//  RelaxBot
//
//  Created by xiongbiao on 2019/4/8.
//  Copyright © 2019年 xiongbiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Message.h"

NS_ASSUME_NONNULL_BEGIN

@interface ContentScrollView : UIScrollView
@property (nonatomic, strong) Message *message;
@end

NS_ASSUME_NONNULL_END
