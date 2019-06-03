//
//  SettingViewController.m
//  RelaxBot
//
//  Created by xiongbiao on 2019/4/18.
//  Copyright © 2019 xiongbiao. All rights reserved.
//

#import "SettingViewController.h"
#import "AboutUsController.h"
#import "AccountController.h"
#import "LoginViewController.h"
#import "User.h"

#define FooterHeight 10
#define HeaderHeight 5

@interface SettingViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *settingTableView;
@property (nonatomic, strong) NSArray *array1;
@property (nonatomic, strong) NSArray *array2;
@property (nonatomic, strong) UISwitch *swithButton;
@property (nonatomic, strong) DGActivityIndicatorView *activityView;
@property (nonatomic, strong) UILabel *activityLabel;
@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addSubview:self.settingTableView];
    [self.view addSubview:self.activityView];
    self.array1 = @[@"Account"];
    self.array2 = @[@"About Us", @"Recommendation Switch"];
    [self.settingTableView mas_makeConstraints:^(MASConstraintMaker *make) {
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
    [self getSwitchStatus];
}
- (void)getSwitchStatus{
    self.activityView.hidden = NO;
    [self.activityView startAnimating];
    [self POST:kSwitchUrl parameters:nil success:^(id  _Nullable responseObject) {
        [self.activityView stopAnimating];
        self.activityView.hidden = YES;
        NSLog(@"%@", responseObject);
        if ([responseObject[@"switch"] intValue] == 1) {
            self.swithButton.on = YES;
        }else{
            self.swithButton.on = NO;
        }
        
    } failure:^(NSError * _Nonnull error) {
        [self.activityView stopAnimating];
        self.activityView.hidden = YES;
        UIAlertController *alert = [self alertControllerWithTitle:@"Error" message:@"You have disconnected to server." actionTitle:@"OK"];
        [self presentViewController:alert animated:YES completion:nil];
    }];
}
- (void)openRecommendationSystem{
    NSLog(@"current switch status: %d", self.swithButton.isOn);
    if (self.swithButton.isOn){
        [self engineStart:1];
    }else{
        [self engineStart:0];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}
- (void)engineStart:(int)status{
    NSLog(@"switch go: %d", status);
    self.activityView.hidden = NO;
    [self.activityView startAnimating];
    NSDictionary *param = @{
                            @"switch" : [NSString stringWithFormat:@"%d", status]
                            };
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:kRecommendationUrl parameters:param progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"%@", responseObject);
        [self.activityView stopAnimating];
        self.activityView.hidden = YES;
        if ([responseObject[@"status"] intValue] == 1){
            if ([responseObject[@"switch"] intValue] == 1){
                NSLog(@"engine start success");
                UIAlertController *alert = [self alertControllerWithTitle:@"Done" message:@"You have start Recommendation System." actionTitle:@"OK"];
                [self presentViewController:alert animated:YES completion:nil];
            }else{
                NSLog(@"engine stop success");
                UIAlertController *alert = [self alertControllerWithTitle:@"Done" message:@"You have close Recommendation System." actionTitle:@"OK"];
                [self presentViewController:alert animated:YES completion:nil];
            }
        }else{
            NSLog(@"engine operation fail");
            [self.swithButton setOn:!self.swithButton.isOn animated:YES];
            UIAlertController *alert = [self alertControllerWithTitle:@"Error" message:@"You have failed to control Recommendation System." actionTitle:@"OK"];
            [self presentViewController:alert animated:YES completion:nil];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self.activityView stopAnimating];
        self.activityView.hidden = YES;
        UIAlertController *alert = [self alertControllerWithTitle:@"Error" message:@"You have disconnected to server." actionTitle:@"OK"];
        [self presentViewController:alert animated:YES completion:nil];
    }];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger number = 0;
    switch (section) {
        case 0:
            number = self.array1.count;
            break;
        case 1:
            number = self.array2.count;
            break;
        case 2:
            number = 1;
        default:
            break;
    }
    return number;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return HeaderHeight;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, HeaderHeight)];
    view.backgroundColor = [UIColor clearColor];
    return view ;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, FooterHeight)];
    view.backgroundColor = [UIColor clearColor];
    return view ;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return FooterHeight;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (indexPath.section == 2 && indexPath.row == 0){
        NSLog(@"退出登录");
        [User clearUser];
        LoginViewController *loginController = [[LoginViewController alloc]init];
        [self presentViewController:loginController animated:YES completion:nil];
    } else if (indexPath.section == 0 && indexPath.row == 0){
        NSLog(@"账户信息");
        AccountController *accountController = [[AccountController alloc]init];
        [self.navigationController pushViewController:accountController animated:YES];
    } else if (indexPath.section == 1 && indexPath.row == 0){
        NSLog(@"关于我们");
        AboutUsController *abountController = [[AboutUsController alloc]init];
        [self.navigationController pushViewController:abountController animated:YES];
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Setting"];
    if (indexPath.section == 2) {
        cell.textLabel.text = @"Log Out";
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.textColor = [UIColor redColor];
    } else if (indexPath.section == 1){
        cell.textLabel.text = self.array2[indexPath.row];
        if (indexPath.row == 0){
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }else{
            cell.accessoryView = self.swithButton;
        }
    } else{
        cell.textLabel.text = self.array1[indexPath.row];
        cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    }
    return cell;
}
-(UITableView *)settingTableView{
    if (!_settingTableView) {
        UITableView *tableView = [[UITableView alloc]init];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.backgroundColor = [UIColor colorWithRed:243/255.0 green:243/255.0 blue:243/255.0 alpha:1];
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Setting"];
        self.settingTableView = tableView;
    }
    return _settingTableView;
}

-(UISwitch *)swithButton{
    if (!_swithButton) {
        UISwitch *switchButton = [[UISwitch alloc]init];
        switchButton.onTintColor = systemColor;
        [switchButton addTarget:self action:@selector(openRecommendationSystem) forControlEvents:UIControlEventValueChanged];
        self.swithButton = switchButton;
    }
    return _swithButton;
}

- (DGActivityIndicatorView *)activityView{
    if (!_activityView) {
        DGActivityIndicatorView *activityView = [[DGActivityIndicatorView alloc]initWithType:DGActivityIndicatorAnimationTypeBallBeat tintColor:systemColor size:50.0f];
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
        label.text = @"Setting...";
        label.textColor = systemColor;
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont boldSystemFontOfSize:16];
        self.activityLabel = label;
    }
    return _activityLabel;
}
@end
