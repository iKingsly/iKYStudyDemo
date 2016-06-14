//
//  ViewController.m
//  iKYNotificationCenter
//
//  Created by 郑钦洪 on 16/6/14.
//  Copyright © 2016年 iKingsly. All rights reserved.
//

#import "ViewController.h"
#import "iKYNotificationCenter.h"
static NSString * const  NotificationKey = @"CHANGECOLOR";
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [[iKYNotificationCenter defaultCenter] addObserver:self selector:@selector(changeBackGroundColor) name:NotificationKey object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)changeBackGroundColor {
    NSLog(@"控制器1收到了来自控制器2的通知");
    self.view.backgroundColor = [UIColor orangeColor];
}
@end
