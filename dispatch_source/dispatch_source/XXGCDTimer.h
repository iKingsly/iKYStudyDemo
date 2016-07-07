//
//  XXGCDTimer.h
//  dispatch_source
//
//  Created by 郑钦洪 on 16/7/7.
//  Copyright © 2016年 iKingsly. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XXGCDTimer : NSObject
/** Array */
@property (nonatomic,strong) NSMutableArray *array;
- (void)startGCDTimer;

- (void) pauseTimer;

- (void) resumeTimer;

- (void) stopTimer;

@end
