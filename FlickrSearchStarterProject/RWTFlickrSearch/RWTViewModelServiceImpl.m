//
//  RWTViewModelServiceImpl.m
//  RWTFlickrSearch
//
//  Created by 郑钦洪 on 16/6/8.
//  Copyright © 2016年 Colin Eberhardt. All rights reserved.
//

#import "RWTViewModelServiceImpl.h"
#import "RWTFlickrSearchImpl.h"
#import "RWTSearchResultsViewController.h"
@interface RWTViewModelServiceImpl()
@property (nonatomic, strong) RWTFlickrSearchImpl *searchService;
@property (nonatomic, weak) UINavigationController *navigationController;
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
- (instancetype)initWithNavigationController:(UINavigationController *)navigationController{
    if (self = [super init]) {
        _searchService = [RWTFlickrSearchImpl new];
        _navigationController = navigationController;
    }
    return self;
}

#pragma mark - protocol
- (void)pushViewModel:(id)viewModel{
    id viewController;
    if ([viewModel isKindOfClass:RWTSearchResultsViewModel.class]) {
        viewController = [[RWTSearchResultsViewController alloc] initWithViewModel:viewModel];
    } else {
        NSLog(@"an unknow ViewModel was pushedf!");
    }
    
    [self.navigationController pushViewController:viewController animated:YES];
}
@end
