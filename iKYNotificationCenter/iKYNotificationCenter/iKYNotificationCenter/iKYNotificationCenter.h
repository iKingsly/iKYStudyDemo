//
//  iKYNotificationCenter.h
//  iKYNotificationCenter
//
//  Created by 郑钦洪 on 16/6/14.
//  Copyright © 2016年 iKingsly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "iKYNotification.h"
NS_ASSUME_NONNULL_BEGIN
@interface iKYNotificationCenter : NSObject
+ (iKYNotificationCenter *)defaultCenter;

- (void)addObserver: (id)observer selector:(nonnull SEL)aSelector name:(nullable NSString *)aName object:(nullable id)anObject;

- (void)postNotification:(nullable NSString *)notificationName object:(id) objcet;

- (void)removeObserver:(id)observer;
@end
NS_ASSUME_NONNULL_END