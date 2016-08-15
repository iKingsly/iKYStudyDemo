//
//  ViewController.m
//  iKYThrottle
//
//  Created by 郑钦洪 on 16/8/15.
//  Copyright © 2016年 iKingsly. All rights reserved.
//

#import "ViewController.h"
#import "iKYThrottle.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSLog(@"%@",[NSThread callStackSymbols][1]);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)editText:(UITextField *)sender {
    dispatch_throttle(0.5, ^{
        NSLog(@"%@",sender.text);
    });
//    NSLog(@"%@",sender.text);
}

@end
