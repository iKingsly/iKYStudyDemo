//
//  ViewController.m
//  为UIView添加手势
//
//  Created by 郑钦洪 on 16/7/6.
//  Copyright © 2016年 iKingsly. All rights reserved.
//

#import "ViewController.h"
#import "UIView+addGesture.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self.view iKY_setTapActionWithBlock:^{
        NSLog(@"打印成功");
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
