//
//  PKProtocolExtension.m
//  iKYProtocolKit
//
//  Created by 郑钦洪 on 16/8/18.
//  Copyright © 2016年 iKingsly. All rights reserved.
//

#import "PKProtocolExtension.h"
#import <pthread.h>

typedef struct {
    Protocol *__unsafe_unretained protocol;
    Method *instanceMethods;
    unsigned instanceMethodCount;
    Method *classMethods;
    unsigned classMethodCount;

} PKExtendProtocol;

static PKExtendProtocol *allExtendedProtocols = NULL;
static pthread_mutex_t protocolLoadingLock = PTHREAD_MUTEX_INITIALIZER;
static size_t extendedProtocolCount = 0, extendedProtocolCapacity = 0;

Method *_pk_extension_create_merged(Method *existMethods, unsigned existMethodCount, Method *appendingMethods, unsigned appendingMethodCount) {
    if (existMethodCount == 0) {
        return appendingMethods;
    }
    unsigned mergedMethodCount = existMethodCount + appendingMethodCount;
    Method *mergedMethods = malloc(mergedMethodCount * sizeof(Method));

    // 把原来的方法复制
    memcpy(mergedMethods, existMethods, existMethodCount * sizeof(Method));
    // 追加新的方法
    memcpy(mergedMethods + existMethodCount, appendingMethods, appendingMethodCount * sizeof(Method));

    // 返回方法的首地址
    return mergedMethods;
}

void _pk_extension_merge(PKExtendProtocol *extendedProtocol, Class containerClass) {
    // 对象方法
    unsigned appendingInstanceMethodCount = 0;
    // 从containerClass 中获得方法列表
    Method *appendingInstanceMethods = class_copyMethodList(containerClass, &appendingInstanceMethodCount);
    Method *mergedInstanceMethods = _pk_extension_create_merged(extendedProtocol->instanceMethods, extendedProtocol->instanceMethodCount, appendingInstanceMethods, appendingInstanceMethodCount);

    // 释放原来的内存空间
    free(extendedProtocol->instanceMethods);
    extendedProtocol->instanceMethods = mergedInstanceMethods;
    extendedProtocol->instanceMethodCount += appendingInstanceMethodCount;

    // 类方法
    unsigned appendingClassMethodCount = 0;
    Method *appendingClassMethods = class_copyMethodList(object_getClass(containerClass), &appendingClassMethodCount);
    Method *mergedClassMethods = _pk_extension_create_merged(extendedProtocol->classMethods, extendedProtocol->classMethodCount, appendingClassMethods, appendingClassMethodCount);

    free(extendedProtocol->classMethods);
    extendedProtocol->classMethods = mergedClassMethods;
    extendedProtocol->classMethodCount += appendingClassMethodCount;
}

void _pk_extension_load(Protocol *protocol, Class containerClass) {
    // 加锁
    pthread_mutex_lock(&protocolLoadingLock);

    if (extendedProtocolCount >= extendedProtocolCapacity) {
        size_t newCapacity = 0;
        if (extendedProtocolCapacity == 0) {
            newCapacity = 1;
        } else {
            newCapacity = extendedProtocolCapacity << 1;
        }
        // allExtendedProtocols 用于保存所有的 PKExtendedProtocol 结构体
        allExtendedProtocols = realloc(allExtendedProtocols, sizeof(*allExtendedProtocols) * newCapacity);
    }

    // 在静态区变量中寻找或创建传入的 protocol 对应的 PKExtendedProtocol 结构体
    size_t resultIndex = SIZE_T_MAX;
    for (size_t index = 0; index < extendedProtocolCount; index++) {
        if (allExtendedProtocols[index].protocol == protocol) {
            resultIndex = index;
            break;
        }
    }

    if (resultIndex == SIZE_T_MAX) {
        allExtendedProtocols[extendedProtocolCount] = (PKExtendProtocol){
            .protocol = protocol,
            .instanceMethods = NULL,
            .instanceMethodCount = 0,
            .classMethods = NULL,
            .classMethodCount = 0,
        };
        resultIndex = extendedProtocolCount;
        extendedProtocolCount++;
    }

    _pk_extension_merge(&(allExtendedProtocols[resultIndex]), containerClass);
    pthread_mutex_unlock(&protocolLoadingLock);
}

/**
 *  方法注入，即动态添加方法
 */
static void _pk_extension_inject_class (Class targetClass, PKExtendProtocol extendedProtocol) {
    // 动态添加对象方法
    for (unsigned methodIndex = 0; methodIndex < extendedProtocol.instanceMethodCount; ++methodIndex) {
        Method method = extendedProtocol.instanceMethods[methodIndex];
        SEL selector = method_getName(method);

        if (class_getInstanceMethod(targetClass, selector)) {
            continue;
        }

        IMP imp = method_getImplementation(method);
        const char *type = method_getTypeEncoding(method);
        class_addMethod(targetClass, selector, imp, type);
    }

    // 动态添加类方法
    Class targetMetaClass = object_getClass(targetClass);
    for (unsigned methodIndex = 0; methodIndex < extendedProtocol.classMethodCount; ++methodIndex) {
        Method method = extendedProtocol.classMethods[methodIndex];
        SEL selector = method_getName(method);

        if (selector == @selector(load) || selector == @selector(initialize)) {
            continue;
        }
        if (class_getInstanceMethod(targetMetaClass, selector)) {
            continue;
        }

        IMP imp = method_getImplementation(method);
        const char *types = method_getTypeEncoding(method);
        class_addMethod(targetMetaClass, selector, imp, types);
    }
}

__attribute__((constructor)) static void _pk_extension_inject_entry(void) {
    pthread_mutex_unlock(&protocolLoadingLock);
    unsigned classCount = 0;
    // 查询所有的类
    Class *allClasses = objc_copyClassList(&classCount);

    @autoreleasepool {
        for (unsigned protocolIndex = 0; protocolIndex < extendedProtocolCount; ++protocolIndex) {
            PKExtendProtocol extendedProtocol = allExtendedProtocols[protocolIndex];
            for (unsigned classIndex = 0; classIndex < classCount; ++ classIndex) {
                Class class = allClasses[classIndex];
                if (!class_conformsToProtocol(class, extendedProtocol.protocol)) {
                    continue;
                }
                NSLog(@"%@",class);
                // 如果类有遵守对应的协议，就进行注入
                _pk_extension_inject_class(class, extendedProtocol);
            }
        }
    }

    pthread_mutex_unlock(&protocolLoadingLock);

    free(allClasses);
    free(allExtendedProtocols);
    extendedProtocolCount = 0;
    extendedProtocolCapacity = 0;
}