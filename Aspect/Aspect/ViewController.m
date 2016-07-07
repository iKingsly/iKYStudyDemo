//
//  ViewController.m
//  Aspect
//
//  Created by 郑钦洪 on 16/7/7.
//  Copyright © 2016年 iKingsly. All rights reserved.
//

#import "ViewController.h"
#import "AspectClass.h"
#import "TargetClass.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    TargetClass *target = [TargetClass new];
    [target show];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
