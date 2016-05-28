//
//  Person.h
//  iKYModel
//
//  Created by 郑钦洪 on 16/5/27.
//  Copyright © 2016年 iKingsly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Dog.h"

@interface Person : NSObject
{
    NSString *name;
    Dog *dog;
    NSString *sex;
    int age;
    NSArray *array;
}
- (NSDictionary *)allProperties;
@end
