//
//  YYWebImageManager.h
//  YYWebImage <https://github.com/ibireme/YYWebImage>
//
//  Created by ibireme on 15/2/19.
//  Copyright (c) 2015 ibireme.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import <UIKit/UIKit.h>

#if __has_include(<YYWebImage/YYWebImage.h>)
#import <YYWebImage/YYImageCache.h>
#else
#import "YYImageCache.h"
#endif

@class YYWebImageOperation;

NS_ASSUME_NONNULL_BEGIN

/// 控制图片请求模式
typedef NS_OPTIONS(NSUInteger, YYWebImageOptions) {
    
    /// 发送一个网络加载菊花 当下载图片的时候
    YYWebImageOptionShowNetworkActivity = 1 << 0,
    
    /// 能够像浏览器一样显示一个逐渐显示的图片 有三种方法
    YYWebImageOptionProgressive = 1 << 1,
    

    /// 下载的时候显示一个模糊的渐渐显示的JPEG图片,或者一个交错显示的PNG图片
    YYWebImageOptionProgressiveBlur = 1 << 2,
    
    /// 使用NSUrlCache而不是YYCache
    YYWebImageOptionUseNSURLCache = 1 << 3,
    
    /// 允许使用未经认证的SSL证书
    YYWebImageOptionAllowInvalidSSLCertificates = 1 << 4,
    
    /// 允许后台下载图片 当app进入后台的时候
    YYWebImageOptionAllowBackgroundTask = 1 << 5,
    
    /// 缓存Cookiew
    YYWebImageOptionHandleCookies = 1 << 6,
    
    /// 从远端获取新的图片 然后更新本地图片
    YYWebImageOptionRefreshImageCache = 1 << 7,
    
    ///不要在本地磁盘加载图片.
    YYWebImageOptionIgnoreDiskCache = 1 << 8,
    
    /// 不要改变图片知道更改了URL
    YYWebImageOptionIgnorePlaceHolder = 1 << 9,
    
    /// 忽略图片解码
    /// 在下载的时候不会进行解码操作
    YYWebImageOptionIgnoreImageDecoding = 1 << 10,
    
    
    /// 不会进行多个帧的图片进行解码比如GIF/APNG/WebP/ICO 会把它们当作一个帧的图片来处理
    YYWebImageOptionIgnoreAnimatedImage = 1 << 11,
    
    /// 做一个渐变的效果
    YYWebImageOptionSetImageWithFadeAnimation = 1 << 12,
    
    /// 当下载好图片后不要set image  需要手动 set image
    YYWebImageOptionAvoidSetImage = 1 << 13,
    
    /// 添加URL黑名单
    YYWebImageOptionIgnoreFailedURL = 1 << 14,
};

/// 说明图片的来源
typedef NS_ENUM(NSUInteger, YYWebImageFromType) {
    
    /// 空
    YYWebImageFromNone = 0,
    
    /// 从内存中读取，如果你调用了"setImageWithURL..."并且图片已经存在于内存,你会从相同的回调里面得到这个值
    YYWebImageFromMemoryCacheFast,
    
    /// 内存中读取
    YYWebImageFromMemoryCache,
    
    /// 从硬盘中来
    YYWebImageFromDiskCache,
    
    /// 从远端中来
    YYWebImageFromRemote,
};

/// 图片获取的结果
typedef NS_ENUM(NSInteger, YYWebImageStage) {
    
    /// 图片获取中
    YYWebImageStageProgress  = -1,
    
    /// 图片获取取消
    YYWebImageStageCancelled = 0,
    
    /// 完成图片获取
    YYWebImageStageFinished  = 1,
};


/**
    图片下载进度block
 */
typedef void(^YYWebImageProgressBlock)(NSInteger receivedSize, NSInteger expectedSize);

