//
//  AccountController.m
//  RelaxBot
//
//  Created by xiongbiao on 2019/4/19.
//  Copyright © 2019 xiongbiao. All rights reserved.
//

#import "AccountController.h"
#import "Regx.h"
#import "User.h"

#define HeaderHeight 10

@interface AccountController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>
@property (nonatomic, strong) UITableView *accountTableView;
@property (nonatomic, strong) UILabel *userLabel;
@property (nonatomic, strong) UITextField *emailLabel;
@property (nonatomic, copy) NSString *currentEmail;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, strong) DGActivityIndicatorView *activityView;
@property (nonatomic, strong) User *user;
@property (nonatomic, strong) UILabel *activityLabel;
@end

@implementation AccountController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.user = [User shareInstance];
    self.userLabel.text = self.user.username;
    self.emailLabel.text = self.user.email;
    
    // Do any additional setup after loading the view.
    [self.view addSubview:self.accountTableView];
    [self.accountTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
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

}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return HeaderHeight;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, HeaderHeight)];
    view.backgroundColor = [UIColor clearColor];
    return view ;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Account"];
    if (indexPath.row == 0) {
        cell.textLabel.text = @"Username";
        cell.accessoryView = self.userLabel;
    } else if (indexPath.row == 1){
        cell.textLabel.text = @"Email";
        cell.accessoryView = self.emailLabel;
    } else{
        cell.textLabel.text = @"Password";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return cell;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField endEditing:YES];
    return YES;
}
-(void)textFieldDidBeginEditing:(UITextField *)textField{
    self.currentEmail = textField.text;
    textField.text = @"";

}
-(void)textFieldDidEndEditing:(UITextField *)textField{
    if ([textField.text length] == 0) {
        textField.text = self.currentEmail;
    }else{
        [self sendInfo:textField.text];
    }
}
- (void)sendInfo:(NSString *)email{
    BOOL isValid = [Regx validateEmail:email];
    if (isValid) {
        [self sendRequestWithString:email];
    }else{
        UIAlertController *alert = [self alertControllerWithTitle:@"Error" message:@"Your Email Format is Incorrect" actionTitle:@"Done"];
        [self presentViewController:alert animated:YES completion:nil];
    }
}
-(void)sendRequestWithString:(NSString *)string{
    self.activityView.hidden = NO;
    [self.activityView startAnimating];
    NSDictionary *param = @{
                            @"username": self.user.username,
                            @"new_email": string
                            };
    NSLog(@"%@", kModifyUrl);
    [self POST:kModifyUrl parameters:param success:^(id  _Nullable responseObject) {
        NSLog(@"%@", responseObject);
        [self.activityView stopAnimating];
        self.activityView.hidden = YES;
        if ([responseObject[@"status"] intValue] == 1){
            UIAlertController *alert = [self alertControllerWithTitle:@"Success" message:@"Your Email have been Modified Successfully" actionTitle:@"Done"];
            [self presentViewController:alert animated:YES completion:nil];
            self.user.email = string;
        }else{
            NSLog(@"修改失败");
            UIAlertController *alert = [self alertControllerWithTitle:@"Failure" message:@"Your Email have failed to  been Modified" actionTitle:@"Done"];
            [self presentViewController:alert animated:YES completion:nil];
            self.emailLabel.text = self.currentEmail;
        }
    } failure:^(NSError * _Nonnull error) {
        [self.activityView stopAnimating];
        self.activityView.hidden = YES;
        UIAlertController *alert = [self alertControllerWithTitle:@"Error" message:@"You have connected to server." actionTitle:@"Done"];
        [self presentViewController:alert animated:YES completion:nil];
        self.emailLabel.text = self.currentEmail;
    }];
}
-(UITableView *)accountTableView{
    if (!_accountTableView) {
        UITableView *tableView = [[UITableView alloc]init];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.backgroundColor = [UIColor colorWithRed:243/255.0 green:243/255.0 blue:243/255.0 alpha:1];
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Account"];
        self.accountTableView = tableView;
    }
    return _accountTableView;
}
- (UILabel *)userLabel{
    if (!_userLabel) {
        UILabel *label = [UILabel new];
        label.textColor = [UIColor blackColor];
        label.frame = CGRectMake(0, 0, 100, 40);
        label.textAlignment = NSTextAlignmentRight;
        self.userLabel = label;
    }
    return _userLabel;
}
- (UITextField *)emailLabel{
    if (!_emailLabel) {
        UITextField *label = [UITextField new];
        label.textColor = [UIColor blackColor];
        label.frame = CGRectMake(0, 0, 200, 40);
        label.delegate = self;
        label.textAlignment = NSTextAlignmentRight;
        label.returnKeyType = UIReturnKeyDone;
        [label setAutocapitalizationType:UITextAutocapitalizationTypeNone];
        self.emailLabel = label;
    }
    return _emailLabel;
}

- (DGActivityIndicatorView *)activityView{
    if (!_activityView) {
        DGActivityIndicatorView *activityView = [[DGActivityIndicatorView alloc]initWithType:DGActivityIndicatorAnimationTypeBallPulse tintColor:systemColor size:50.0f];
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
