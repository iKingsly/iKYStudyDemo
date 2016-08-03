//
//  main.m
//  iKYHttpProxy
//
//  Created by 郑钦洪 on 16/8/3.
//  Copyright © 2016年 iKingsly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HttpProxy.h"
#import "CommentHttpHandlerImp.h"
#import "UserHttpHandlerImp.h"
int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...

        [[HttpProxy shareInstance] registerHttpProtocol:@protocol(UserHttpHandler) handler:[UserHttpHandlerImp new]];
        [[HttpProxy shareInstance] registerHttpProtocol:@protocol(CommentHttpHandler) handler:[CommentHttpHandlerImp new]];
        
        //call
        [[HttpProxy shareInstance] getUserWithID:@100];
        [[HttpProxy shareInstance] getCommentsWithDate:[NSDate new]];
    }
    return 0;
}
