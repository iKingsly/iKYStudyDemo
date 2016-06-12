//
//  RequestViewModel.h
//  RequestMVVM
//
//  Created by 郑钦洪 on 16/6/10.
//  Copyright © 2016年 iKingsly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
@interface RequestViewModel : NSObject<UITableViewDataSource>
@property (nonatomic, strong, readonly) RACCommand *requestCommand;
@property (nonatomic, copy) NSArray *models;
@end
