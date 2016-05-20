//
//  Student.m
//  testRouter
//
//  Created by 郑钦洪 on 16/5/20.
//  Copyright © 2016年 iKingsly. All rights reserved.
//

#import "Student.h"

@implementation Student
- (instancetype)initWithName:(NSString *)name age:(NSString *)age{
    self = [super init];
    if (self) {
        self.name = name;
        self.age = age;
    }
    return self;
}

- (NSString *)description{
    NSString *string = [NSString stringWithFormat:@"name:%@ age:%@",self.name,self.age];
    return string;
}
@end
