//
//  UserHttpHandler.h
//  iKYHttpProxy
//
//  Created by 郑钦洪 on 16/8/3.
//  Copyright © 2016年 iKingsly. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol UserHttpHandler <NSObject>
- (void)getUserWithID:(NSNumber *)userID;
@end
