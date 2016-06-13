//
//  ViewController.m
//  iKYOperation
//
//  Created by 郑钦洪 on 16/6/13.
//  Copyright © 2016年 iKingsly. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (strong, nonatomic) NSOperationQueue *queue;
@property (strong, nonatomic) NSOperation *op;
@end

@implementation ViewController
- (NSOperationQueue *)queue{
    if (!_queue) {
        // 默认创建出来的队列，没有限制并发数量
        _queue = [[NSOperationQueue alloc] init];
        // 设置最大的并发数
        _queue.maxConcurrentOperationCount = 4;
    }
    return _queue;
}

- (void)testQueueSuspendAndResume {
    if (self.queue.isSuspended) {
        // 恢复
        [self.queue setSuspended:NO];
    }else{
        [self.queue setSuspended:YES];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    int i = 0;
//    while (i < 1000) {
//        [self.queue addOperationWithBlock:^{
//            NSLog(@"%@",[NSThread currentThread]);
//        }];
//    }
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
//    int i = 0;
//    while (i < 1000) {
//        [self.queue addOperationWithBlock:^{
//            NSLog(@"%@",[NSThread currentThread]);
//        }];
//    }
    
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)testOperationCancel {
    // 1.
    _op = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(invocationBlockCallback) object:nil];
    dispatch_async(dispatch_get_global_queue(0, DISPATCH_QUEUE_PRIORITY_DEFAULT), ^{
        // 2.
        [self.queue addOperation:_op];
    });
    
    // 3.5s cancel operation
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_op cancel];
    });
}
- (IBAction)stop:(id)sender {
    [self testQueueSuspendAndResume];
}

- (IBAction)start:(id)sender {
    
    [self testOperationCancel];
    return;
    int i = 0;
    dispatch_async(dispatch_get_global_queue(0,DISPATCH_QUEUE_PRIORITY_DEFAULT), ^{
        //修改为串行队列
        self.queue.maxConcurrentOperationCount = 1;
        
        [self.queue addOperationWithBlock:^{
            for (NSInteger i = 0; i < 10000; i++) {
                NSLog(@"Thread 1: %ld", i);
            }
        }];
        
        [self.queue addOperationWithBlock:^{
            for (NSInteger i = 0; i < 10000; i++) {
                NSLog(@"Thread 2: %ld", i);
            }
        }];
        
        [self.queue addOperationWithBlock:^{
            for (NSInteger i = 0; i < 10000; i++) {
                NSLog(@"Thread 3: %ld", i);
            }
        }];
    });
}

- (void)invocationBlockCallback {
    
    //耗时任务1
    for (NSInteger i = 0; i < 10000; i++) {
        NSLog(@"Operation did execute: %ld", i);
    }
    
    if ([_op isCancelled]) return;//判断是否已经被取消
    
    //耗时任务2
    for (NSInteger i = 0; i < 10000; i++) {
        NSLog(@"Operation did execute: %ld", i);
    }
    
    if ([_op isCancelled]) return;//判断是否已经被取消
    
    //耗时任务3
    for (NSInteger i = 0; i < 10000; i++) {
        NSLog(@"Operation did execute: %ld", i);
    }
    
    if ([_op isCancelled]) return;//判断是否已经被取消
}
@end
