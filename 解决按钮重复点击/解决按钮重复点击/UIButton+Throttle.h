//
//  UIButton+Throttle.h
//  解决按钮重复点击
//
//  Created by 郑钦洪 on 16/7/1.
//  Copyright © 2016年 iKingsly. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (Throttle)
/** 点击间隔时间 */
@property (nonatomic,assign) NSTimeInterval iKY_ThrottleTime;

@end
