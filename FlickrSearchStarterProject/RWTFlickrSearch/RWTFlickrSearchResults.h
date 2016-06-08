//
//  RWTFlickrSearchResults.h
//  RWTFlickrSearch
//
//  Created by 郑钦洪 on 16/6/8.
//  Copyright © 2016年 Colin Eberhardt. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RWTFlickrSearchResults : NSObject
@property (strong, nonatomic) NSString *searchString;
@property (strong, nonatomic) NSArray *photos;
@property (nonatomic) NSUInteger totalResults;
@end
