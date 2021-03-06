//
//  ViewController.m
//  dispatch_source
//
//  Created by 郑钦洪 on 16/6/2.
//  Copyright © 2016年 iKingsly. All rights reserved.
//

#import "ViewController.h"
#import "XXGCDTimer.h"
typedef void (^Success)(void);

@interface ViewController ()
{
    XXGCDTimer *timer;
}
@property (nonatomic, strong) dispatch_queue_t queue;
@property (nonatomic, assign) int abc;
@property (nonatomic, copy) Success block;
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
    
    
//    // 指定DISPATCH_SOURCE_TYPE_DATA_ADD，做成Dispatch Source(分派源)。设定Main Dispatch Queue 为追加处理的Dispatch Queue
//    dispatch_source_t _processingQueueSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_DATA_ADD, 0, 0,
//                                                    dispatch_get_main_queue());
//    __block NSUInteger totalComplete = 0;
//    dispatch_source_set_event_handler(_processingQueueSource, ^{
//        //当处理事件被最终执行时，计算后的数据可以通过dispatch_source_get_data来获取。这个数据的值在每次响应事件执行后会被重置，所以totalComplete的值是最终累积的值。
//        NSUInteger value = dispatch_source_get_data(_processingQueueSource);
//        totalComplete += value;
//        NSLog(@"进度：%@", @((CGFloat)totalComplete/100));
//        NSLog(@"🔵线程号：%@", [NSThread currentThread]);
//    });
//    //分派源创建时默认处于暂停状态，在分派源分派处理程序之前必须先恢复。
//    dispatch_resume(_processingQueueSource);
//    
//    //2.
//    //恢复源后，就可以通过dispatch_source_merge_data向Dispatch Source(分派源)发送事件:
//    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//    for (NSUInteger index = 0; index < 100; index ++) {
//        dispatch_async(queue, ^{
//            dispatch_source_merge_data(_processingQueueSource, 1);
//            NSLog(@"♻️线程号：%@", [NSThread currentThread]);
//            usleep(20000);//0.02秒
//        });
//    }
//    timer = [XXGCDTimer new];
//    [timer startGCDTimer];

//    dispatch_queue_t q = dispatch_queue_create("abc", NULL);
//    dispatch_sync(q, ^{
//        NSLog(@"当前进程 %@", [NSThread currentThread]);
//    });
//    
//    dispatch_async(q, ^{
//        NSLog(@"dispatch_async 当前进程 %@", [NSThread currentThread]);
//    });
    
//    dispatch_queue_t queue = dispatch_queue_create("abc", DISPATCH_QUEUE_CONCURRENT);
////    self.queue = queue;
//    
//    dispatch_group_t group = dispatch_group_create();
//    dispatch_group_enter(group);
//    NSLog(@"1");
//    dispatch_group_leave(group);
//    
//    dispatch_group_enter(group);
//    NSLog(@"2");
//    dispatch_group_leave(group);
//    
//    dispatch_group_enter(group);
//    sleep(3);
//    NSLog(@"3");
//    dispatch_group_leave(group);
//    
//    dispatch_group_enter(group);
//    sleep(2);
//    NSLog(@"4");
//    dispatch_group_leave(group);
//
//    dispatch_group_notify(group, queue, ^{
//        NSLog(@"done");
//    });
//    NSLog(@"主线程");


//    dispatch_async(dispatch_get_main_queue(), ^{
//        NSLog(@"1 %@",[NSThread currentThread]);
//    });
    // 开启一个异步队列来等待
    //    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    //        dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    //        dispatch_async(queue, ^{
    //            NSLog(@"done");
    //        });
    //    });
//
//    dispatch_async(dispatch_get_main_queue(), ^{
//        NSLog(@"2 %@",[NSThread currentThread]);
//    });
//    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        NSLog(@"3 %@",[NSThread currentThread]);
//    });
    

