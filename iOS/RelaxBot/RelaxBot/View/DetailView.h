//
//  DetailView.h
//  RelaxBot
//
//  Created by xiongbiao on 2019/4/7.
//  Copyright © 2019年 xiongbiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Message.h"

NS_ASSUME_NONNULL_BEGIN

@protocol DetailViewDelegate <NSObject>
@optional
- (void)selectDetailCellWithIndexPath:(NSIndexPath *)indexPath uri:(NSString *)uri;
@end

@interface DetailView : UIView
@property (nonatomic, strong) Message *message;
@property (nonatomic, weak) id <DetailViewDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
