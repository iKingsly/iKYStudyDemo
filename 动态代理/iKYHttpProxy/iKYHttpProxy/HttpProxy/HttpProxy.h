//
//  HttpProxy.h
//  iKYHttpProxy
//
//  Created by 郑钦洪 on 16/8/3.
//  Copyright © 2016年 iKingsly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommentHttpHandler.h"
#import "UserHttpHandler.h"
#import "CommentHttpHandler.h"

@interface HttpProxy : NSProxy<CommentHttpHandler,UserHttpHandler>
+ (instancetype)shareInstance;
- (void)registerHttpProtocol:(Protocol *)httpProtocol handler:(id)handler;
@end
