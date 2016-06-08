//
//  RWTFlickrSearchModel.h
//  RWTFlickrSearch
//
//  Created by 郑钦洪 on 16/6/8.
//  Copyright © 2016年 Colin Eberhardt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "RWTViewModelServices.h"
@interface RWTFlickrSearchViewModel : NSObject
@property (strong, nonatomic) NSString *searchText;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) RACCommand *executeSearch;
- (instancetype) initWithServices:(id<RWTViewModelServices>)services;
@end
