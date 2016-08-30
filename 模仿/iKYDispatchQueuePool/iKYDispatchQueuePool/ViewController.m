//
//  ViewController.m
//  iKYDispatchQueuePool
//
//  Created by 郑钦洪 on 16/8/29.
//  Copyright © 2016年 iKingsly. All rights reserved.
//

#import "ViewController.h"
#import "iKYDispatchQueuePool.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    dispatch_queue_t queue = iKYDispatchQueueGetForQOS(NSQualityOfServiceUtility);

    iKYDispatchQueuePool *pool = [[iKYDispatchQueuePool alloc] initWithName:@"file.read" queueCount:5 qos:NSQualityOfServiceBackground];

    dispatch_queue_t queue2 = [pool queue];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
