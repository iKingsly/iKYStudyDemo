//
//  ViewController.m
//  解决按钮重复点击
//
//  Created by 郑钦洪 on 16/7/1.
//  Copyright © 2016年 iKingsly. All rights reserved.
//

#import "ViewController.h"
#import "UIButton+Throttle.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(100, 100, 200, 100)];
    button.backgroundColor = [UIColor orangeColor];
    button.iKY_ThrottleTime = 5;
    [button addTarget:self action:@selector(buttonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
}

- (void)buttonAction {
    NSLog(@"点击了我");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
