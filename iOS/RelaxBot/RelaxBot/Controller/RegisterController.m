//
//  RegisterController.m
//  RelaxBot
//
//  Created by xiongbiao on 2019/4/19.
//  Copyright © 2019 xiongbiao. All rights reserved.
//

#import "RegisterController.h"
#import "Regx.h"
#import "ChatViewController.h"
#import "User.h"

#define kCornerRadius 22
#define kBorderWidth 2

@interface RegisterController () <UITextFieldDelegate>
@property (nonatomic, strong) UILabel *signupLabel;
@property (nonatomic, strong) UITextField *username;
@property (nonatomic, strong) UITextField *password;
@property (nonatomic, strong) UITextField *email;
@property (nonatomic, strong) UITextField *confirmPwd;
@property (nonatomic, strong) UIButton *registerButton;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) NSMutableDictionary *param;
@property (nonatomic, copy) NSString *usernameString;
@property (nonatomic, copy) NSString *passwordString;
@property (nonatomic, copy) NSString *emailString;
@property (nonatomic, copy) NSString *confirmString;
@property (nonatomic, strong) DGActivityIndicatorView *activityView;
@property (nonatomic, strong) UILabel *activityLabel;
@end

@implementation RegisterController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithRed:243/255.0 green:243/255.0 blue:243/255.0 alpha:1];
    
    self.param = [[NSMutableDictionary alloc]init];
    [self.view addSubview:self.signupLabel];
    [self.view addSubview:self.username];
    [self.view addSubview:self.password];
    [self.view addSubview:self.email];
    [self.view addSubview:self.confirmPwd];
    [self.view addSubview:self.registerButton];
    [self.view addSubview:self.cancelButton];
    [self.view addSubview:self.activityView];
    [self.activityView addSubview:self.activityLabel];
    
    [self layout];
}
- (void)registerButtonClick:(UIButton *)button{

    if ([self.usernameString isEqualToString:@""] || self.usernameString == nil){
        UIAlertController *alert = [self alertControllerWithTitle:@"Error" message:@"Username cannot be Empty." actionTitle:@"OK"];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }

    if (![Regx validateEmail:self.emailString]) {

        UIAlertController *alert = [self alertControllerWithTitle:@"Error" message:@"E-mail format is incorrect." actionTitle:@"OK"];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    if (![Regx checkPassword:self.passwordString]){
        NSLog(@"密码格式不对");
        UIAlertController *alert = [self alertControllerWithTitle:@"Error" message:@"Password format is incorrect." actionTitle:@"OK"];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    if (![self.passwordString isEqualToString:self.confirmString]) {
        NSLog(@"%@ %@", self.passwordString, self.confirmString);
        UIAlertController *alert = [self alertControllerWithTitle:@"Error" message:@"Confirm password is not equal to password." actionTitle:@"OK"];
        [self presentViewController:alert animated:YES completion:nil];
        NSLog(@"密码不一致");
        return;
    }
    [self sendRegisterRequest];
}
-(void)sendRegisterRequest{
    self.activityView.hidden = NO;
    [self.activityView startAnimating];
    NSDictionary *param = @{
                            @"username": self.usernameString,
                            @"password": self.passwordString,
                            @"emial": self.emailString,
                            @"second_password": self.confirmString
                            };
    [self POST:kSignupUrl parameters:param success:^(id  _Nullable responseObject) {
        [self.activityView stopAnimating];
        self.activityView.hidden = YES;
        if ([responseObject[@"status"] intValue] == 1){
            NSLog(@"注册成功");
            User *user = [User mj_objectWithKeyValues:responseObject[@"content"]];
            ChatViewController *chatViewController = [[ChatViewController alloc]init];
            UINavigationController *navigationController = [[UINavigationController alloc]initWithRootViewController:chatViewController];
            [self presentViewController:navigationController  animated:YES completion:nil];
        }else{
            UIAlertController *alert = [self alertControllerWithTitle:@"Error" message:@"" actionTitle:@"OK"];
            [self presentViewController:alert animated:YES completion:nil];
        }
    } failure:^(NSError * _Nonnull error) {
        [self.activityView stopAnimating];
        self.activityView.hidden = YES;
        UIAlertController *alert = [self alertControllerWithTitle:@"Error" message:@"You have disconnected to server." actionTitle:@"OK"];
        [self presentViewController:alert animated:YES completion:nil];
    }];
}
- (void)cancelButtonClick:(UIButton *)button{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)keyboardHide:(NSNotification *)aNSNotification
{
    if (self.view.frame.origin.y == -70) {
        CGFloat deltaY = 70;
        //在0.25s内完成self.view的Frame的变化，等于是给self.view添加一个向上移动deltaY的动画
        [UIView animateWithDuration:0.25f animations:^{
            [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y+deltaY, self.view.frame.size.width, self.view.frame.size.height)];
        }];
    }
}
-(void)keyboardShow:(NSNotification *)aNSNotification
{
    if (self.view.frame.origin.y == 0) {
        CGFloat deltaY = 70;
        //在0.25s内完成self.view的Frame的变化，等于是给self.view添加一个向上移动deltaY的动画
        [UIView animateWithDuration:0.25f animations:^{
            [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y-deltaY, self.view.frame.size.width, self.view.frame.size.height)];
        }];
    }
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}
- (void)textFieldDidEndEditing:(UITextField *)textField{
    NSInteger tag = textField.tag;
    switch (tag) {
        case 1:{
            self.usernameString = textField.text;
            break;
        }
        case 2:{
            self.emailString = textField.text;
            break;
        }
        case 3:{
            self.passwordString = textField.text;
            break;
        }
        case 4:{
            self.confirmString = textField.text;
            break;
        }
        default:
            break;
    }
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField endEditing:YES];
    
    return YES;
}

