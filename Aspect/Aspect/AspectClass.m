//
//  AspectClass.m
//  Aspect
//
//  Created by 郑钦洪 on 16/7/7.
//  Copyright © 2016年 iKingsly. All rights reserved.
//

#import "AspectClass.h"

@implementation AspectClass
+ (void)beforeTarget {
    NSLog(@"我是Aspect，在目标方法【执行前】做的事情...\n");
}

+ (void)afterTarget {
    NSLog(@"我是Aspect，在目标方法【执行后】做的事情...\n");
}
@end
