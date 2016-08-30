//
//  iKYDispatchQueuePool.h
//  iKYDispatchQueuePool
//
//  Created by 郑钦洪 on 16/8/29.
//  Copyright © 2016年 iKingsly. All rights reserved.
//

#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN
@interface iKYDispatchQueuePool : NSObject
/// Pool's name.
@property (nullable, nonatomic, readonly) NSString *name;

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;

/// Get a serial queue from pool.
- (dispatch_queue_t)queue;

+ (instancetype)defaultPoolForQOS:(NSQualityOfService)qos;

- (instancetype)initWithName:(NSString *)name queueCount:(NSUInteger)queueCount qos:(NSQualityOfService)qos;
@end

/// Get a serial queue from global queue pool with a specified qos.
extern dispatch_queue_t iKYDispatchQueueGetForQOS(NSQualityOfService qos);
NS_ASSUME_NONNULL_END