//
//  BottomInputView.m
//  RelaxBot
//
//  Created by xiongbiao on 2019/3/27.
//  Copyright © 2019年 xiongbiao. All rights reserved.
//

#import "BottomInputView.h"
#import <Masonry/Masonry.h>

@interface BottomInputView () <UITextFieldDelegate>

@property (nonatomic, weak) UIButton *typeButton;
@property (nonatomic, weak) UIButton *voiceButton;
@property (nonatomic, assign) int buttonFlag;

@end

@implementation BottomInputView

- (instancetype)init
{
    self = [super init];
    if (self) {
    
        
        self.backgroundColor = [UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1];
        self.buttonFlag = 0;
        UIButton *typeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        //    typeButton.backgroundColor = [UIColor greenColor];
        [typeButton setBackgroundImage:[UIImage imageNamed:@"Voice"] forState:UIControlStateNormal];
        [typeButton setBackgroundImage:[UIImage imageNamed:@"VoiceHL"] forState:UIControlStateSelected];
        [typeButton addTarget:self action:@selector(typeButtonClick:) forControlEvents:UIControlEventTouchDown];
        self.typeButton = typeButton;
        
        UIButton *voiceButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [voiceButton setBackgroundImage:[UIImage imageNamed:@"VoiceInput"] forState:UIControlStateNormal];
        voiceButton.hidden = YES;
        [voiceButton addTarget:self action:@selector(startRecording:) forControlEvents:UIControlEventTouchDown];
        [voiceButton addTarget:self action:@selector(releaseInside:) forControlEvents:UIControlEventTouchUpInside];
        [voiceButton addTarget:self action:@selector(releaseOutside:) forControlEvents:UIControlEventTouchUpOutside];
        [voiceButton addTarget:self action:@selector(dragUp:) forControlEvents:UIControlEventTouchDragOutside];
        [voiceButton addTarget:self action:@selector(dragDown:) forControlEvents:UIControlEventTouchDragInside];
        self.voiceButton = voiceButton;
        
        UITextField *textInputField = [[UITextField alloc]init];
        textInputField.layer.cornerRadius = 5;
        textInputField.layer.masksToBounds = YES;
        textInputField.hidden = NO;
        textInputField.backgroundColor = [UIColor whiteColor];
        textInputField.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, 0)];
        textInputField.leftViewMode = UITextFieldViewModeAlways;
        textInputField.delegate = self;
        textInputField.returnKeyType = UIReturnKeySend;
        [textInputField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
        self.textInputField = textInputField;
        
        [self addSubview:self.voiceButton];
        [self addSubview:self.typeButton];
        [self addSubview:self.textInputField];
    }
    return self;
}


// text field

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField endEditing:YES];
    if ([self.delegate respondsToSelector:@selector(bottomInputTextFieldShouldReturn:)]){
        [self.delegate bottomInputTextFieldShouldReturn:textField];
    }
    return YES;
}

// button action
- (void)startRecording:(UIButton *)recordButton{
//    NSLog(@"start Recording");
    if ([self.delegate respondsToSelector:@selector(recordButtonTouchDown:)]) {
        [self.delegate recordButtonTouchDown:recordButton];
    }
}
- (void)releaseInside:(UIButton *)recordButton {
//    NSLog(@"release inside");
    if ([self.delegate respondsToSelector:@selector(recordButtonReleaseInside:)]){
        [self.delegate recordButtonReleaseInside:recordButton];
    }
}

- (void)dragUp:(UIButton *)recordButton{
//    NSLog(@"drag up");
    if ([self.delegate respondsToSelector:@selector(recordButtonDragUp:)]){
        [self.delegate recordButtonDragUp:recordButton];
    }
}
- (void)dragDown:(UIButton *)recordButton{
//    NSLog(@"drag down");
    if ([self.delegate respondsToSelector:@selector(recordButtonDragDown:)]){
        [self.delegate recordButtonDragDown:recordButton];
    }
}
- (void)releaseOutside:(UIButton *)recordButton{
//    NSLog(@"release outside");
    if ([self.delegate respondsToSelector:@selector(recordButtonReleaseOutside:)]){
        [self.delegate recordButtonReleaseOutside:recordButton];
    }
}

- (void)typeButtonClick:(UIButton *)button{
    if (self.buttonFlag == 0) {
        [self.textInputField resignFirstResponder];
        //        button.backgroundColor = [UIColor blueColor];
        [button setBackgroundImage:[UIImage imageNamed:@"Keyboard"] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"KeyboardHL"] forState:UIControlStateSelected];
        self.buttonFlag = 1;
        self.voiceButton.hidden = NO;
        self.textInputField.hidden = YES;
    }else{
        //        button.backgroundColor = [UIColor greenColor];
        [button setBackgroundImage:[UIImage imageNamed:@"Voice"] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"VoiceHL"] forState:UIControlStateSelected];
        self.buttonFlag = 0;
        self.voiceButton.hidden = YES;
        self.textInputField.hidden = NO;
        [self.textInputField becomeFirstResponder];
    }
}

- (void)layoutSubviews{
    [self.voiceButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        //        make.right.equalTo(bottomView).offset(-15);
        //        make.centerY.equalTo(bottomView);
        make.height.width.mas_equalTo(66);
    }];
    [self.typeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.left.mas_equalTo(12);
        make.width.height.mas_equalTo(44);
    }];
    
    [self.textInputField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(44);
        make.centerY.equalTo(self);
        make.left.equalTo(self.typeButton.mas_right).offset(10);
        make.right.equalTo(self.mas_right).offset(-25);
    }];
}

@end
