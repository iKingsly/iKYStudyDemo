//
//  RWTFlickrPhoto.h
//  RWTFlickrSearch
//
//  Created by 郑钦洪 on 16/6/8.
//  Copyright © 2016年 Colin Eberhardt. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RWTFlickrPhoto : NSObject
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, copy) NSString *identifier;
@end
