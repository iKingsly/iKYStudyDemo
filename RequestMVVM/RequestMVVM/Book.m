//
//  Book.m
//  RequestMVVM
//
//  Created by 郑钦洪 on 16/6/10.
//  Copyright © 2016年 iKingsly. All rights reserved.
//

#import "Book.h"

@implementation Book
+ (instancetype)bookWithDictionary:(NSDictionary *)dict{
    Book *book = [[Book alloc] init];
    book.title = dict[@"title"];
    book.subTitle = dict[@"subtitle"];
    return book;
}
@end
