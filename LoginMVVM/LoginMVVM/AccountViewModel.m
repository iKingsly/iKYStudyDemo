//
//  AccountViewModel.m
//  LoginMVVM
//
//  Created by 郑钦洪 on 16/6/10.
//  Copyright © 2016年 iKingsly. All rights reserved.
//

#import "AccountViewModel.h"
#import "MBProgressHUD.h"

@implementation AccountViewModel
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initialBind];
    }
    return self;
}
- (Account *)account{
    if (!_account) {
        _account = [Account new];
    }
    return _account;
}

#pragma mark - 绑定
- (void)initialBind{
    // 监听账号的改变
    _enableLoginSignal = [RACSignal combineLatest:@[RACObserve(self.account, account),RACObserve(self.account, password)] reduce:^id(NSString *account,NSString *pwd){
        return @(account.length>3 && pwd.length>3);
    }];
    
    // 处理点击事件的业务逻辑
    _loginCommand = [[RACCommand alloc] initWithEnabled:_enableLoginSignal signalBlock:^RACSignal *(id input) {
        NSLog(@"点击了登录按钮");
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
           // 模拟网络请求
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [subscriber sendNext:@"登录成功"];
                
                // 数据传送完毕，必须调用完成，否则命令永远处于执行状态
                [subscriber sendCompleted];
            });
            return nil;
        }];
    }];
    
    // 监听登录产生的数据
    [_loginCommand.executionSignals.switchToLatest subscribeNext:^(id x) {
        if ([x isEqualToString:@"登录成功"]) {
            NSLog(@"登录成功");
        }
    }];
    
    // 监听登录状态
    [[_loginCommand.executing skip:1] subscribeNext:^(id x) {
        if ([x isEqualToNumber:@(YES)]) {
            
            // 正在登录ing...
            // 用蒙版提示
            NSLog(@"正在登录");
            
            
        }else
        {
            // 登录成功
            // 隐藏蒙版
            NSLog(@"已经登录");
        }
    }];
}
@end
