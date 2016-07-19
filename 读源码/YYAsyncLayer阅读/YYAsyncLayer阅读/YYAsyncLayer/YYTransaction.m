//
//  YYTransaction.m
//  YYKit <https://github.com/ibireme/YYKit>
//
//  Created by ibireme on 15/4/18.
//  Copyright (c) 2015 ibireme.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import "YYTransaction.h"


@interface YYTransaction()
@property (nonatomic, strong) id target;
@property (nonatomic, assign) SEL selector;
@end

static NSMutableSet *transactionSet = nil;
// RunLoop Observer 回调
static void YYRunLoopObserverCallBack(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info) {
    /// 如果集合内需要渲染的内容数量为0 直接返回
    if (transactionSet.count == 0) return;
    /// 获得当前的Set
    NSSet *currentSet = transactionSet;
    /// 刷新set
    transactionSet = [NSMutableSet new];
    /// 对transaction进行刷新
    [currentSet enumerateObjectsUsingBlock:^(YYTransaction *transaction, BOOL *stop) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [transaction.target performSelector:transaction.selector];
#pragma clang diagnostic pop
    }];
}

static void YYTransactionSetup() {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        transactionSet = [NSMutableSet new];
        /// 获得主线程的runLoop
        CFRunLoopRef runloop = CFRunLoopGetMain();
        /// 注册通知者
        CFRunLoopObserverRef observer;
        /// 监听 kCFRunLoopBeforeWaiting 和 kCFRunLoopExit
        /// 在runloop 空闲的时候进行刷新
        observer = CFRunLoopObserverCreate(CFAllocatorGetDefault(),
                                           kCFRunLoopBeforeWaiting | kCFRunLoopExit,
                                           true,      // repeat
                                           0xFFFFFF,  // after CATransaction(2000000)
                                           YYRunLoopObserverCallBack, NULL);
        /// 添加到runLoop中
        CFRunLoopAddObserver(runloop, observer, kCFRunLoopCommonModes);
        /// 对observer做一次释放
        CFRelease(observer);
    });
}


@implementation YYTransaction
/**
 *  通过一个target和selector来创建YYTransaction
 *
 *  @param target   target
 *  @param selector 选择子
 *
 *  @return YYTransaction
 */
+ (YYTransaction *)transactionWithTarget:(id)target selector:(SEL)selector{
    if (!target || !selector) return nil;
    YYTransaction *t = [YYTransaction new];
    t.target = target;
    t.selector = selector;
    return t;
}

/// 将YYTransaction对象本身提交保存在transactionSet的集合中
- (void)commit {
    if (!_target || !_selector) return;
    YYTransactionSetup();
    [transactionSet addObject:self];
}

/// 对selecotr 和 target进行哈希处理
- (NSUInteger)hash {
    long v1 = (long)((void *)_selector);
    long v2 = (long)_target;
    return v1 ^ v2;
}
/// 判断是否相等的条件是 selector 和 target是否相等
- (BOOL)isEqual:(id)object {
    if (self == object) return YES;
    if (![object isMemberOfClass:self.class]) return NO;
    YYTransaction *other = object;
    return other.selector == _selector && other.target == _target;
}

@end
