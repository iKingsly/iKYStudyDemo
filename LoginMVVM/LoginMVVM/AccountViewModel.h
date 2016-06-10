//
//  AccountViewModel.h
//  LoginMVVM
//
//  Created by 郑钦洪 on 16/6/10.
//  Copyright © 2016年 iKingsly. All rights reserved.
//
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <Foundation/Foundation.h>
#import "Account.h"

@interface AccountViewModel : NSObject
@property (nonatomic, strong) Account *account;
@property (nonatomic, strong, readonly) RACSignal *enableLoginSignal;
@property (nonatomic, strong, readonly) RACCommand *loginCommand;
@end
