//
//  YYWebImageOperation.h
//  YYWebImage <https://github.com/ibireme/YYWebImage>
//
//  Created by ibireme on 15/2/15.
//  Copyright (c) 2015 ibireme.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import <UIKit/UIKit.h>

#if __has_include(<YYWebImage/YYWebImage.h>)
#import <YYWebImage/YYImageCache.h>
#import <YYWebImage/YYWebImageManager.h>
#else
#import "YYImageCache.h"
#import "YYWebImageManager.h"
#endif

NS_ASSUME_NONNULL_BEGIN

/**
 The YYWebImageOperation class is an NSOperation subclass used to fetch image 
 from URL request.
 
 @discussion It's an asynchronous operation. You typically execute it by adding 
 it to an operation queue, or calls 'start' to execute it manually. When the 
 operation is started, it will:
 
     1. Get the image from the cache, if exist, return it with `completion` block.
     2. Start an URL connection to fetch image from the request, invoke the `progress`
        to notify request progress (and invoke `completion` block to return the 
        progressive image if enabled by progressive option).
     3. Process the image by invoke the `transform` block.
     4. Put the image to cache and return it with `completion` block.
 
 */
@interface YYWebImageOperation : NSOperation
/// 图片请求
@property (nonatomic, strong, readonly)           NSURLRequest      *request;
/// 响应体
@property (nullable, nonatomic, strong, readonly) NSURLResponse     *response;
/// 缓存
@property (nullable, nonatomic, strong, readonly) YYImageCache      *cache;
/// 缓存key
@property (nonatomic, strong, readonly)           NSString          *cacheKey;
/// 理解为下载图片模式,具体见YYWebImageManager
@property (nonatomic, readonly)                   YYWebImageOptions options;


/**
 *  这个URL connection 是否是从 存储的认证里面授权查阅出来的.默认值为YES
 @discussion 这个值是NSURLConnectionDelegate的方法-connectionShouldUseCredentialStorage:的返回值
 */
@property (nonatomic) BOOL shouldUseCredentialStorage;

/**
 NSURLCredential类
 */
@property (nullable, nonatomic, strong) NSURLCredential *credential;

/**
 *  构造方法,会创建并返回一个新的operation
 你应该调用start方法来开启这个operation,或者把它加到一个operation queue
 *
 *  @param request    图片请求,不可为nil
 *  @param options    下载模式
 *  @param cache      图片缓存,传nil的话就禁用了缓存
 *  @param cacheKey   缓存key,传nil禁用图片缓存
 *  @param progress   下载进度block
 *  @param transform  这个block会在图片下载完成之前调用来让你对图片进行一些预处理,传nil禁用
 *  @param completion 图片下载完成后或者已经取消下载了调用
 *
 *  @return operation实例,出现错误的话就为nil
 */
- (instancetype)initWithRequest:(NSURLRequest *)request
                        options:(YYWebImageOptions)options
                          cache:(nullable YYImageCache *)cache
                       cacheKey:(nullable NSString *)cacheKey
                       progress:(nullable YYWebImageProgressBlock)progress
                      transform:(nullable YYWebImageTransformBlock)transform
                     completion:(nullable YYWebImageCompletionBlock)completion NS_DESIGNATED_INITIALIZER;

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;

@end

NS_ASSUME_NONNULL_END
