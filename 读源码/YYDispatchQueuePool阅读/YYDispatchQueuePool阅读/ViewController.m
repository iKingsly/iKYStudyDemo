//
//  ViewController.m
//  YYDispatchQueuePool阅读
//
//  Created by 郑钦洪 on 16/7/13.
//  Copyright © 2016年 iKingsly. All rights reserved.
//

#import "ViewController.h"
#import "YYDispatchQueuePool.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 从全局的 queue pool 中获取一个 queue
    dispatch_queue_t queue = YYDispatchQueueGetForQOS(NSQualityOfServiceUtility);
    
    // 创建一个新的 serial queue pool
    YYDispatchQueuePool *pool = [[YYDispatchQueuePool alloc] initWithName:@"file.read" queueCount:5 qos:NSQualityOfServiceBackground];
//    dispatch_queue_t queue = [pool queue];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
