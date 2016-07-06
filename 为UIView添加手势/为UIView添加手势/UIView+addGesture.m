//
//  UIView+addGesture.m
//  为UIView添加手势
//
//  Created by 郑钦洪 on 16/7/6.
//  Copyright © 2016年 iKingsly. All rights reserved.
//

#import "UIView+addGesture.h"
#import <objc/runtime.h>
static NSString const *kAddGestureKey = @"AddGestureKey";
static NSString const *kAddGestureBlock = @"AddGestureBlock";
@implementation UIView (addGesture)

- (void)iKY_setTapActionWithBlock:(void (^)(void))block {
    UITapGestureRecognizer *tap = objc_getAssociatedObject(self, &kAddGestureKey);
    if (!tap) {
        tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(iKY_handlerActionWithGesture:)];
        [self addGestureRecognizer:tap];
        objc_setAssociatedObject(self, &kAddGestureKey, tap, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    objc_setAssociatedObject(self, &kAddGestureBlock, block, OBJC_ASSOCIATION_COPY_NONATOMIC);
}


- (void)iKY_handlerActionWithGesture:(UITapGestureRecognizer *)tap{
    if (tap.state == UIGestureRecognizerStateRecognized) {
        void (^block) (void) = objc_getAssociatedObject(self, &kAddGestureBlock);
        if (block) {
            block();
        }
    }
}
@end
