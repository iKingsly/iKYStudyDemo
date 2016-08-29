//
//  iKYDispatchQueuePool.m
//  iKYDispatchQueuePool
//
//  Created by 郑钦洪 on 16/8/29.
//  Copyright © 2016年 iKingsly. All rights reserved.
//

#import "iKYDispatchQueuePool.h"
#import <UIKit/UIKit.h>
#import <libkern/OSAtomic.h>
#import <objc/runtime.h>
#define MAX_QUEUE_COUNT 32
/// 返回队列的优先线 iOS8 之前的方法
static inline dispatch_queue_priority_t NSQualityOfServiceToDispatchPriority(NSQualityOfService qos) {
    switch (qos) {
        case NSQualityOfServiceUserInteractive: {
            return DISPATCH_QUEUE_PRIORITY_HIGH;
            break;
        }
        case NSQualityOfServiceUserInitiated: {
            return DISPATCH_QUEUE_PRIORITY_HIGH;
            break;
        }
        case NSQualityOfServiceUtility: {
            return DISPATCH_QUEUE_PRIORITY_LOW;
            break;
        }
        case NSQualityOfServiceBackground: {
            return DISPATCH_QUEUE_PRIORITY_BACKGROUND;
            break;
        }
        case NSQualityOfServiceDefault: {
            return DISPATCH_QUEUE_PRIORITY_DEFAULT;
            break;
        }
    }
}

/// iOS 8之后提出的描述队列质量
static inline qos_class_t NSQualityOfServiceToQOSClass (NSQualityOfService qos) {
    switch (qos) {
        case NSQualityOfServiceUserInteractive: {
            return QOS_CLASS_USER_INTERACTIVE;
            break;
        }
        case NSQualityOfServiceUserInitiated: {
            return QOS_CLASS_USER_INITIATED;
            break;
        }
        case NSQualityOfServiceUtility: {
            return QOS_CLASS_UTILITY;
            break;
        }
        case NSQualityOfServiceBackground: {
            return QOS_CLASS_BACKGROUND;
            break;
        }
        case NSQualityOfServiceDefault: {
            return QOS_CLASS_DEFAULT;
            break;
        }
        default:
            return QOS_CLASS_UNSPECIFIED;
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
} iKYDispatchContext;


static iKYDispatchContext *iKYDispatchContextCreate (const char *name,
                                                     uint32_t queueCount,
                                                     NSQualityOfService qos) {

    iKYDispatchContext *context = calloc(1, sizeof(iKYDispatchContext));

    if (!context) {
        return NULL;
    }

    context->queues = calloc(queueCount, sizeof(void *));

    /// create fail
    if (!context->queues) {
        free(context);
        return NULL;
    }

    if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0) {

        dispatch_qos_class_t qosClass = NSQualityOfServiceToQOSClass(qos);

        for (NSUInteger i = 0; i < queueCount; i++) { // after iOS 8
            dispatch_queue_attr_t  attr = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, qosClass, 0);

            dispatch_queue_t queue = dispatch_queue_create(name, attr);

            context->queues[i] = (__bridge_retained void *)(queue);
        }
    } else { // before iOS 8

        long identifier = NSQualityOfServiceToDispatchPriority(qos);

        for (NSUInteger i = 0; i < queueCount; i ++) {

            dispatch_queue_t queue = dispatch_queue_create(name, DISPATCH_QUEUE_SERIAL);

            /// get the priority by dispatch_get_global_queue
            dispatch_set_target_queue(queue, dispatch_get_global_queue(identifier, 0));

            context->queues[i] = (__bridge_retained void *)(queue);
        }

    }

    /// set queue Count
    context->queueCount = queueCount;
    if (name) {
        /// set queue name by copy from name
        context->name = strdup(name);
    }

    return context;
}

static void iKYDispatchContextRelease (iKYDispatchContext *context) {
    /// judge if context released
    if (!context) { /// context has released
        return;
    }

    if (context->queues) {
        for (NSUInteger i = 0 ; i < context->queueCount; i++) {
            // get the queue of index
            void *queuePointer = context->queues[i];

            dispatch_queue_t queue = (__bridge_transfer dispatch_queue_t)(queuePointer);

            const char *name = dispatch_queue_get_label(queue);

            if (name) {
                strlen(name);
            }
            queue = nil;
        }

        /// free the queues
        free(context->queues);

        context->queues = NULL;
    }

    /// free the name
    if (context->name) {
        free((void *)context->name);
    }
}

/// get a queue from cachePool
static dispatch_queue_t iKYDispatchContextGetQueue(iKYDispatchContext *context) {
    /// add used count
    uint32_t counter = (uint32_t)OSAtomicIncrement32(&context->counter);

    // get current queue index by counter mod queueCount
    void *queue = context->queues[counter % context->queueCount];

    return (__bridge dispatch_queue_t)(queue);
}

static iKYDispatchContext *iKYDispatchContextGetForQOS(NSQualityOfService qos) {
    /// create a array of 5
    static iKYDispatchContext *context[5] = {0};
    switch (qos) {
        case NSQualityOfServiceUserInteractive: {
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                /// get current CPU count
                int count = (int)[NSProcessInfo processInfo].activeProcessorCount;
                /// if count > 1 then set count of MAX_QUEUE_COUNT
                count = count < 1 ? 1 : count > MAX_QUEUE_COUNT ? MAX_QUEUE_COUNT : count;
                context[0] = iKYDispatchContextCreate("com.iKingsly.interactive", count, qos);
            });
            return context[0];
            break;
        }
        case NSQualityOfServiceUserInitiated: {
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                /// get current CPU count
                int count = (int)[NSProcessInfo processInfo].activeProcessorCount;
                /// if count > 1 then set count of MAX_QUEUE_COUNT
                count = count < 1 ? 1 : count > MAX_QUEUE_COUNT ? MAX_QUEUE_COUNT : count;
                context[1] = iKYDispatchContextCreate("com.iKingsly.Initiated", count, qos);
            });
            return context[1];
            break;
        }
        case NSQualityOfServiceUtility: {
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                /// get current CPU count
                int count = (int)[NSProcessInfo processInfo].activeProcessorCount;
                /// if count > 1 then set count of MAX_QUEUE_COUNT
                count = count < 1 ? 1 : count > MAX_QUEUE_COUNT ? MAX_QUEUE_COUNT : count;
                context[2] = iKYDispatchContextCreate("com.iKingsly.Utility", count, qos);
            });
            return context[2];
            break;
        }
        case NSQualityOfServiceBackground: {
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                /// get current CPU count
                int count = (int)[NSProcessInfo processInfo].activeProcessorCount;
                /// if count > 1 then set count of MAX_QUEUE_COUNT
                count = count < 1 ? 1 : count > MAX_QUEUE_COUNT ? MAX_QUEUE_COUNT : count;
                context[3] = iKYDispatchContextCreate("com.iKingsly.Background", count, qos);
            });
            return context[3];
            break;
        }
        case NSQualityOfServiceDefault: {
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                /// get current CPU count
                int count = (int)[NSProcessInfo processInfo].activeProcessorCount;
                /// if count > 1 then set count of MAX_QUEUE_COUNT
                count = count < 1 ? 1 : count > MAX_QUEUE_COUNT ? MAX_QUEUE_COUNT : count;
                context[4] = iKYDispatchContextCreate("com.iKingsly.Default", count, qos);
            });
            return context[4];
            break;
        }
    }
}
@implementation iKYDispatchQueuePool

@end
