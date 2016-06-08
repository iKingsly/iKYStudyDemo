//
//  RWTSearchResultsViewModel.m
//  RWTFlickrSearch
//
//  Created by 郑钦洪 on 16/6/8.
//  Copyright © 2016年 Colin Eberhardt. All rights reserved.
//

#import "RWTSearchResultsViewModel.h"

@implementation RWTSearchResultsViewModel
- (instancetype)initWithSearchResults:(RWTFlickrSearchResults *)results servieces:(id<RWTViewModelServices>)services{
    if (self = [super init]) {
        _title = results.searchString;
        _searchResults = results.photos;
    }
    return self;
}
@end
