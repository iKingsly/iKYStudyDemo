//
//  YYDispatchQueueManager.m
//  YYKit <https://github.com/ibireme/YYKit>
//
//  Created by ibireme on 15/7/18.
//  Copyright (c) 2015 ibireme.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import "YYDispatchQueuePool.h"
#import <UIKit/UIKit.h>
#import <libkern/OSAtomic.h>

#define MAX_QUEUE_COUNT 32
/// 返回队列的优先级 iOS8 之前使用的方法
static inline dispatch_queue_priority_t NSQualityOfServiceToDispatchPriority(NSQualityOfService qos) {
    switch (qos) {
        case NSQualityOfServiceUserInteractive: return DISPATCH_QUEUE_PRIORITY_HIGH;
        case NSQualityOfServiceUserInitiated: return DISPATCH_QUEUE_PRIORITY_HIGH;
        case NSQualityOfServiceUtility: return DISPATCH_QUEUE_PRIORITY_LOW;
        case NSQualityOfServiceBackground: return DISPATCH_QUEUE_PRIORITY_BACKGROUND;
        case NSQualityOfServiceDefault: return DISPATCH_QUEUE_PRIORITY_DEFAULT;
        default: return DISPATCH_QUEUE_PRIORITY_DEFAULT;
    }
}

/// iOS之后提出的描述队列质量
static inline qos_class_t NSQualityOfServiceToQOSClass(NSQualityOfService qos) {
    switch (qos) {
        case NSQualityOfServiceUserInteractive: return QOS_CLASS_USER_INTERACTIVE;
        case NSQualityOfServiceUserInitiated: return QOS_CLASS_USER_INITIATED;
        case NSQualityOfServiceUtility: return QOS_CLASS_UTILITY;
        case NSQualityOfServiceBackground: return QOS_CLASS_BACKGROUND;
        case NSQualityOfServiceDefault: return QOS_CLASS_DEFAULT;
        default: return QOS_CLASS_UNSPECIFIED;
    }
}

typedef struct {
    /// 容器的名称
    const char *name;
    /// 所有被缓存的队列
    void **queues;
    /// 队列的总数
    uint32_t queueCount;
    /// 累加缓存池队列被使用的次数
    int32_t counter;
} YYDispatchContext;

static YYDispatchContext *YYDispatchContextCreate(const char *name,
                                                 uint32_t queueCount,
                                                 NSQualityOfService qos) {
    /// 创建一个context结构体指针
    YYDispatchContext *context = calloc(1, sizeof(YYDispatchContext));
    
    if (!context) return NULL;
    
    // 创建queueCount数量的数组
    context->queues =  calloc(queueCount, sizeof(void *));
    /// 创建失败的话就释放context 返回
    if (!context->queues) {
        free(context);
        return NULL;
    }
    
    /// 判断当前系统的版本 通过不同的api来创建queue
    if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0) {
        /// NSQualityOfService 转化为 qos_class_t
        dispatch_qos_class_t qosClass = NSQualityOfServiceToQOSClass(qos);
        // 创建queueCount个队列 并且按照队列优先级来处理
        for (NSUInteger i = 0; i < queueCount; i++) {
            /// 创建队列描述为串行队列 并设置优先级
            dispatch_queue_attr_t attr = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, qosClass, 0);
            /// 创建队列
            dispatch_queue_t queue = dispatch_queue_create(name, attr);
            // 将数组对应下标指向队列
            context->queues[i] = (__bridge_retained void *)(queue);
        }
    } else { // iOS 8 以前
        /// NSQualityOfService 转化为 dispatch_queue_priority_t
        long identifier = NSQualityOfServiceToDispatchPriority(qos);
        /// 创建queueCount个队列 并且按照队列优先级来处理
        for (NSUInteger i = 0; i < queueCount; i++) {
            /// 创建队列
            dispatch_queue_t queue = dispatch_queue_create(name, DISPATCH_QUEUE_SERIAL);
            /// 使用前面获取得到的优先级 来创建一个全局队列 并且把该全局队列的优先级设置给queue
            dispatch_set_target_queue(queue, dispatch_get_global_queue(identifier, 0));
            // 将数组对应下标指向队列
            context->queues[i] = (__bridge_retained void *)(queue);
        }
    }
    /// 设置context的队列数
    context->queueCount = queueCount;
    if (name) { /// 如果name不为空 则拷贝字符串name的一个副本设置对列的名字
         context->name = strdup(name);
    }
    /// 返回context
    return context;
}

static void YYDispatchContextRelease(YYDispatchContext *context) {
    /// 判断context是否已经释放
    if (!context) return;
    if (context->queues) { // 取得context中的线程
        for (NSUInteger i = 0; i < context->queueCount; i++) {
            // 取出对应下标的queue
            void *queuePointer = context->queues[i];
            /// 强转为 dispatch_queue_t 类型
            dispatch_queue_t queue = (__bridge_transfer dispatch_queue_t)(queuePointer);
            /// 获得队列的名字
            const char *name = dispatch_queue_get_label(queue);
            // 为了避免编译器 warning 写了这段代码
            if (name) strlen(name);
            // 释放指针指向的内存
            queue = nil;
        }
        // 释放数组
        free(context->queues);
        /// 指针指向null
        context->queues = NULL;
    }
    /// 释放字符串内存
    if (context->name) free((void *)context->name);
}