- (void)layout{
    [self.activityLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.left.equalTo(self.activityView);
        make.bottom.equalTo(self.activityView).offset(-15);
    }];
    [self.activityView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.width.height.mas_equalTo(160);
    }];
    [self.signupLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(100);
        make.left.right.equalTo(self.view);
    }];
    
    [self.username mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.signupLabel.mas_bottom).offset(40);
        make.left.equalTo(self.view).offset(30);
        make.right.equalTo(self.view).offset(-30);
        make.height.mas_equalTo(44);
    }];
    [self.email mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.height.equalTo(self.username);
        make.top.equalTo(self.username.mas_bottom).offset(10);
    }];
    [self.password mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.height.equalTo(self.username);
        make.top.equalTo(self.email.mas_bottom).offset(10);
    }];
    [self.confirmPwd mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.height.equalTo(self.username);
        make.top.equalTo(self.password.mas_bottom).offset(10);
    }];
    [self.registerButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.height.equalTo(self.username);
        make.top.equalTo(self.confirmPwd.mas_bottom).offset(10);
    }];
    [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view).offset(-10);
        make.top.equalTo(self.view).offset(50);
        make.width.mas_equalTo(50);
        make.height.mas_equalTo(30);
    }];
}

- (UILabel *)signupLabel{
    if (!_signupLabel) {
        UILabel *label = [UILabel new];
        label.text = @"Welcome Join!";
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont boldSystemFontOfSize:30];
        label.textColor = [UIColor blackColor];
        label.backgroundColor = [UIColor clearColor];
        self.signupLabel = label;
    }
    return _signupLabel;
}
- (UITextField *)username
{
    if (!_username) {
        UITextField *textfield = [[UITextField alloc]init];
        textfield.layer.borderWidth = kBorderWidth;
        textfield.layer.borderColor = [systemColor CGColor];
        textfield.layer.cornerRadius = kCornerRadius;
        textfield.layer.masksToBounds = YES;
        textfield.placeholder = @"UserName";
        textfield.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 20, 44)];
        textfield.leftViewMode = UITextFieldViewModeAlways;
        textfield.delegate = self;
        textfield.tag = 1;
        textfield.returnKeyType = UIReturnKeyDone;
        [textfield setAutocapitalizationType:UITextAutocapitalizationTypeNone];
        textfield.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.username = textfield;
    }
    return _username;
}
- (UITextField *)password
{
    if (!_password) {
        UITextField *textfield = [[UITextField alloc]init];
        textfield.layer.borderWidth = kBorderWidth;
        textfield.layer.borderColor = [systemColor CGColor];
        textfield.layer.cornerRadius = kCornerRadius;
        textfield.layer.masksToBounds = YES;
        textfield.placeholder = @"Password";
        textfield.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 20, 44)];
        textfield.leftViewMode = UITextFieldViewModeAlways;
        textfield.delegate = self;
        textfield.tag = 3;
        textfield.returnKeyType = UIReturnKeyDone;
        [textfield setAutocapitalizationType:UITextAutocapitalizationTypeNone];
        textfield.clearButtonMode = UITextFieldViewModeWhileEditing;
        textfield.secureTextEntry = YES;
        self.password = textfield;
    }
    return _password;
}
- (UITextField *)email
{
    if (!_email) {
        UITextField *textfield = [[UITextField alloc]init];
        textfield.layer.borderWidth = kBorderWidth;
        textfield.layer.borderColor = [systemColor CGColor];
        textfield.layer.cornerRadius = kCornerRadius;
        textfield.layer.masksToBounds = YES;
        textfield.placeholder = @"Email";
        textfield.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 20, 44)];
        textfield.leftViewMode = UITextFieldViewModeAlways;
        textfield.delegate = self;
        textfield.tag = 2;
        textfield.returnKeyType = UIReturnKeyDone;
        [textfield setAutocapitalizationType:UITextAutocapitalizationTypeNone];
        textfield.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.email = textfield;
    }
    return _email;
}
- (UITextField *)confirmPwd
{
    if (!_confirmPwd) {
        UITextField *textfield = [[UITextField alloc]init];
        textfield.layer.borderWidth = kBorderWidth;
        textfield.layer.borderColor = [systemColor CGColor];
        textfield.layer.cornerRadius = kCornerRadius;
        textfield.layer.masksToBounds = YES;
        textfield.placeholder  = @"Confirm Password";
        textfield.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 20, 44)];
        textfield.leftViewMode = UITextFieldViewModeAlways;
        textfield.clearButtonMode = UITextFieldViewModeWhileEditing;
        textfield.secureTextEntry= YES;
        textfield.delegate = self;
        textfield.tag = 4;
        textfield.returnKeyType = UIReturnKeyDone;
        [textfield setAutocapitalizationType:UITextAutocapitalizationTypeNone];
        self.confirmPwd = textfield;
    }
    return _confirmPwd;
}
- (UIButton *)registerButton{
    if (!_registerButton) {
        UIButton *registerButton = [UIButton buttonWithType:UIButtonTypeCustom];
        registerButton.layer.cornerRadius = 22;
        registerButton.layer.masksToBounds = YES;
        [registerButton setTitle:@"Sign Up" forState:UIControlStateNormal];
        [registerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        registerButton.backgroundColor = systemColor;
        [registerButton addTarget:self action:@selector(registerButtonClick:) forControlEvents:UIControlEventTouchDown];
        self.registerButton = registerButton;
    }
    return _registerButton;
}
- (UIButton *)cancelButton{
    if (!_cancelButton) {
        UIButton *registerButton = [UIButton buttonWithType:UIButtonTypeCustom];
        registerButton.layer.cornerRadius = 2;
        registerButton.layer.masksToBounds = YES;
        registerButton.titleLabel.font = [UIFont systemFontOfSize:13];
        [registerButton setTitle:@"Cancel" forState:UIControlStateNormal];
        [registerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        registerButton.backgroundColor = systemColor;
        [registerButton addTarget:self action:@selector(cancelButtonClick:) forControlEvents:UIControlEventTouchDown];
        self.cancelButton = registerButton;
    }
    return _cancelButton;
}
- (DGActivityIndicatorView *)activityView{
    if (!_activityView) {
        DGActivityIndicatorView *activityView = [[DGActivityIndicatorView alloc]initWithType:DGActivityIndicatorAnimationTypeBallScaleRippleMultiple tintColor:systemColor size:50.0f];
        activityView.hidden = YES;
        activityView.layer.cornerRadius= 5;
        activityView.layer.masksToBounds = YES;
        activityView.backgroundColor = [UIColor colorWithWhite:0.4 alpha:0.8];
        self.activityView = activityView;
    }
    return _activityView;
}
- (UILabel *)activityLabel{
    if (!_activityLabel) {
        UILabel *label = [[UILabel alloc]init];
        label.text = @"Loading...";
        label.textColor = systemColor;
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont boldSystemFontOfSize:16];
        self.activityLabel = label;
    }
    return _activityLabel;
}
@end