//     2
//    dispatch_queue_t queue = dispatch_get_main_queue();
//    
//    // 3
//    static dispatch_source_t source = nil;
//    
//    // 4
//    __typeof(self) __weak weakSelf = self;
//    
//    // 5
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        // 6
//        source = dispatch_source_create(DISPATCH_SOURCE_TYPE_SIGNAL, SIGSTOP, 0, queue);
//        
//        // 7
//        if (source)
//        {
//            // 8
//            dispatch_source_set_event_handler(source, ^{
//                // 9
//                NSLog(@"Hi, I am: %@", weakSelf);
//            });
//            dispatch_resume(source); // 10
//        }
//    });
    
//    [self barrierDemo];
//    dispatch_semaphore_t sema = dispatch_semaphore_create(1);
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
//        NSLog(@"获得sema 1 %@",[NSThread currentThread]);
//        sleep(3);
//        dispatch_semaphore_signal(sema);
//    });
//    
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        dispatch_semaphore_wait(sema, DISPATCH_TIME_NOW);
//        NSLog(@"获得sema 2 %@",[NSThread currentThread]);
//        dispatch_semaphore_signal(sema);
//    });
//    
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
//        NSLog(@"获得sema 3 %@",[NSThread currentThread]);
//        sleep(2);
//
////        dispatch_semaphore_signal(sema);
//    });
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
//        NSLog(@"获得sema 4 %@",[NSThread currentThread]);
//        dispatch_semaphore_signal(sema);
//    });
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_enter(group);
    NSLog(@"%ld",LONG_MAX);
    sleep(3);
    dispatch_group_leave(group);
    NSLog(@"done");
}

- (void) barrierDemo{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dispatch_queue_t queue = dispatch_queue_create("iKingsly", DISPATCH_QUEUE_CONCURRENT);
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    dispatch_async(queue, ^{
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        for (int i = 0; i < 1000; i++) {
            dict[@(i)] = @(i);
        }
        dispatch_semaphore_signal(semaphore);
    });
    
    dispatch_async(queue, ^{
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        for (int i = 0; i < 1000; i++) {
            NSLog(@"%@", dict[@(i)]);
        }
        dispatch_semaphore_signal(semaphore);
    });
}

void myFinalizerFunction(){
    NSLog(@"销毁了");
}
- (int)abc {
    return 1;
}

- (IBAction)resume:(id)sender {
    [timer resumeTimer];
}

- (IBAction)pauseTimer:(id)sender {
    [timer pauseTimer];
}


- (IBAction)stopTimer:(id)sender {
    [timer stopTimer];
}

int largeNumber = 1000000;
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    NSLog(@"start");
    CFAbsoluteTime start = CFAbsoluteTimeGetCurrent();
    [self answer1];
    NSLog(@"外 %f", CFAbsoluteTimeGetCurrent() - start);
    
    start = CFAbsoluteTimeGetCurrent();
    [self answer2];
    NSLog(@"内 %f", CFAbsoluteTimeGetCurrent() - start);
}

- (void)answer1 {
    @autoreleasepool {
        for (long i = 0; i < largeNumber; ++i) {
            NSString *str = [NSString stringWithFormat:@"hello - %ld", i];
            str = [str uppercaseString];
            str = [str stringByAppendingString:@" - world"];
        }
    }
}

- (void)answer2 {
    for (long i = 0; i < largeNumber; ++i) {
        @autoreleasepool {
            NSString *str = [NSString stringWithFormat:@"hello - %ld", i];
            str = [str uppercaseString];
            str = [str stringByAppendingString:@" - world"];
        }
    }
}
/// 在主线程空闲时才会调度队列中的任务在主线程执行
- (void)gcdDemo1 {
    
    dispatch_queue_t queue = dispatch_get_main_queue();
    
    for (int i = 0; i < 10; ++i) {
        dispatch_async(queue, ^{
            NSLog(@"%@ - %d", [NSThread currentThread], i);
        });
        NSLog(@"---> %d", i);
    }
    
    NSLog(@"come here");
}

