//
//  ChatViewCell.h
//  RelaxBot
//
//  Created by xiongbiao on 2019/3/15.
//  Copyright © 2019年 xiongbiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Message.h"
NS_ASSUME_NONNULL_BEGIN

@protocol ChatCellDelegate <NSObject>
- (void)messageViewClick:(UILabel *)messageLabel indexOfCell:(NSInteger)index messageType:(enum MessageType)type;
@end
@interface ChatViewCell : UITableViewCell
@property (nonatomic, strong) Message *message;
@property (nonatomic, weak) id <ChatCellDelegate> delegate;
@property (nonatomic, assign) NSInteger index;
@end

NS_ASSUME_NONNULL_END
