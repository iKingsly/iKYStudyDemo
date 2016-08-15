//
//  iKYThrottle.m
//  iKYThrottle
//
//  Created by 郑钦洪 on 16/8/15.
//  Copyright © 2016年 iKingsly. All rights reserved.
//

#import "iKYThrottle.h"
/// 用堆栈的信息来当作key
#define ThreadCallStackSymbol       [NSThread callStackSymbols][1]
#define THROTTLE_MAIN_QUEUE             (dispatch_get_main_queue())
#define THROTTLE_GLOBAL_QUEUE           (dispatch_get_global_queue(0, 0))
@implementation iKYThrottle
+ (NSMutableDictionary *)scheduledSources {
    static NSMutableDictionary *dict = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dict = [NSMutableDictionary dictionary];
    });
    return dict;
}

void dispatch_throttle(NSTimeInterval threshold, GCDThrottleBlock block) {
    [iKYThrottle throttle:threshold queue:THROTTLE_MAIN_QUEUE key:ThreadCallStackSymbol block:block];
}

void dispatch_throttle_on_queue(NSTimeInterval threshold, dispatch_queue_t queue, GCDThrottleBlock block) {
    [iKYThrottle throttle:threshold queue:queue key:ThreadCallStackSymbol block:block];
}

+ (void)throttle:(NSTimeInterval) second block:(GCDThrottleBlock) block {
    [self throttle:second queue:THROTTLE_MAIN_QUEUE key:ThreadCallStackSymbol block:block];
}

+ (void)throttle:(NSTimeInterval) second queue:(dispatch_queue_t) queue block:(GCDThrottleBlock) block {
    [self throttle:second queue:queue key:ThreadCallStackSymbol block:block];
}
/// 便利构造器
void _dispatch_throttle_on_queue(NSTimeInterval threshold, dispatch_queue_t queue, NSString *key, GCDThrottleBlock block) {
    [iKYThrottle throttle:threshold queue:queue key:key block:block];
}

+ (void)throttle:(NSTimeInterval) second queue:(dispatch_queue_t) queue key:(NSString *)key block:(GCDThrottleBlock) block {
    NSMutableDictionary *dict = self.scheduledSources;

    dispatch_source_t source = dict[key];
    if (source) {
        dispatch_source_cancel(source);
    }

    source = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);

    dispatch_source_set_timer(source, dispatch_time(DISPATCH_TIME_NOW, second * NSEC_PER_SEC), DISPATCH_TIME_FOREVER, 0);

    dispatch_source_set_event_handler(source, ^{
        block();
        dispatch_source_cancel(source);
        [dict removeObjectForKey:key];
    });

    // 让定时器开启
    dispatch_resume(source);

    dict[key] = source;
}
@end
