//
//  iKYOperation.m
//  iKYOperation
//
//  Created by 郑钦洪 on 16/6/13.
//  Copyright © 2016年 iKingsly. All rights reserved.
//

#import "iKYOperation.h"
// 将枚举值转换成对应的iOS系统人士的NSOperation KVO 通知key
static inline NSString *AFKeyPathFromOperationState(iKYOpetationStatus status) {
    switch (status) {
        case iKYOperationStatusReady:
            return @"isReady";
            break;
        case iKYOperationStatusPaused:
            return @"isPaused";
            break;
        case iKYOperationStatusExcuting:
            return @"isExecuting";
            break;
        case iKYOperationStatusFinished:
            return @"isFinished";
            break;
        default:
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunreachable-code"
            return @"state";
#pragma clang diagnostic pop
            break;
    }
}

// 从一个状态改变到另一个状态 是否合法
static inline BOOL AFStateTransitionIsValid(iKYOpetationStatus fromStatus, iKYOpetationStatus toStatus,BOOL isCancelled) {
    switch (fromStatus) {
            // 1. 当前状态为Ready
        case iKYOperationStatusReady:
            switch (toStatus) {
                case iKYOperationStatusPaused:
                case iKYOperationStatusExcuting:
                    return YES;
                case iKYOperationStatusFinished:
                    return NO;
                default:
                    return NO;
            }
            break;
            // 2. 当前状态为excuting
        case iKYOperationStatusExcuting:
            switch (toStatus) {
                case iKYOperationStatusFinished:
                case iKYOperationStatusPaused:
                    return YES;
                default:
                    return NO;
            }
            // 3. 当前状态为finish
        case iKYOperationStatusFinished:
            return NO;
            // 4. 当前状态为paused
        case iKYOperationStatusPaused:
            return toStatus == iKYOperationStatusReady;
        
        default: {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunreachable-code"
            switch (toStatus) {
                case iKYOperationStatusReady:
                case iKYOperationStatusExcuting:
                case iKYOperationStatusPaused:
                case iKYOperationStatusFinished:
                    return YES;
                default:
                    return NO;
            }
        }
#pragma clang diagnostic pop
    }
}

@interface iKYOperation()
// 递归锁
@property (readwrite, nonatomic, strong) NSRecursiveLock *lock;

// 保存当前operation的状态
@property (readwrite, nonatomic, assign) iKYOpetationStatus status;
/**
 *  执行要在Operation执行的任务代码
 */
- (void)operationDidStart;

/**
 *  取消执行operation
 */
- (void)cancelOperation;

/**
 *  结束执行opertaion
 */
- (void)finish;

/**
 *  执行operttation暂停需要执行的代码
 */
- (void)operationDidPause;
@end
@implementation iKYOperation
+ (void)netWorkRequestThreadEntryPoint:(id)__unused object {
    @autoreleasepool {
        // 1
        [[NSThread currentThread] setName:@"iKYOperationThread"];
        
        // 2
        NSRunLoop *runloop = [NSRunLoop currentRunLoop];
        [runloop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
        [runloop run];
    }
}

// 创建线程
+ (NSThread *)netWorkRequestThread {
    static NSThread *_netWorkRequestThread = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 创建线程
        _netWorkRequestThread = [[NSThread alloc] initWithTarget:self selector:@selector(netWorkRequestThreadEntryPoint:) object:nil];
        
        // 启动线程
        [_netWorkRequestThread start];
    });
    return _netWorkRequestThread;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        // 初始化状态为ready
        _status = iKYOperationStatusReady;
        
        // 初始化递归锁
        _lock = [[NSRecursiveLock alloc] init];
        _lock.name = @"iKYOperationLock";
        
        // 设置runloop的Modes
        _runLoopModes = [NSSet setWithObject:NSRunLoopCommonModes];
    }
    return self;
}
#pragma mark - 获取状态
- (BOOL)isReady{
    return  self.status == iKYOperationStatusReady && [super isReady];
}

- (BOOL)isExecuting{
    return self.status == iKYOperationStatusExcuting;
}

- (BOOL)isFinished{
    return self.status == iKYOperationStatusFinished;
}

- (BOOL)isConcurrent{
    return YES; // 默认是并发
}
#pragma mark - 重写关键的方法
- (void)start{
    [self.lock lock];
    
    // 1. 判断operation是否取消，只能是在operation没有被调度之前，就执行cancel
    // 2. 如下［执行operation］和 ［取消operation］函数都是在［另外一个单例子线程上］执行，由runloop来激活线程
    
    if ([self isCancelled]) {
        [self performSelector:@selector(cancelOperation)
                     onThread:[[self class] netWorkRequestThread]
                   withObject:nil
                waitUntilDone:NO
                        modes:[self.runLoopModes allObjects]];
    } else {
        // 1.
        self.status = iKYOperationStatusExcuting;
        // 2.
        [self performSelector:@selector(operationDidStart)
                     onThread:[[self class] netWorkRequestThread]
                   withObject:nil
                waitUntilDone:NO
                        modes:[self.runLoopModes allObjects]];
    }
    
    [self.lock unlock];
}

