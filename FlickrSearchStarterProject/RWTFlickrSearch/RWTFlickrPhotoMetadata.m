//
//  RWTFlickrPhotoMetadata.m
//  RWTFlickrSearch
//
//  Created by 郑钦洪 on 16/6/8.
//  Copyright © 2016年 Colin Eberhardt. All rights reserved.
//

#import "RWTFlickrPhotoMetadata.h"

@implementation RWTFlickrPhotoMetadata
- (NSString *)description{
    return [NSString stringWithFormat:@"metadata: comments = %lU,faves=%lU",(unsigned long)self.comments,(unsigned long)self.favorites];
}
@end
