//
//  GCDThrottle.h
//  GCDThrottle
//
//  Created by cyan on 16/5/24.
//  Copyright © 2016年 cyan. All rights reserved.
//

#import <Foundation/Foundation.h>

#define THROTTLE_MAIN_QUEUE             (dispatch_get_main_queue())
#define THROTTLE_GLOBAL_QUEUE           (dispatch_get_global_queue(0, 0))

typedef void (^GCDThrottleBlock) ();

@interface GCDThrottle : NSObject

void dispatch_throttle(NSTimeInterval threshold, GCDThrottleBlock block);
void dispatch_throttle_on_queue(NSTimeInterval threshold, dispatch_queue_t queue, GCDThrottleBlock block);

+ (void)throttle:(NSTimeInterval)threshold block:(GCDThrottleBlock)block;
+ (void)throttle:(NSTimeInterval)threshold queue:(dispatch_queue_t)queue block:(GCDThrottleBlock)block;

@end
