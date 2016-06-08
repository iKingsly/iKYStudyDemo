//
//  RWTSearchResultsViewModel.h
//  RWTFlickrSearch
//
//  Created by 郑钦洪 on 16/6/8.
//  Copyright © 2016年 Colin Eberhardt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RWTViewModelServices.h"
#import "RWTFlickrSearchResults.h"

@interface RWTSearchResultsViewModel : NSObject
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSArray *searchResults;

- (instancetype)initWithSearchResults:(RWTFlickrSearchResults *) results servieces:(id<RWTViewModelServices>) services;
@end
