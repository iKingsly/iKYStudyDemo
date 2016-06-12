//
//  ViewController.m
//  testIconfont
//
//  Created by 郑钦洪 on 16/6/12.
//  Copyright © 2016年 iKingsly. All rights reserved.
//

#import "ViewController.h"
#import "UIImage+iconFont.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 60, 300, 60)];
    label.font = [UIFont fontWithName:@"icomoon" size:60];
    label.text = @"\U0000E900";
    label.textColor = [UIColor redColor];
    [self.view addSubview:label];
    
    UIImage *image = [UIImage imageWithIcon:@"\U0000E901" inFont:@"icomoon" size:100 color:[UIColor orangeColor]];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    [self.view addSubview:imageView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
