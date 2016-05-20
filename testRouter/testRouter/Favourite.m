//
//  Favourite.m
//  testRouter
//
//  Created by 郑钦洪 on 16/5/20.
//  Copyright © 2016年 iKingsly. All rights reserved.
//

#import "Favourite.h"

@implementation Favourite
- (instancetype)initWithSubject:(NSString *)subject other:(NSString *)other{
    self = [super init];
    if (self) {
        self.subject = subject;
        self.others = other;
    }
    return self;
}

- (NSString *)description{
    NSString *string = [NSString stringWithFormat:@"subject:%@ other:%@",self.subject,self.others];
    return string;
}
@end
