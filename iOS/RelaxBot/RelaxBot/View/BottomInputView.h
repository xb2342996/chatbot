//
//  BottomInputView.h
//  RelaxBot
//
//  Created by xiongbiao on 2019/3/27.
//  Copyright © 2019年 xiongbiao. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol BottomInputViewDelegate <NSObject>

- (void)bottomInputTextFieldShouldReturn:(UITextField *)textField;
- (void)recordButtonReleaseInside:(UIButton *)recordButton;
- (void)recordButtonReleaseOutside:(UIButton *)recordButton;
- (void)recordButtonDragUp:(UIButton *)recordButton;
- (void)recordButtonDragDown:(UIButton *)recordButton;
- (void)recordButtonTouchDown:(UIButton *)recordButton;
@end


@interface BottomInputView : UIView
@property (nonatomic, weak) id <BottomInputViewDelegate> delegate;
@property (nonatomic, weak) UITextField *textInputField;
@end

NS_ASSUME_NONNULL_END
