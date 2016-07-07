//
//  AspectClass.h
//  Aspect
//
//  Created by 郑钦洪 on 16/7/7.
//  Copyright © 2016年 iKingsly. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AspectClass : NSObject
/**
 *  拦截到目标方法执行前，做的事情...
 */
+ (void)beforeTarget;

/**
 *  拦截到目标方法执行后，做的事情...
 */
+ (void)afterTarget;
@end
