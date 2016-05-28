//
//  Person.m
//  iKYModel
//
//  Created by 郑钦洪 on 16/5/27.
//  Copyright © 2016年 iKingsly. All rights reserved.
//

#import "Person.h"
#import <objc/runtime.h>
@implementation Person
- (NSDictionary *)allProperties{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    unsigned int count = 0;
    Ivar *ivars = class_copyIvarList([self class], &count);
    for (NSUInteger  i = 0; i < count; i++) {
        const char *name = ivar_getName(ivars[i]);
        NSString *nameString = [NSString stringWithUTF8String:name];
        dict[nameString] = @"";
    }
    return [dict copy];
}
@end
