//
//  AlertView.m
//  RelaxBot
//
//  Created by xiongbiao on 2019/4/20.
//  Copyright © 2019 xiongbiao. All rights reserved.
//

#import "AlertView.h"

@interface AlertView ()

@end

@implementation AlertView

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

+ (void)alertControllerWithTitle:(NSString *)title message:(NSString*)message actionTitle:(NSString *)actionTitle{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:actionTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [alert dismissViewControllerAnimated:YES completion:nil];
    }];
    [alert addAction:action1];
}

@end
