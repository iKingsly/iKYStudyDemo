//
//  ECBCalibur.h
//  Pods
//
//  Created by 圣迪 on 15/12/15.
//
//

#import <Foundation/Foundation.h>

#define ECB_EXCALIBUR_ROUTE_SCHEME_FOR_CLASS(schemeString) \
\
+ (void)load { \
    static dispatch_once_t onceToken; \
    dispatch_once(&onceToken, ^{ \
    [ECBCalibur registerScheme:schemeString \
                      forClass:[self class]]; \
    }); \
}

#define ECB_SYNTHESIZE_SINGLETON_FOR_HEADER(className) \
\
+ (nullable className *)shared##className;

#define ECB_SYNTHESIZE_SINGLETON_FOR_CLASS(className) \
\
+ (className *)shared##className { \
    static className *shared##className = nil; \
    static dispatch_once_t onceToken; \
    dispatch_once(&onceToken, ^{ \
        shared##className = [[self alloc] init]; \
    }); \
    return shared##className; \
}

NS_ASSUME_NONNULL_BEGIN

@interface ECBCalibur : NSObject

@end

@interface ECBCalibur (ECBRegister)

+ (void)registerScheme:(NSString *)scheme
                 forClass:(__unsafe_unretained Class)aClass;
+ (void)unregisterScheme:(NSString *)scheme;

@end

@interface ECBCalibur (ECBMapping)

+ (nullable __unsafe_unretained Class)classForScheme:(NSString *)scheme;
+ (nullable NSString *)schemeForClass:(__unsafe_unretained Class)aClass;
+ (nullable id)instanceForClassScheme:(NSString *)classScheme;
+ (nullable id)sharedInstanceForClassScheme:(NSString *)classScheme;

@end

@interface ECBCalibur (ECBTransition)

+ (void)pushFromNavigationController:(id)naviController
            toViewControllerByScheme:(NSString *)scheme
                          withParams:(nullable NSDictionary *)params
                            animated:(BOOL)animated;

+ (void)presentViewControllerFromVC:(id)oriViewController
           toViewControllerByScheme:(NSString *)scheme
                         withParams:(nullable NSDictionary *)params
                           animated:(BOOL)animated
                         completion:(void (^ __nullable)(void))completion;
@end

#pragma mark - UINavigationController Category
@interface UINavigationController (ECBCalibur)

- (void)ecbPushViewControllerByScheme:(NSString *)scheme
                             animated:(BOOL)animated;

@end

#pragma mark - UIViewController Category
@interface UIViewController (ECBCalibur)

- (void)ecbPresentViewControllerByScheme:(NSString *)scheme
                                animated:(BOOL)animated
                              completion:(void (^ __nullable)(void))completion;

@end

NS_ASSUME_NONNULL_END
