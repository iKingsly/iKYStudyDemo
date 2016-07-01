//
//  UIButton+Throttle.m
//  解决按钮重复点击
//
//  Created by 郑钦洪 on 16/7/1.
//  Copyright © 2016年 iKingsly. All rights reserved.
//

#import "UIButton+Throttle.h"
#import <objc/runtime.h>
static const char *iKY_DurationTimeString = "iKY_DurationTime";
static NSTimeInterval iKY_CurrentTime;

@implementation UIButton (Throttle)
- (void)setIKY_ThrottleTime:(NSTimeInterval)iKY_ThrottleTime {
    objc_setAssociatedObject(self, iKY_DurationTimeString, @(iKY_ThrottleTime), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSTimeInterval)iKY_ThrottleTime {
    return [objc_getAssociatedObject(self, iKY_DurationTimeString) doubleValue];
}

#pragma mark - 实现方法交换

+ (void)load {
    Method a = class_getInstanceMethod([self class], @selector(sendAction:to:forEvent:));
    Method b = class_getInstanceMethod([self class], @selector(iKY_sendAction:to:forEvent:));
    method_exchangeImplementations(a, b);
}

- (void)iKY_sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event {
    if ([[NSDate date] timeIntervalSince1970] - iKY_CurrentTime < self.iKY_ThrottleTime) {
        return;
    }
    
    if (self.iKY_ThrottleTime > 0.0) {
        iKY_CurrentTime = [[NSDate date] timeIntervalSince1970];
    }
    
    [self iKY_sendAction:action to:target forEvent:event];
}

@end
