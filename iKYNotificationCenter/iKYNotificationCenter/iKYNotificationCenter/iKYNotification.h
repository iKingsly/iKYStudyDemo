//
//  iKYNotification.h
//  iKYNotificationCenter
//
//  Created by 郑钦洪 on 16/6/14.
//  Copyright © 2016年 iKingsly. All rights reserved.
//

#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN
@interface iKYNotification : NSObject
/**
 *  观察者
 */
@property (nonatomic, assign) id observer;
/**
 *  观察者的方法
 */
@property (nonatomic, assign) SEL selector;
/**
 *  观察者的值
 */
@property (nonatomic, copy) NSString *name;
/**
 *  返回参数
 */
@property (nonatomic, strong) id object;
@end
NS_ASSUME_NONNULL_END