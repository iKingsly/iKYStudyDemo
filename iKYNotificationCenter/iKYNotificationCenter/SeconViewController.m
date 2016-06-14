//
//  SeconViewController.m
//  iKYNotificationCenter
//
//  Created by 郑钦洪 on 16/6/14.
//  Copyright © 2016年 iKingsly. All rights reserved.
//

#import "SeconViewController.h"
#import "iKYNotificationCenter.h"
static NSString * const  NotificationKey = @"CHANGECOLOR";
@implementation SeconViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    [[iKYNotificationCenter defaultCenter] postNotification:NotificationKey object:nil];
}
@end
