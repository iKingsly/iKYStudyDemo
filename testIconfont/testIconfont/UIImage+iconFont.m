//
//  UIImage+iconFont.m
//  testIconfont
//
//  Created by 郑钦洪 on 16/6/12.
//  Copyright © 2016年 iKingsly. All rights reserved.
//

#import "UIImage+iconFont.h"

@implementation UIImage (iconFont)
+ (UIImage *)imageWithIcon:(NSString *)iconCode
                    inFont:(NSString *)fontName
                      size:(NSUInteger)size
                     color:(UIColor *)color {
    CGSize imagefSize = CGSizeMake(size, size);
    UIGraphicsBeginImageContextWithOptions(imagefSize, NO, [UIScreen mainScreen].scale);
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, size, size)];
    label.font = [UIFont fontWithName:fontName size:size];
    label.text = iconCode;
    if (color) {
        label.textColor = color;
    }
    [label.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *retImage = UIGraphicsGetImageFromCurrentImageContext();
    return retImage;
}
@end
