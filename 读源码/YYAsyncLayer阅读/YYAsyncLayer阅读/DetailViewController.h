//
//  DetailViewController.h
//  YYAsyncLayer阅读
//
//  Created by 郑钦洪 on 16/7/19.
//  Copyright © 2016年 iKingsly. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end

