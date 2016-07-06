//
//  ViewController.m
//  NSInvocation学习
//
//  Created by 郑钦洪 on 16/7/6.
//  Copyright © 2016年 iKingsly. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    SEL myMethod = @selector(myLog:param:param:);
    
    NSMethodSignature *sig = [[self class] instanceMethodSignatureForSelector:myMethod];
    NSLog(@"signature %@",sig);
    
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
    
    [invocation setTarget:self];
    [invocation setSelector:myMethod];
    
    int a = 1;
    int b = 2;
    int c = 3;
    [invocation setArgument:&a atIndex:2];
    [invocation setArgument:&b atIndex:3];
    [invocation setArgument:&c atIndex:4];
    
    [invocation invoke];
}

- (void)myLog:(int)a param:(int)b param:(int) c {
    NSLog(@"a %d b %d c %d",a,b,c);
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
