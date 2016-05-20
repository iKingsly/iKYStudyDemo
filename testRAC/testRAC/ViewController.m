//
//  ViewController.m
//  testRAC
//
//  Created by 郑钦洪 on 16/5/19.
//  Copyright © 2016年 iKingsly. All rights reserved.
//

#import "ViewController.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "secondViewController.h"
#import "RACSignInAPI.h"
@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *textFieldUsername;
@property (weak, nonatomic) IBOutlet UITextField *textFieldPassword;
@property (strong,nonatomic) RACCommand *command;
@property (weak, nonatomic) IBOutlet UIButton *SubmitBtn;
@property (weak, nonatomic) IBOutlet UIButton *checkCodeBtn;
@property (strong, nonatomic) RACSignInAPI *signInApi;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.signInApi = [RACSignInAPI new];
    // 监听用户输入框的长度
    RACSignal *signalUser = [[self.textFieldUsername rac_textSignal] map:^id(NSString *textField) {
        return @(textField.length > 3);
    }];
    
    // 监听密码输入框的长度
    RACSignal *signalPSW = [[self.textFieldPassword rac_textSignal] map:^id(NSString *textField) {
        return @(textField.length > 3);
    }];
    
    // 聚合两个输入，并对按钮的可选进行判断
    [[RACSignal combineLatest:@[signalUser, signalPSW] reduce:^id(NSNumber *textUserValid, NSNumber *textPasswordValid){
        return @([textUserValid boolValue] && [textPasswordValid boolValue]);
    }] subscribeNext:^(NSNumber *x) {
        self.SubmitBtn.enabled = [x boolValue];
    }];
    
    // 对点击按钮进行处理
    [[[[self.SubmitBtn rac_signalForControlEvents:UIControlEventTouchUpInside] flattenMap:^RACStream *(id value) {
        return [self signIn];
    }] filter:^BOOL(id value) {
        // 对调用完网络的结果进行筛选处理
        NSLog(@"%@",value);
        return [value isEqualToString:@"登录成功"];
    }]subscribeNext:^(id x) { // 登录成功跳到下一页
        NSLog(@"打印点击提交按钮 %@",x);
        secondViewController *vc = [secondViewController new];
        vc.delegateSignal = [RACSubject subject];
        [vc.delegateSignal subscribeNext:^(NSString *x) {
            [self.SubmitBtn setTitle:x forState:UIControlStateNormal];
        }];
        [self.navigationController pushViewController:vc animated:YES];
    }];
    
    // 点击验证码按钮
    [[self.checkCodeBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(UIButton *sender) {
        RAC(sender.titleLabel,text) = [[RACSignal interval:1 onScheduler:[RACScheduler mainThreadScheduler]] map:^NSString *(NSDate *date) {
            NSLog(@"%@",date.description);
            return date.description;
        }];
    }];
}

- (RACSignal *)signIn{
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        BOOL result = [self.signInApi initWithName:self.textFieldUsername.text password:self.textFieldPassword.text];
        if (result == YES) {
            [subscriber sendNext:@"登录成功"];
            [subscriber sendCompleted];
        }else{
            [subscriber sendNext:@"登录失败"];
            [subscriber sendCompleted];
        }
        
        return nil;
    }];
    return signal;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
