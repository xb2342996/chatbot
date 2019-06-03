//
//  LoginViewController.m
//  RelaxBot
//
//  Created by xiongbiao on 2019/3/13.
//  Copyright © 2019年 xiongbiao. All rights reserved.
//

#import "LoginViewController.h"
#import "ChatViewController.h"
#import "RegisterController.h"
#import "User.h"

@interface LoginViewController () <UITextFieldDelegate>
@property (nonatomic, weak) UITextField *usernameTextField;
@property (nonatomic, weak) UITextField *passwordTextField;
@property (nonatomic, strong) UIView *usrborderLine;
@property (nonatomic, strong) UIView *pwdborderLine;
@property (nonatomic, strong) DGActivityIndicatorView *activityView;
@property (nonatomic, strong) UILabel *activityLabel;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupView];
}
- (void)setupView{
    
    UIImageView *backgroundView = [UIImageView new];
    backgroundView.frame = UIScreen.mainScreen.bounds;
    [backgroundView setImage:[UIImage imageNamed:@"bg"]];
    
    UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleRegular];
    UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc]initWithEffect:effect];
    visualEffectView.alpha = 0.9f;
    visualEffectView.frame = UIScreen.mainScreen.bounds;
    
    UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    loginButton.layer.cornerRadius = 22;
    loginButton.layer.masksToBounds = YES;
    [loginButton setTitle:@"Sign In" forState:UIControlStateNormal];
    [loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    loginButton.backgroundColor = systemColor;
    [loginButton addTarget:self action:@selector(loginButtonClick:) forControlEvents:UIControlEventTouchDown];
    
    UIButton *registerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    registerButton.layer.cornerRadius = 22;
    registerButton.layer.masksToBounds = YES;
    registerButton.layer.borderColor = [systemColor CGColor];
    registerButton.layer.borderWidth = 1;
    [registerButton setTitle:@"Sign Up" forState:UIControlStateNormal];
    [registerButton setTitleColor:systemColor forState:UIControlStateNormal];
    registerButton.backgroundColor = [UIColor clearColor];
    [registerButton addTarget:self action:@selector(registerButtonClick:) forControlEvents:UIControlEventTouchDown];
    
    self.usernameTextField = [self textfieldWithPlaceholder:@"username" secureTextEntry:NO leftViewImage:@"username"];
    
    self.passwordTextField = [self textfieldWithPlaceholder:@"password" secureTextEntry:YES leftViewImage:@"password"];
    
    [self.view addSubview:backgroundView];
    [self.view addSubview:visualEffectView];
    [self.view addSubview:self.usernameTextField];
    [self.view addSubview:self.usrborderLine];
    [self.view addSubview:self.passwordTextField];
    [self.view addSubview:self.pwdborderLine];
    [self.view addSubview:loginButton];
    [self.view addSubview:registerButton];
    [self.view addSubview:self.activityView];
    [self.activityView addSubview:self.activityLabel];
    
    [self.activityLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.left.equalTo(self.activityView);
        make.bottom.equalTo(self.activityView).offset(-15);
    }];
    [self.activityView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.width.height.mas_equalTo(160);
    }];
    
    [registerButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(loginButton);
        make.height.mas_equalTo(44);
        make.top.equalTo(loginButton.mas_bottom).offset(10);
    }];
    
    [loginButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.left.mas_equalTo(30);
        make.right.mas_equalTo(-30);
        make.height.mas_equalTo(44);
        make.bottom.mas_equalTo(-200);
    }];
    [self.usernameTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.left.mas_equalTo(30);
        make.right.mas_equalTo(-30);
        make.height.mas_equalTo(44);
        make.bottom.equalTo(self.passwordTextField.mas_top).mas_offset(-10);
    }];
    [self.usrborderLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.usernameTextField);
        make.height.mas_equalTo(1);
        make.top.equalTo(self.usernameTextField.mas_bottom);
    }];
    [self.passwordTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.left.mas_equalTo(30);
        make.right.mas_equalTo(-30);
        make.height.mas_equalTo(44);
        make.bottom.equalTo(loginButton.mas_top).mas_offset(-30);
    }];
    [self.pwdborderLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.passwordTextField);
        make.height.mas_equalTo(1);
        make.top.equalTo(self.passwordTextField.mas_bottom);
    }];
}
- (UITextField *)textfieldWithPlaceholder:(NSString *)placeholder secureTextEntry:(BOOL)secureTextEntry leftViewImage:(NSString *)image{
    
    UITextField *textField = [[UITextField alloc]init];
    textField.placeholder = placeholder;
    textField.delegate = self;
    textField.textColor = [UIColor whiteColor];
    textField.backgroundColor = [UIColor clearColor];
    textField.textAlignment = NSTextAlignmentLeft;
    textField.font = [UIFont systemFontOfSize:18];
    [textField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [textField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    textField.enabled = YES;
    UIView *bgView = [UIView new];
    bgView.frame = CGRectMake(0, 0, 55, 44);
    UIImageView *view = [UIImageView new];
    view.frame = CGRectMake(5, 5, 34, 34);
    
    view.image = [UIImage imageNamed:image];
    [bgView addSubview:view];
    textField.leftView = bgView;
    textField.leftViewMode = UITextFieldViewModeAlways;
//    textField.clearsOnBeginEditing = YES;
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    textField.secureTextEntry= secureTextEntry;
    textField.returnKeyType = UIReturnKeyDone;
    return textField;
}
-(void)keyboardHide:(NSNotification *)aNSNotification
{
    if (self.view.frame.origin.y == -150){
        CGFloat deltaY = 150;
        //在0.25s内完成self.view的Frame的变化，等于是给self.view添加一个向上移动deltaY的动画
        [UIView animateWithDuration:0.25f animations:^{
            [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y+deltaY, self.view.frame.size.width, self.view.frame.size.height)];
        }];
    }
}
-(void)keyboardShow:(NSNotification *)aNSNotification
{
    if (self.view.frame.origin.y == 0){
        CGFloat deltaY = 150;
        //在0.25s内完成self.view的Frame的变化，等于是给self.view添加一个向上移动deltaY的动画
        [UIView animateWithDuration:0.25f animations:^{
            [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y-deltaY, self.view.frame.size.width, self.view.frame.size.height)];
        }];
    }
}
- (void)registerButtonClick:(UIButton *)button{
    RegisterController *registerController = [RegisterController new];
    [self presentViewController:registerController animated:YES completion:nil];
}
- (void)loginButtonClick:(UIButton *)button{
    if ([self.usernameTextField.text isEqualToString:@""] || [self.passwordTextField.text isEqualToString:@""]){
        UIAlertController *alert = [self alertControllerWithTitle:@"Error" message:@"Username & Password can not be Empty!" actionTitle:@"Done"];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    [self.view endEditing:YES];
    self.activityView.hidden = NO;
    [self.activityView startAnimating];
    NSDictionary *param = @{
                            @"username": self.usernameTextField.text,
                            @"password" : self.passwordTextField.text
                            };
    NSLog(@"%@", param);
    [self POST:kLoginUrl parameters:param success:^(id  _Nullable responseObject) {
        [self.activityView stopAnimating];
        self.activityView.hidden = YES;
        NSLog(@"%@", responseObject);
        NSString *msg = responseObject[@"content"][@"error"];
        int status = [responseObject[@"status"] intValue];
        if (status == 0){
            UIAlertController *alert = [self alertControllerWithTitle:@"Error" message:msg actionTitle:@"Done"];
            [self presentViewController:alert animated:YES completion:nil];
        }else if (status == 1){
            ChatViewController *chatViewController = [[ChatViewController alloc]init];
            UINavigationController *navigationController = [[UINavigationController alloc]initWithRootViewController:chatViewController];
            [self presentViewController:navigationController  animated:YES completion:nil];
            User *user = [User mj_objectWithKeyValues:responseObject[@"content"]];
        };
    } failure:^(NSError * _Nonnull error) {
        NSLog(@"fail to connect to server.");
        [self.activityView stopAnimating];
        self.activityView.hidden = YES;
        UIAlertController *alert = [self alertControllerWithTitle:@"Error" message:@"fail to connect to server." actionTitle:@"Done"];
        [self presentViewController:alert animated:YES completion:nil];
    }];
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField endEditing:YES];
    return YES;
}
- (UIView *)usrborderLine{
    if (!_usrborderLine) {
        UIView *view = [UIView new];
        view.backgroundColor = [UIColor whiteColor];
        self.usrborderLine = view;
    }
    return _usrborderLine;
}
- (UIView *)pwdborderLine{
    if (!_pwdborderLine) {
        UIView *view = [UIView new];
        view.backgroundColor = [UIColor whiteColor];
        self.pwdborderLine = view;
    }
    return _pwdborderLine;
}
- (DGActivityIndicatorView *)activityView{
    if (!_activityView) {
        DGActivityIndicatorView *activityView = [[DGActivityIndicatorView alloc]initWithType:DGActivityIndicatorAnimationTypeBallSpinFadeLoader tintColor:systemColor size:50.0f];
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
