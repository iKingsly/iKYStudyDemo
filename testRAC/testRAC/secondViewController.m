//
//  secondViewController.m
//  testRAC
//
//  Created by 郑钦洪 on 16/5/19.
//  Copyright © 2016年 iKingsly. All rights reserved.
//

#import "secondViewController.h"
#import "Masonry.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface secondViewController ()

@end

@implementation secondViewController
- (IBAction)notice:(id)sender {
    // notic first viewcontroller the button did touch
    if(self.delegateSignal){
        // 有值才需要通知
        [self.delegateSignal sendNext:@"Hi kingsly"];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor orangeColor];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(100, 100, 100, 100);
    [button setTitle:@"Notification" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(notice:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
