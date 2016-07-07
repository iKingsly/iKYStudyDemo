//
//  TargetClass+Swizzle.m
//  Aspect
//
//  Created by 郑钦洪 on 16/7/7.
//  Copyright © 2016年 iKingsly. All rights reserved.
//

#import "TargetClass+Swizzle.h"
#import "JRSwizzle.h"
#import "AspectClass.h"
@implementation TargetClass (Swizzle)
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSError *error = nil;
        [TargetClass jr_swizzleMethod:@selector(show) withMethod:@selector(aspect_show) error:&error];
    });
}

- (void)aspect_show {
    // 1. 目标方法执行前
    [AspectClass beforeTarget];
    
    // 2. 目标方法执行
    [self aspect_show];
    
    // 3. 目标方法执行后
    [AspectClass afterTarget];
}
@end