/// 从缓存池中获得一个queue
static dispatch_queue_t YYDispatchContextGetQueue(YYDispatchContext *context) {
    /// 累加缓存池被使用的次数
    uint32_t counter = (uint32_t)OSAtomicIncrement32(&context->counter);
    /// 取出当前队列的下标， 用 counter mod 缓存总队列数
    void *queue = context->queues[counter % context->queueCount];
    /// 返回对应的 queue
    return (__bridge dispatch_queue_t)(queue);
}


/// 根据传入的队列优先级来创建线程池
static YYDispatchContext *YYDispatchContextGetForQOS(NSQualityOfService qos) {
    /// 传教一个缓存器数组
    static YYDispatchContext *context[5] = {0};
    switch (qos) { // 根据队列的优先级来做不同的操作
        case NSQualityOfServiceUserInteractive: {
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                /// 当前激活的处理器个数
                int count = (int)[NSProcessInfo processInfo].activeProcessorCount;
                /// 如果处理器>1 就设置最大为的 MAX_QUEUE_COUNT 的数量
                count = count < 1 ? 1 : count > MAX_QUEUE_COUNT ? MAX_QUEUE_COUNT : count;
                context[0] = YYDispatchContextCreate("com.ibireme.yykit.user-interactive", count, qos);
            });
            return context[0];
        } break;
        case NSQualityOfServiceUserInitiated: {
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                int count = (int)[NSProcessInfo processInfo].activeProcessorCount;
                count = count < 1 ? 1 : count > MAX_QUEUE_COUNT ? MAX_QUEUE_COUNT : count;
                context[1] = YYDispatchContextCreate("com.ibireme.yykit.user-initiated", count, qos);
            });
            return context[1];
        } break;
        case NSQualityOfServiceUtility: {
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                int count = (int)[NSProcessInfo processInfo].activeProcessorCount;
                count = count < 1 ? 1 : count > MAX_QUEUE_COUNT ? MAX_QUEUE_COUNT : count;
                context[2] = YYDispatchContextCreate("com.ibireme.yykit.utility", count, qos);
            });
            return context[2];
        } break;
        case NSQualityOfServiceBackground: {
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                int count = (int)[NSProcessInfo processInfo].activeProcessorCount;
                count = count < 1 ? 1 : count > MAX_QUEUE_COUNT ? MAX_QUEUE_COUNT : count;
                context[3] = YYDispatchContextCreate("com.ibireme.yykit.background", count, qos);
            });
            return context[3];
        } break;
        case NSQualityOfServiceDefault:
        default: {
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                int count = (int)[NSProcessInfo processInfo].activeProcessorCount;
                count = count < 1 ? 1 : count > MAX_QUEUE_COUNT ? MAX_QUEUE_COUNT : count;
                context[4] = YYDispatchContextCreate("com.ibireme.yykit.default", count, qos);
            });
            return context[4];
        } break;
    }
}


@implementation YYDispatchQueuePool {
    @public
    /// 一个缓存容器对象
    YYDispatchContext *_context;
}

- (void)dealloc {
    if (_context) {
        /// 释放context
        YYDispatchContextRelease(_context);
        _context = NULL;
    }
}

- (instancetype)initWithContext:(YYDispatchContext *)context {
    self = [super init];
    if (!context) return nil;
    self->_context = context;
    _name = context->name ? [NSString stringWithUTF8String:context->name] : nil;
    return self;
}

/// 创建一个指定优先级的缓存池
- (instancetype)initWithName:(NSString *)name queueCount:(NSUInteger)queueCount qos:(NSQualityOfService)qos {
    /// 1. 队列的数量必须大于0 小于最大队列数
    if (queueCount == 0 || queueCount > MAX_QUEUE_COUNT) return nil;
    /// 创建context对象
    self = [super init];
    _context = YYDispatchContextCreate(name.UTF8String, (uint32_t)queueCount, qos);
    if (!_context) return nil;
    _name = name;
    return self;
}

// 从当前缓存池中获得一个queue
- (dispatch_queue_t)queue {
    return YYDispatchContextGetQueue(_context);
}

// 传入服务质量，获取静态Pool实例。Pool实例获取的也是静态的Context实例。
+ (instancetype)defaultPoolForQOS:(NSQualityOfService)qos {
    switch (qos) {
        case NSQualityOfServiceUserInteractive: {
            static YYDispatchQueuePool *pool;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                pool = [[YYDispatchQueuePool alloc] initWithContext:YYDispatchContextGetForQOS(qos)];
            });
            return pool;
        } break;
        case NSQualityOfServiceUserInitiated: {
            static YYDispatchQueuePool *pool;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                pool = [[YYDispatchQueuePool alloc] initWithContext:YYDispatchContextGetForQOS(qos)];
            });
            return pool;
        } break;
        case NSQualityOfServiceUtility: {
            static YYDispatchQueuePool *pool;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                pool = [[YYDispatchQueuePool alloc] initWithContext:YYDispatchContextGetForQOS(qos)];
            });
            return pool;
        } break;
        case NSQualityOfServiceBackground: {
            static YYDispatchQueuePool *pool;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                pool = [[YYDispatchQueuePool alloc] initWithContext:YYDispatchContextGetForQOS(qos)];
            });
            return pool;
        } break;
        case NSQualityOfServiceDefault:
        default: {
            static YYDispatchQueuePool *pool;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                pool = [[YYDispatchQueuePool alloc] initWithContext:YYDispatchContextGetForQOS(NSQualityOfServiceDefault)];
            });
            return pool;
        } break;
    }
}

@end

dispatch_queue_t YYDispatchQueueGetForQOS(NSQualityOfService qos) {
    return YYDispatchContextGetQueue(YYDispatchContextGetForQOS(qos));
}
