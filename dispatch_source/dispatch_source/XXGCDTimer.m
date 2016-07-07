//
//  XXGCDTimer.m
//  dispatch_source
//
//  Created by 郑钦洪 on 16/7/7.
//  Copyright © 2016年 iKingsly. All rights reserved.
//

#import "XXGCDTimer.h"
@interface XXGCDTimer()
{
    dispatch_source_t _timer;
    dispatch_queue_t _queue;
}
@end
@implementation XXGCDTimer
- (instancetype)init
{
    self = [super init];
    if (self) {
        _queue = dispatch_queue_create("abccc", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}
- (void)startGCDTimer {
    NSTimeInterval period = 1.0;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(_timer, DISPATCH_TIME_NOW, period * NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(_timer, ^{
        NSLog(@"每秒执行test");
    });
    
    dispatch_resume(_timer);
}

- (void) pauseTimer {
    if (_timer) {
        dispatch_suspend(_timer);
    }
}

- (void) resumeTimer {
    if (_timer) {
        dispatch_resume(_timer);
    }
}

- (void) stopTimer {
    if (_timer) {
        dispatch_source_cancel(_timer);
        _timer = nil;
    }
}

@end
