//
//  RWTViewModelServiceImpl.m
//  RWTFlickrSearch
//
//  Created by 郑钦洪 on 16/6/8.
//  Copyright © 2016年 Colin Eberhardt. All rights reserved.
//

#import "RWTViewModelServiceImpl.h"
#import "RWTFlickrSearchImpl.h"
@interface RWTViewModelServiceImpl()
@property (nonatomic, strong) RWTFlickrSearchImpl *searchService;
@end
@implementation RWTViewModelServiceImpl
- (instancetype)init{
    if (self = [super init]) {
        _searchService = [RWTFlickrSearchImpl new];
    }
    return self;
}

- (id<RWTFlickrSearch>)getFlickrSearchService{
    return self.searchService;
}
@end
