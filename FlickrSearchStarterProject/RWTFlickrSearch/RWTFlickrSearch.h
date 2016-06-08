//
//  RWTFlickrSearch.h
//  RWTFlickrSearch
//
//  Created by 郑钦洪 on 16/6/8.
//  Copyright © 2016年 Colin Eberhardt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
@protocol RWTFlickrSearch <NSObject>
- (RACSignal *)flickrSeachSignal:(NSString *)searchString;
@end
