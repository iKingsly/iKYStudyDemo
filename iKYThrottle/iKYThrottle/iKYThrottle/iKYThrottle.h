//
//  iKYThrottle.h
//  iKYThrottle
//
//  Created by 郑钦洪 on 16/8/15.
//  Copyright © 2016年 iKingsly. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void (^GCDThrottleBlock) ();
@interface iKYThrottle : NSObject
void dispatch_throttle(NSTimeInterval threshold, GCDThrottleBlock block);
void dispatch_throttle_on_queue(NSTimeInterval threshold, dispatch_queue_t queue, GCDThrottleBlock block);


+ (void)throttle:(NSTimeInterval) second
           block:(GCDThrottleBlock) block;

+ (void)throttle:(NSTimeInterval) second
           queue:(dispatch_queue_t) queue
           block:(GCDThrottleBlock) block ;
@end
