//
//  ViewController.m
//  LoginMVVM
//
//  Created by 郑钦洪 on 16/6/10.
//  Copyright © 2016年 iKingsly. All rights reserved.
//

#import "ViewController.h"
#import "AccountViewModel.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *accountTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (strong, nonatomic) AccountViewModel *loginViewModel;
@end

@implementation ViewController
- (AccountViewModel *)loginViewModel{
    if (!_loginViewModel) {
        _loginViewModel = [AccountViewModel new];
    }
    return _loginViewModel;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self bindViewModel];
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self bindViewModel];
}

- (void)bindViewModel{
    RAC(self.loginViewModel.account, account) = _accountTextField.rac_textSignal;
    RAC(self.loginViewModel.account, password) = _passwordTextField.rac_textSignal;
    
    // 绑定登录按钮的可点击状态
//    RAC(self.loginBtn,enabled) = self.loginViewModel.enableLoginSignal;
//    
//    [[self.loginBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
//        [self.loginViewModel.loginCommand execute:nil];
//    }];
    self.loginBtn.rac_command = _loginViewModel.loginCommand;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
