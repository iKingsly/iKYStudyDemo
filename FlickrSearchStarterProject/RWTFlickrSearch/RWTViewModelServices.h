//
//  RWTViewModelServices.h
//  RWTFlickrSearch
//
//  Created by 郑钦洪 on 16/6/8.
//  Copyright © 2016年 Colin Eberhardt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RWTFlickrSearch.h"

@protocol RWTViewModelServices <NSObject>
- (id<RWTFlickrSearch>)getFlickrSearchService;
- (void)pushViewModel:(id)viewModel;
@end
