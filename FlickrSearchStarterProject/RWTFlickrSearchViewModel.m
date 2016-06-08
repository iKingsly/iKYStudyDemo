//
//  RWTFlickrSearchModel.m
//  RWTFlickrSearch
//
//  Created by 郑钦洪 on 16/6/8.
//  Copyright © 2016年 Colin Eberhardt. All rights reserved.
//

#import "RWTFlickrSearchViewModel.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
@interface RWTFlickrSearchViewModel()
@property (nonatomic, weak) id<RWTViewModelServices> services;
@end
@implementation RWTFlickrSearchViewModel
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize{
    self.title = @"Flickr Search";
    RACSignal *validSearchSignal = [[RACObserve(self, searchText) map:^id(NSString *text) {
        return @(text.length > 3);
    }] distinctUntilChanged];
    
    [validSearchSignal subscribeNext:^(id x) {
        NSLog(@"search text is validf %@",x);
    }];
    
    self.executeSearch = [[RACCommand alloc] initWithEnabled:validSearchSignal signalBlock:^RACSignal *(id input) {
        return [self executeSearchSignal];
    }];
}

- (RACSignal *)executeSearchSignal{
    return [[[self.services getFlickrSearchService] flickrSeachSignal:self.searchText] logAll];
}

- (instancetype)initWithServices:(id<RWTViewModelServices>)services{
    self = [super init];
    if (self) {
        _services = services;
        [self initialize];
    }
    return self;
}
@end
