//
//  iKYOperation.h
//  iKYOperation
//
//  Created by 郑钦洪 on 16/6/13.
//  Copyright © 2016年 iKingsly. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSUInteger, iKYOpetationStatus) {
    iKYOperationStatusReady  = 1, // 准备就绪
    iKYOperationStatusExcuting = 2, // 正在执行
    iKYOperationStatusPaused = 3, // 已经暂停
    iKYOperationStatusFinished = 4, // 已经结束
};

@interface iKYOperation : NSOperation
@property (nonatomic, strong, readonly) NSSet *runLoopModes;
@end
