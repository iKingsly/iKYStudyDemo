//
//  main.m
//  iKYModel
//
//  Created by 郑钦洪 on 16/5/27.
//  Copyright © 2016年 iKingsly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Person.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        Person *per = [Person new];
        NSArray *array = @[@"a",@"b"];
        [per setValue:array forKey:@"array"];
//        [per setValue:@"K" forKey:@"dog.name"];
        NSDictionary *dict = [per allProperties];
        NSLog(@"%@",dict);
        
    }
    return 0;
}
