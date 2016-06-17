//
//  ViewController.m
//  studyJSpatch
//
//  Created by 郑钦洪 on 16/6/17.
//  Copyright © 2016年 iKingsly. All rights reserved.
//

#import "ViewController.h"
#import <JSPatch/JPEngine.h>
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [JPEngine startEngine];
    
    [JPEngine evaluateScript:@"\
     var alertView = require('UIAlertView').alloc().init();\
     alertView.setTitle('Alert');\
     alertView.setMessage('AlertView from js'); \
     alertView.addButtonWithTitle('OK');\
     alertView.show(); \
     "];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