- (void)operationDidStart {
    [self.lock lock];
    
    // 1. 先在子线程的runloop发送事件源，执行耗时任务代码
    
    //2. 重要的部分 执行任务完成后耦 让operation结束执行
    [self finish];
    [self.lock unlock];
}

- (void)finish {
    // 1. 修改operation的状态
    [self.lock lock];
    self.status = iKYOperationStatusFinished;
    [self.lock unlock];
    
    // 2. 发送通知，operation已经执行结束
}


//不管是【开始执行operation】、【取消执行operation】、【暂停operation】、【执行完毕operation】， 所有的状态改变，必须手动发出KVO通知，否则系统不会执行NSOperation实例对应的函数
- (void)setStatus:(iKYOpetationStatus)status{
    if (!AFStateTransitionIsValid(self.status, status, [self isCancelled])) {
        return;
    }

    [self.lock lock];
    
    /**
     *   获取status枚举对应的字符串值
     */
    NSString *oldStateKey = AFKeyPathFromOperationState(self.status);
    NSString *newStateKey = AFKeyPathFromOperationState(status);
    
    // 手动发出KVO属性修改通知
    [self willChangeValueForKey:newStateKey];
    [self willChangeValueForKey:oldStateKey];
    _status = status;
    
    [self didChangeValueForKey:oldStateKey];
    [self didChangeValueForKey:newStateKey];
    
    [self.lock unlock];
}

/**
 *  重写设置NSOperation的回调代码
 */
- (void)setCompletionBlock:(void (^)(void))completionBlock{
    [self.lock lock];
    
    if (!completionBlock) {
        [super setCompletionBlock:nil];
    } else {
        __weak typeof(self) weakSelf = self;
        [super setCompletionBlock:^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            
            // 判断当operaion取消后，不执行传入的任务代码
            if (strongSelf.isCancelled == NO) {
                dispatch_async(dispatch_get_main_queue(), completionBlock);
            }
        }];
    }
    
    [self.lock unlock];
}

- (void)cancel {
    [self.lock lock];
    
    if (!self.isFinished && !self.isCancelled) {
        [super cancel];
        
        [self performSelector:@selector(cancelOperation) onThread:[[self class] netWorkRequestThread] withObject:nil waitUntilDone:NO modes:[self.runLoopModes allObjects]];
        
    }
    
    [self.lock unlock];
}

- (void)cancelOperation {
    if (![self isFinished]) {
        // 1. 做一些清除对象
        // 比如 取消NSURLConnection对象的执行
        
        // 2。 结束执行operation
        [self finish];
    }
}

#pragma mark - 暂停执行operation
- (BOOL)isPaused {
    return  self.status == iKYOperationStatusPaused;
}

- (void)pause{
    // 暂停条件， 不能已经暂停，不能已经结束，不能已经取消
    if ([self isPaused] || [self isFinished] || [self isCancelled]) {
        return;
    }
    
    [self.lock lock];
    
    // 如果正在执行ing
    if ([self isExecuting]) {
        // 1. 执行暂停执行任务代码
        [self performSelector:@selector(operationDidPause) onThread:[[self class] netWorkRequestThread] withObject:nil waitUntilDone:NO modes:[self.runLoopModes allObjects]];
        
        // 2. 发送通知 operation已经暂停
    }
    
    // 修改状态 发出KVO通知
    self.status = iKYOperationStatusPaused;
    
    [self.lock unlock];
}

- (void)operationDidPause{
    [self.lock lock];
    
    // 取消执行建立网络连接 等等
    NSLog(@"operation暂停执行..., 线程: %@\n", [NSThread currentThread]);
    
    //结束执行（应该写在NSURLConnectionDelegate回调函数中）
    [self finish];
    
    [self.lock unlock];
}
// 实际上 pause暂停就是直接让operation结束执行 发出finish的KVO通知

#pragma mark - 恢复执行
- (void)resume {
    // 只有被paused的operation才可以恢复
    if (![self isPaused]) {
        return;
    }
    
    [self.lock lock];
    
    // 1.
    self.status = iKYOperationStatusReady;
    
    // 2.
    [self start];
    
    [self.lock unlock];
}

@end
