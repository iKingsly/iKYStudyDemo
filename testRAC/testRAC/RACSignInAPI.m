//
//  RACSignInAPI.m
//  testRAC
//
//  Created by 郑钦洪 on 16/5/20.
//  Copyright © 2016年 iKingsly. All rights reserved.
//

#import "RACSignInAPI.h"

@implementation RACSignInAPI
- (BOOL)initWithName:(NSString *)name password:(NSString *)password{
    if ([name isEqualToString:@"Kingsly"]||[password isEqualToString:@"666"]) {
        return YES;
    }
    return NO;
}
@end
