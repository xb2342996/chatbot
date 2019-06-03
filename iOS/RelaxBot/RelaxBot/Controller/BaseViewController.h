//
//  BaseViewController.h
//  RelaxBot
//
//  Created by xiongbiao on 2019/4/20.
//  Copyright © 2019 xiongbiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Config.h"
#import <Masonry/Masonry.h>
#import <AFNetworking/AFNetworking.h>
#import <DGActivityIndicatorView/DGActivityIndicatorView.h>
#import <MJExtension/MJExtension.h>

NS_ASSUME_NONNULL_BEGIN

@interface BaseViewController : UIViewController
- (void)POST:(NSString*)url parameters:(nullable id)parameters success:(nullable void (^)(id _Nullable responseObject))success failure:(nullable void (^)(NSError * _Nonnull error))failure;
- (UIAlertController *)alertControllerWithTitle:(NSString *)title message:(NSString*)message actionTitle:(NSString *)actionTitle;
- (void)keyboardShow:(NSNotification *)noti;
- (void)keyboardHide:(NSNotification *)noti;
@end

NS_ASSUME_NONNULL_END
