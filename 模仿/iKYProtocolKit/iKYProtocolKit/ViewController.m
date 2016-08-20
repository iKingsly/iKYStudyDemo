//
//  ViewController.m
//  iKYProtocolKit
//
//  Created by 郑钦洪 on 16/8/18.
//  Copyright © 2016年 iKingsly. All rights reserved.
//

#import "ViewController.h"
#import "PKProtocolExtension.h"

// Protocol

@protocol Forkable <NSObject>

@optional
- (void)fork;

@required
- (NSString *)github;

@end

// Protocol Extension

@defs(Forkable)

- (void)fork {
    NSLog(@"Forkable protocol extension: I'm forking (%@).", self.github);
}

- (NSString *)github {
    return @"This is a required method, concrete class must override me.";
}


@end


@interface ViewController ()<Forkable>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self fork];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
