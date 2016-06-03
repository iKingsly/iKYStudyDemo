//
//  ViewController.m
//  dispatch_source
//
//  Created by 郑钦洪 on 16/6/2.
//  Copyright © 2016年 iKingsly. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        UIButton *button = [self addAButton];
//        NSURL *url = [NSURL URLWithString:@"https://www.baidu.com/img/bd_logo1.png"];
//        NSData *data = [NSData dataWithContentsOfURL:url];
//        UIImage *image = [UIImage imageWithData:data];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [button setBackgroundImage:image forState:UIControlStateNormal];
//            [self.view addSubview:button];
//        });
//    });
    [self dispatchGroupNotifyDemo];
}

- (void)barrier{
    dispatch_queue_t dataQueue = dispatch_queue_create("abc", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(dataQueue, ^{
        [NSThread sleepForTimeInterval:2.f];
        NSLog(@"读取1");
    });
    dispatch_async(dataQueue, ^{
        NSLog(@"读取2");
    });
    // 等待前面完成 执行barrier后面的内容
    dispatch_barrier_async(dataQueue, ^{
        NSLog(@"写数据1");
        [NSThread sleepForTimeInterval:1];
    });
    dispatch_async(dataQueue, ^{
        [NSThread sleepForTimeInterval:1.f];
        NSLog(@"读取数据3");
    });
    dispatch_async(dataQueue, ^{
        NSLog(@"read data4");
    });
}

- (void)dispatchGroupNotifyDemo {
    dispatch_queue_t concurrentQueue = dispatch_queue_create("", DISPATCH_QUEUE_CONCURRENT);
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_async(group, concurrentQueue, ^{
        [NSThread sleepForTimeInterval:2.f];
        NSLog(@"1");
    });
    
    dispatch_group_async(group, concurrentQueue, ^{
        NSLog(@"2");
    });
    dispatch_group_notify(group, concurrentQueue, ^{
        NSLog(@"end");
    });
    NSLog(@"done");
}

- (void)dispatchGroupWaitDemo{
    dispatch_queue_t concurrentQueue = dispatch_queue_create("com", DISPATCH_QUEUE_CONCURRENT);
    dispatch_group_t group = dispatch_group_create();
    // 在group中添加队列的block
    dispatch_group_async(group, concurrentQueue, ^{
        [NSThread sleepForTimeInterval:2.f];
        NSLog(@"1");
    });
    
    dispatch_group_async(group, concurrentQueue, ^{
        NSLog(@"2");
    });
    
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    NSLog(@"go on");
}
- (UIButton *)addAButton{
    UIButton *button = [UIButton new];
    button.frame = CGRectMake(100, 100, 100, 100);
    button.backgroundColor = [UIColor redColor];
    return button;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
