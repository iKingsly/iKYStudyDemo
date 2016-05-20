//
//  Student.h
//  testRouter
//
//  Created by 郑钦洪 on 16/5/20.
//  Copyright © 2016年 iKingsly. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Student : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *age;
- (instancetype)initWithName:(NSString *)name age:(NSString *)age;
@end
