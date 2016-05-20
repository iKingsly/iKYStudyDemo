//
//  secondViewController.h
//  testRAC
//
//  Created by 郑钦洪 on 16/5/19.
//  Copyright © 2016年 iKingsly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
@interface secondViewController : UIViewController
@property (nonatomic, strong) RACSubject *delegateSignal;
@end