/**
 图片从远程下载完成之前会执行这个block,用来执行一些额外的操作
 @discussion 当'YYWebImageCompletionBlock'这个完成度额回调在下载完成之前会执行这个回调用来给你一个机会做一些额外的处理,比如用来修改图片尺寸等.如果这里不需要对图片进行transform处理,只会返回image这一个参数
 @example 你可以裁剪/模糊图片,或者添加一些边角通过以下代码:
 ^(UIImage *image, NSURL *url){
 //可能你需要创建一个 @autoreleasepool来限制内存开销
 image = [image yy_imageByResizeToSize:CGSizeMake(100, 100) contentMode:UIViewContentModeScaleAspectFill];
 image = [image yy_imageByBlurRadius:20 tintColor:nil tintMode:kCGBlendModeNormal saturation:1.2 maskImage:nil];
 image = [image yy_imageByRoundCornerRadius:5];
 return image;
 }
 */
typedef UIImage * _Nullable (^YYWebImageTransformBlock)(UIImage *image, NSURL *url);

/// 这个方法会在completion或者cancel之后进行
typedef void (^YYWebImageCompletionBlock)(UIImage * _Nullable image,
                                          NSURL *url,
                                          YYWebImageFromType from,
                                          YYWebImageStage stage,
                                          NSError * _Nullable error);




/**
 一个管理器用来创建和管理web image 进程
 */
@interface YYWebImageManager : NSObject

/**
 返回全局的manager单例
 */
+ (instancetype)sharedManager;

/**
 创建一个指定队列的manager
 */
- (instancetype)initWithCache:(nullable YYImageCache *)cache
                        queue:(nullable NSOperationQueue *)queue NS_DESIGNATED_INITIALIZER;

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;

/**
 创建并且返回一个新的图片下载线程，这个线程会马上开始执行
 @param url        图片下载URL
 @param options    图片控制模式
 @param progress   下载过程的block.
 @param transform  下载后对图片进行处理的block.
 @param completion 下载完成后的处理 会在后台线程之行.
 @return A new image operation.
 */
- (nullable YYWebImageOperation *)requestImageWithURL:(NSURL *)url
                                              options:(YYWebImageOptions)options
                                             progress:(nullable YYWebImageProgressBlock)progress
                                            transform:(nullable YYWebImageTransformBlock)transform
                                           completion:(nullable YYWebImageCompletionBlock)completion;

/**
 用来做图片缓存的Cache
 */
@property (nullable, nonatomic, strong) YYImageCache *cache;

/**
 图片下载的处理队列
 可以用来控制最大的线程数目
 */
@property (nullable, nonatomic, strong) NSOperationQueue *queue;

/**
 这个block用来处理全局图片下载任务中对图片的处理
 */
@property (nullable, nonatomic, copy) YYWebImageTransformBlock sharedTransformBlock;

/**
 默认图片下载的超时时间
 */
@property (nonatomic) NSTimeInterval timeout;

/**
 NSURLCredential 中的 username
 */
@property (nullable, nonatomic, copy) NSString *username;

/**
 NSURLCredential 中的password
 */
@property (nullable, nonatomic, copy) NSString *password;

/**
 图片的http 请求头部 默认为Accept:image/webp,image
 */
@property (nullable, nonatomic, copy) NSDictionary<NSString *, NSString *> *headers;

/**
 每个图片http请求做额外的HTTP header操作的时候会调用这个block,默认为nil
 */
@property (nullable, nonatomic, copy) NSDictionary<NSString *, NSString *> *(^headersFilter)(NSURL *url, NSDictionary<NSString *, NSString *> * _Nullable header);

/**
 每个图片的操作都会调用这个block,默认为nil
 使用这个block能够给URL提供一个自定义的的图片
 */
@property (nullable, nonatomic, copy) NSString *(^cacheKeyFilter)(NSURL *url);

/**
 为一个特殊的url 设置http headers
 */
- (nullable NSDictionary<NSString *, NSString *> *)headersForURL:(NSURL *)url;

/**
 为特定的url 设置 cache key
 */
- (NSString *)cacheKeyForURL:(NSURL *)url;



/*  增加活跃的网络请求数量
    如果在增加前数量为0,那么会在状态来开始有一个网络菊花动画
    该方法是线程安全的
    该方法不会对APP扩展产生影响
*/
+ (void)incrementNetworkActivityCount;

/**
    减少活跃的网络请求数量
 */
+ (void)decrementNetworkActivityCount;

/**
 获得当前网络活跃请求数量
 */
+ (NSInteger)currentNetworkActivityCount;

@end

NS_ASSUME_NONNULL_END
