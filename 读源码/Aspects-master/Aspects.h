//
//  Aspects.h
//  Aspects - A delightful, simple library for aspect oriented programming.
//
//  Copyright (c) 2014 Peter Steinberger. Licensed under the MIT license.
//

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSUInteger, AspectOptions) {
    // 在方法执行后调用
    AspectPositionAfter   = 0,            /// Called after the original implementation (default)
    // 替换原来的方法
    AspectPositionInstead = 1,            /// Will replace the original implementation.
    // 在原方法执行前调用
    AspectPositionBefore  = 2,            /// Called before the original implementation.
    // 在第一次执行后会自动移除hook
    AspectOptionAutomaticRemoval = 1 << 3 /// Will remove the hook after the first execution.
};

/// Opaque Aspect Token that allows to deregister the hook.
// Aspect是隐藏的 用来移除hook的协议
@protocol AspectToken <NSObject>

/// Deregisters an aspect.
/// @return YES if deregistration is successful, otherwise NO.
// 如果返回YES 就移除成功
- (BOOL)remove;

@end

/// The AspectInfo protocol is the first parameter of our block syntax.
// AspectInfo 协议是我们设置的block的第一个参数
@protocol AspectInfo <NSObject>
// 这两个方法都通过声明 property 会自动创建getter方法来实现
/// The instance that is currently hooked.
/// 返回当前被hook 的对象
- (id)instance;

/// The original invocation of the hooked method.
/// 被hook的原始方法
- (NSInvocation *)originalInvocation;

/// All method arguments, boxed. This is lazily evaluated.
/// 方法的所有参数， 这个方法是懒加载模式
- (NSArray *)arguments;

@end

/**
 Aspects uses Objective-C message forwarding to hook into messages. This will create some overhead. Don't add aspects to methods that are called a lot. Aspects is meant for view/controller code that is not called a 1000 times per second.

 Adding aspects returns an opaque token which can be used to deregister again. All calls are thread safe.
 */
/// Aspects 通过消息转发来做到hook。因此会有一定的性能损耗，不要使用在频繁调用的函数上
/// 添加 aspects 会返回一个隐私的token 用来移除hook
@interface NSObject (Aspects)

/// Adds a block of code before/instead/after the current `selector` for a specific class.
///
/// @param block Aspects replicates the type signature of the method being hooked.
/// The first parameter will be `id<AspectInfo>`, followed by all parameters of the method.
/// These parameters are optional and will be filled to match the block signature.
/// You can even use an empty block, or one that simple gets `id<AspectInfo>`.
///
/// @note Hooking static methods is not supported.
/// @return A token which allows to later deregister the aspect.
/// 两个方法 一个用来hook对象方法 一个用来hook类方法
/// selector ： 要hook的方法的selector
/// options ： hook的执行时机
/// block : 复制了正在被hook的方法签名
/// error : 错误的类型
+ (id<AspectToken>)aspect_hookSelector:(SEL)selector
                           withOptions:(AspectOptions)options
                            usingBlock:(id)block
                                 error:(NSError **)error;

/// Adds a block of code before/instead/after the current `selector` for a specific instance.
- (id<AspectToken>)aspect_hookSelector:(SEL)selector
                           withOptions:(AspectOptions)options
                            usingBlock:(id)block
                                 error:(NSError **)error;

@end


typedef NS_ENUM(NSUInteger, AspectErrorCode) {
    // 不能被hook的方法 像是release retain，autorelease
    AspectErrorSelectorBlacklisted,                   /// Selectors like release, retain, autorelease are blacklisted.
    // 找不到Selector
    AspectErrorDoesNotRespondToSelector,              /// Selector could not be found.

    AspectErrorSelectorDeallocPosition,               /// When hooking dealloc, only AspectPositionBefore is allowed.
    // 已经hook 父类的 同名方法
    AspectErrorSelectorAlreadyHookedInClassHierarchy, /// Statically hooking the same method in subclasses is not allowed.
    AspectErrorFailedToAllocateClassPair,             /// The runtime failed creating a class pair.
    AspectErrorMissingBlockSignature,                 /// The block misses compile time signature info and can't be called.
    AspectErrorIncompatibleBlockSignature,            /// The block signature does not match the method or is too large.

    AspectErrorRemoveObjectAlreadyDeallocated = 100   /// (for removing) The object hooked is already deallocated.
};

extern NSString *const AspectErrorDomain;
