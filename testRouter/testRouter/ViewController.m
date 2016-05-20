//
//  ViewController.m
//  testRouter
//
//  Created by 郑钦洪 on 16/5/20.
//  Copyright © 2016年 iKingsly. All rights reserved.
//

#import "ViewController.h"
#import "Student.h"
#import "Favourite.h"

@interface ViewController ()

@end

@implementation ViewController
ECB_EXCALIBUR_ROUTE_SCHEME_FOR_CLASS(@"viewcontroller")
- (void)viewDidLoad {
    [super viewDidLoad];
//    Class aClass = [ECBCalibur classForScheme:@"secondViewController"];
//    NSLog(@"%@",NSStringFromClass(aClass));
//
//    id instance = [ECBCalibur instanceForClassScheme:@"secondViewController"];
//    [self.navigationController ecbPushViewControllerByScheme:@"secondViewController" animated:YES];
//    
//    NSDictionary *dic = [NSDictionary dictionary];
//    
//    NSMapTable *table = [NSMapTable mapTableWithKeyOptions:NSMapTableStrongMemory valueOptions:NSMapTableStrongMemory];
//    [table setObject:aClass forKey:dic];
//    NSLog(@"%@",table);
//    NSLog(@"%@",[table objectForKey:dic]);
    Student *student1 = [[Student alloc] initWithName:@"Kingsly" age:@"21"];
    Student *student2 = [[Student alloc] initWithName:@"Rose" age:@"18"];
    
    Favourite *favourite1 = [[Favourite alloc] initWithSubject:@"iOS" other:@"py"];
    Favourite *favourite2 = [[Favourite alloc] initWithSubject:@"java" other:@"php"];
    
    NSMapTable *table = [NSMapTable mapTableWithKeyOptions:NSMapTableStrongMemory valueOptions:NSMapTableStrongMemory];
    [table setObject:favourite2 forKey:student2];
    [table setObject:favourite1 forKey:student1];
    student1.name = @"iKingsly";
    
    
    NSLog(@"%@",table);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
