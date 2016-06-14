//
//  iKYNotificationCenter.m
//  iKYNotificationCenter
//
//  Created by 郑钦洪 on 16/6/14.
//  Copyright © 2016年 iKingsly. All rights reserved.
//

#import "iKYNotificationCenter.h"

@interface iKYNotificationCenter()
@property (nonatomic, strong) NSMutableArray *notifactionArray;
@end

@implementation iKYNotificationCenter
+ (iKYNotificationCenter *)defaultCenter {
    static iKYNotificationCenter *center = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        center = [iKYNotificationCenter new];
    });
    
    return center;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.notifactionArray = [NSMutableArray array];
    }
    return self;
}

- (void)addObserver:(id)observer selector:(SEL)aSelector name:(NSString *)aName object:(id)anObject {
    iKYNotification *notification = [iKYNotification new];
    notification.observer = observer;
    notification.selector = aSelector;
    notification.name = aName;
    
    [self.notifactionArray addObject:notification];
}

- (void)postNotification:(NSString *)notificationName object:(id)objcet{
    for (iKYNotification *notification in self.notifactionArray) {
        notification.object = objcet;
        [notification.observer performSelector:notification.selector withObject:objcet];
    }
}

- (void)postNotification:(NSNotification *)notification {
    [self postNotification:notification object:nil];
}
@end
