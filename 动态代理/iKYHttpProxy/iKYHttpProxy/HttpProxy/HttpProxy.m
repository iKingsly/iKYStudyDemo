//
//  HttpProxy.m
//  iKYHttpProxy
//
//  Created by 郑钦洪 on 16/8/3.
//  Copyright © 2016年 iKingsly. All rights reserved.
//

#import "HttpProxy.h"
#import <objc/runtime.h>

@interface HttpProxy ()
@property (nonatomic, strong) NSMutableDictionary *selToHandlerMap;
@end

@implementation HttpProxy

#pragma mark - Public methods
+ (instancetype)shareInstance {
    static HttpProxy *shareInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [HttpProxy alloc];
        shareInstance.selToHandlerMap = [NSMutableDictionary dictionary];
    });
    return shareInstance;
}

- (void)registerHttpProtocol:(Protocol *)httpProtocol handler:(id)handler {
    unsigned int numberOfMethods = 0;
    struct objc_method_description *methods = protocol_copyMethodDescriptionList(httpProtocol, YES, YES, &numberOfMethods);
    
    // 注册protocol methods
    for (unsigned int i = 0; i < numberOfMethods; i++) {
        struct objc_method_description method = methods[i];
        [_selToHandlerMap setObject:handler forKey:NSStringFromSelector(method.name)];
    }
}

#pragma mark - Methods Route
- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    NSString *methodsName = NSStringFromSelector(sel);
    id handler = [_selToHandlerMap objectForKey:methodsName];
    if (handler != nil && [handler respondsToSelector:sel]) {
        return [handler methodSignatureForSelector:sel];
    } else {
        return [super methodSignatureForSelector:sel];
    }
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    NSString *methodsName = NSStringFromSelector(invocation.selector);
    id handler = [_selToHandlerMap objectForKey:methodsName];
    
    if (handler != nil && [handler respondsToSelector:invocation.selector]) {
        [invocation invokeWithTarget:handler];
    } else {
        [super forwardInvocation:invocation];
    }
}
@end
