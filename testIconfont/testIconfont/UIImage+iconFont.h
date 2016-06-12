//
//  UIImage+iconFont.h
//  testIconfont
//
//  Created by 郑钦洪 on 16/6/12.
//  Copyright © 2016年 iKingsly. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (iconFont)
/**
 *  用iconFont来生成对应的Image
 *
 *  @param iconCode iconFont编码
 *  @param fontName 字体名字
 *  @param size     图片大小
 *  @param color    图片颜色
 *
 *  @return iconFont对应的图片
 */
+ (UIImage *)imageWithIcon:(NSString *)iconCode inFont:(NSString *)fontName size:(NSUInteger)size color:(UIColor *)color;
@end
