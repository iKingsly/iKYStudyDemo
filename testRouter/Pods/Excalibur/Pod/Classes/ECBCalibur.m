//
//  ECBCalibur.m
//  Pods
//
//  Created by 圣迪 on 15/12/15.
//
//

#import "ECBCalibur.h"
#import <objc/runtime.h>
#import <objc/message.h>

/**
 *  place pointer here to improve the efficiency in accessing
 *  the sharedInstance.
 */
static ECBCalibur *sharedInstance = nil;

@interface ECBCalibur ()

@property (nonatomic, strong) NSMapTable *mapTable;

@end

@implementation ECBCalibur

+ (void)initialize {
    [ECBCalibur sharedEXCCalibur];
}

+ (instancetype)sharedEXCCalibur {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        self.mapTable = [NSMapTable mapTableWithKeyOptions:NSMapTableStrongMemory
                                              valueOptions:NSMapTableWeakMemory];
    }
    return self;
}

- (void)addScheme:(nonnull NSString *)scheme forClass:(nonnull __unsafe_unretained Class)aClass {
    [self checkSchemeValidation:scheme];
    [self.mapTable setObject:aClass
                      forKey:[scheme stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
}

- (void)removeScheme:(nonnull NSString *)scheme {
    [self checkSchemeValidation:scheme];
    [self.mapTable removeObjectForKey:
     [scheme stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
}

- (void)checkSchemeValidation:(nonnull NSString *)scheme {
    if (!scheme) {
        [NSException raise:@"Nill Scheme"
                    format:@"You should not input nill scheme"];
    }
    if ([[scheme stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]
         isEqualToString:@""]) {
        [NSException raise:@"Blank Scheme"
                    format:@"You should not input blank scheme"];
    }
}

@end

#pragma mark - EXCRegister
@implementation ECBCalibur (EXCRegister)

+ (void)registerScheme:(nonnull NSString *)scheme
              forClass:(nonnull __unsafe_unretained Class)aClass {
    NSParameterAssert(scheme);
    NSParameterAssert(aClass);
    if ([ECBCalibur classForScheme:scheme]) {
        [NSException raise:@"Scheme Already Exists"
                    format:@"'%@' Scheme Already Exists", scheme];
        return;
    }
    if ([ECBCalibur schemeForClass:aClass]) {
        [NSException raise:@"Class Already Exists"
                    format:@"'%@' Class Already Exists", NSStringFromClass(aClass)];
        return;
    }
    if (![aClass isSubclassOfClass:[NSObject class]]) {
        [NSException raise:@"Wrong Class Type"
                    format:@"Class should inherit from NSObject"];
        return;
    }
    if ([scheme isEqualToString:@""]) {
        [NSException raise:@"Scheme Wrong"
                    format:@"Scheme should not be blank"];
        return;
    }
    [sharedInstance addScheme:scheme forClass:aClass];
}

+ (void)unregisterScheme:(nonnull NSString *)scheme {
    NSParameterAssert(scheme);
    [sharedInstance removeScheme:scheme];
}

@end

#pragma mark - ECBMapping
@implementation ECBCalibur (ECBMapping)

+ (nullable __unsafe_unretained Class)classForScheme:(nonnull NSString *)scheme {
    return [sharedInstance.mapTable objectForKey:scheme];
}

+ (nullable NSString *)schemeForClass:(nonnull __unsafe_unretained Class)aClass {
    NSEnumerator *enumerator = [sharedInstance.mapTable keyEnumerator];
    NSString *key;
    
    while ((key = [enumerator nextObject])) {
        Class bClass = [sharedInstance.mapTable objectForKey:key];
        if (bClass == aClass) {
            return key;
        }
    }
    return nil;
}

+ (nullable id)instanceForClassScheme:(nonnull NSString *)classScheme {
    Class aClass = [ECBCalibur classForScheme:classScheme];
    if (aClass) {
        id aInstance = [[aClass alloc] init];
        return aInstance;
    } else {
        return nil;
    }
}

+ (nullable id)sharedInstanceForClassScheme:(nonnull NSString *)classScheme {
    Class aClass = [ECBCalibur classForScheme:classScheme];
    if (aClass) {
        NSString *sharedInstacneString = [NSString stringWithFormat:@"shared%@", NSStringFromClass(aClass)];
        SEL sharedInstanceSelector     = NSSelectorFromString(sharedInstacneString);
        if ([aClass respondsToSelector:sharedInstanceSelector]) {
            id (*typed_msgSend)(id, SEL) = (void *)objc_msgSend;
            id aInstance = typed_msgSend(aClass, sharedInstanceSelector);
            return aInstance;
        } else {
            return nil;
        }
    } else {
        return nil;
    }
}

@end

#pragma mark - ECBTransition
@implementation ECBCalibur (EXCTransition)

+ (nullable UIViewController *)getViewControllerFromScheme:(nonnull NSString *)scheme
                                              andSetParams:(nullable NSDictionary *)params {
    Class className = [sharedInstance.mapTable objectForKey:scheme];
    if (!className) {
        [NSException raise:@"ViewController Not Found"
                    format:@"The ViewController corresponding to your scheme %@ can NOT be found", scheme];
        return nil;
    }
    UIViewController *viewController = [[className alloc] init];
    if (params) {
        [params enumerateKeysAndObjectsUsingBlock:^(id  __nonnull key, id  __nonnull obj, BOOL * stop) {
            NSAssert([key isKindOfClass:[NSString class]], @"Should be NSString");
            /**
             *  In case of some unexpected problems and
             *  in order to support custom getter method,
             *  use setValue:forKey: method directly.
             */
            [viewController setValue:obj forKey:key];
        }];
    }
    return viewController;
}

+ (void)pushFromNavigationController:(id)naviController
            toViewControllerByScheme:(NSString *)scheme
                          withParams:(NSDictionary *)params
                            animated:(BOOL)animated {
    NSParameterAssert(naviController);
    NSParameterAssert(scheme);
    if (![naviController isKindOfClass:[UINavigationController class]]) {
        [NSException raise:@"Wrong Type" format:@"instance should inherit from UINavigationController"];
        return;
    }
    UIViewController *viewController = [ECBCalibur getViewControllerFromScheme:scheme andSetParams:params];
    [(UINavigationController *)naviController pushViewController:viewController animated:animated];
}

+ (void)presentViewControllerFromVC:(id)oriViewController
           toViewControllerByScheme:(NSString *)scheme
                         withParams:(NSDictionary *)params
                           animated:(BOOL)animated
                         completion:(void (^)(void))completion {
    NSParameterAssert(oriViewController);
    NSParameterAssert(scheme);
    if (![oriViewController isKindOfClass:[UIViewController class]]) {
        [NSException raise:@"Wrong Type" format:@"instance should inherit from UIViewController"];
        return;
    }
    UIViewController *viewController = [ECBCalibur getViewControllerFromScheme:scheme andSetParams:params];
    [(UIViewController *)oriViewController presentViewController:viewController
                                                        animated:animated
                                                      completion:completion];
}

@end

#pragma mark - UINavigationController Category
@implementation UINavigationController (ECBCalibur)

- (void)ecbPushViewControllerByScheme:(NSString *)scheme
                             animated:(BOOL)animated {
    [ECBCalibur pushFromNavigationController:self
                    toViewControllerByScheme:scheme
                                  withParams:nil
                                    animated:animated];
}

@end

#pragma mark - UIViewController Category
@implementation UIViewController (ECBCalibur)

- (void)ecbPresentViewControllerByScheme:(NSString *)scheme
                                animated:(BOOL)animated
                              completion:(void (^)(void))completion {
    [ECBCalibur presentViewControllerFromVC:self
                   toViewControllerByScheme:scheme
                                 withParams:nil
                                   animated:animated
                                 completion:completion];
}

@end
