//
//  Favourite.h
//  testRouter
//
//  Created by 郑钦洪 on 16/5/20.
//  Copyright © 2016年 iKingsly. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Favourite : NSObject
@property (nonatomic, strong) NSString * subject;
@property (nonatomic, strong) NSString * others;
- (instancetype)initWithSubject:(NSString *)subject other:(NSString *)other;
@end