- (void)gcdDemo2 {
    // 1. 队列
    dispatch_queue_t q = dispatch_get_global_queue(0, 0);
    
    // 2. 执行任务
    for (int i = 0; i < 10; ++i) {
        dispatch_async(q, ^{
            NSLog(@"%@ - %d", [NSThread currentThread], i);
        });
    }
    
    NSLog(@"come here");
}

//
//2016-07-05 20:01:58.333 dispatch_source[13601:493518] come here
//2016-07-05 20:01:58.334 dispatch_source[13601:493554] 任务2 <NSThread: 0x7fd3c3f15d60>{number = 2, name = (null)}
//2016-07-05 20:01:58.334 dispatch_source[13601:493557] 任务3 <NSThread: 0x7fd3c3d1c610>{number = 3, name = (null)}
//2016-07-05 20:01:59.336 dispatch_source[13601:493553] 任务1 <NSThread: 0x7fd3c6003580>{number = 4, name = (null)}
//2016-07-05 20:01:59.336 dispatch_source[13601:493553] OVER <NSThread: 0x7fd3c6003580>{number = 4, name = (null)}

- (void)group1 {
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_queue_t q = dispatch_get_global_queue(0, 0);
    
    dispatch_group_async(group, q, ^{
        [NSThread sleepForTimeInterval:1];
        NSLog(@"任务1 %@",[NSThread currentThread]);
    });
    
    dispatch_group_async(group, q, ^{
        NSLog(@"任务2 %@", [NSThread currentThread]);
    });
    
    dispatch_group_async(group, q, ^{
        NSLog(@"任务3 %@", [NSThread currentThread]);
    });
    
    dispatch_group_notify(group, q, ^{
        NSLog(@"OVER %@", [NSThread currentThread]);
    });
    
    NSLog(@"come here");
}

- (void)group2 {
    // 1. 调度组
    dispatch_group_t group = dispatch_group_create();
    
    // 2. 队列
    dispatch_queue_t q = dispatch_queue_create(0, 0);
    
    dispatch_group_enter(group);
    dispatch_group_async(group, q, ^{
        NSLog(@"任务1 %@", [NSThread currentThread]);
        dispatch_group_leave(group);
    });
    
    dispatch_group_enter(group);
    dispatch_group_async(group, q, ^{
        NSLog(@"任务2 %@", [NSThread currentThread]);
        dispatch_group_leave(group);
    });
    
    // 4. 阻塞等待调度组中所有任务执行完毕
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    NSLog(@"OVER %@", [NSThread currentThread]);
}
/**
 提问：是否开线程？是否顺序执行？come here 的位置？
 come here 第一行执行 开启线程
 */
- (void)gcdDemo3 {
    
    // 1. 队列
    dispatch_queue_t q = dispatch_queue_create("itheima", DISPATCH_QUEUE_CONCURRENT);
    
    // 2. 执行任务
    for (int i = 0; i < 10; ++i) {
        dispatch_async(q, ^{
            NSLog(@"%@ - %d", [NSThread currentThread], i);
        });
    }
    
    NSLog(@"come here");
}

- (void)gcdDemo5 {
    
    // 1. 队列
    dispatch_queue_t q = dispatch_queue_create("itheima", DISPATCH_QUEUE_SERIAL);
    
    // 2. 执行任务
    for (int i = 0; i < 10; ++i) {
        dispatch_async(q, ^{
            NSLog(@"%@ - %d", [NSThread currentThread], i);
        });
    }
    
    NSLog(@"come here");
}

/**
 提问：是否开线程？是否顺序执行？come here 的位置？
 不会开启新的线程，都在主线程执行
 */
- (void)gcdDemo4 {
    
    // 1. 队列
    dispatch_queue_t q = dispatch_queue_create("itheima", DISPATCH_QUEUE_CONCURRENT);
    
    // 2. 执行任务
    for (int i = 0; i < 10; ++i) {
        dispatch_sync(q, ^{
            NSLog(@"%@ - %d", [NSThread currentThread], i);
        });
        NSLog(@"---> %i", i);
    }
    
    NSLog(@"come here");
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
