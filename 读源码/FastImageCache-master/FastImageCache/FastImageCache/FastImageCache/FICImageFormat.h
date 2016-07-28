//
//  FICImageFormat.h
//  FastImageCache
//
//  Copyright (c) 2013 Path, Inc.
//  See LICENSE for full license agreement.
//

#import "FICImports.h"

@class FICImageTable;

// Image显示的设备
typedef NS_OPTIONS(NSUInteger, FICImageFormatDevices) {
    FICImageFormatDevicePhone = 1 << UIUserInterfaceIdiomPhone,
    FICImageFormatDevicePad = 1 << UIUserInterfaceIdiomPad,
};

typedef NS_ENUM(NSUInteger, FICImageFormatStyle) {
    // 全色彩 带透明通道，每个图像8位，还有一个8位的alpha通道
    FICImageFormatStyle32BitBGRA,
    // 全色彩 不带透明通道，每个图像8位，还有一个8位的保留位
    FICImageFormatStyle32BitBGR,
    // 减弱的色彩 不带透明通道，每个图像8位，还有一个1位的保留位
    FICImageFormatStyle16BitBGR,
    // 灰色图片 不带透明通道
    FICImageFormatStyle8BitGrayscale,
};

// 图片的保护模式
typedef NS_ENUM(NSUInteger, FICImageFormatProtectionMode) {
    FICImageFormatProtectionModeNone,
    FICImageFormatProtectionModeComplete,
    FICImageFormatProtectionModeCompleteUntilFirstUserAuthentication,
};

/**
 FICImageFormat`充当存储在图像缓存中的图像类型。各图像格式必须有一个唯一的名字，但多种格式可以属于同一家族。
 与特定格式相关联的所有图片必须具有相同的图像dimentions和不透明性设置。可以定义图像格式可容纳的最大条目数
 防止图像缓存占用过多的磁盘空间。每个图像缓存管理的` < FICImageTable >`与单个图像格式有关。
 */

@interface FICImageFormat : NSObject <NSCopying>

///------------------------------
/// @name Image Format Properties
///------------------------------

/**
 The name of the image format. Each image format must have a unique name.
 
 @note Since multiple instances of Fast Image Cache can exist in the same application, it is important that image format name's be unique across all instances of `<FICImageCache>`. Reverse DNS naming
 is recommended (e.g., com.path.PTUserProfilePhotoLargeImageFormat).
 */
/**
 *  每一个图片格式必须有不相同的名字
    由于FastImageCache可以存在在同一个应用中，所以明知必须不相同，使用的是反DNS命名建议
 */
@property (nonatomic, copy) NSString *name;

/**
 这个可选的family是指 image format 归属于哪个组。同一个family关联image formats
 
 @discussion If you are using the image cache to create several different cached variants of the same source image, all of those variants would be unique image formats that share the same family.
 如果你使用image cache 去创建几个不同的cache变量 指向同一个源图片，所有的这写变量会用不同的图片格式并且共享同一个family的图片格式

 For example, you might define a `userPhoto` family that groups together image formats with the following names: `userPhotoSmallThumbnail`, `userPhotoLargeThumbnail`, `userPhotoLargeThumbnailBorder`.

 理想的情况下，相同的源图像可以被处理以​​用于属于同一家族每个图像格式创建缓存的图像数据
 `<FICImageCache>` provides its delegate a chance to process all image formats in a given family at the same time when a particular entity-image format pair is being processed. This allows you to process
 a source image once instead of having to download and process the same source image multiple times for different formats in the same family.
 
 @see [FICImageCacheDelegate imageCache:shouldProcessAllFormatsInFamily:forEntity:]
 */
@property (nonatomic, copy) NSString *family;

/**
 由format来决定这个图片在 imagetable 中保存的大小
 */
@property (nonatomic, assign) CGSize imageSize;

/**
 *  图片的格式
 */
@property (nonatomic, assign)  FICImageFormatStyle style;

/**
 一个image table 可以包含这个image format 的最大数量

 这个image format的最大数量会被插入到 imagetable 的最后一次image format 给覆盖
 */
@property (nonatomic, assign) NSInteger maximumCount;

/**
 这个image table 显示的设备
 */
@property (nonatomic, assign) FICImageFormatDevices devices;

/**
 屏幕的scale
 */
@property (nonatomic, assign, readonly) CGSize pixelSize;

/**
 The bitmap info associated with the images created with this image format.
 与此 image format 创建的图片 相关的位图信息。
 */
@property (nonatomic, assign, readonly) CGBitmapInfo bitmapInfo;

/**
 The number of bytes each pixel of an image created with this image format occupies.
 */
@property (nonatomic, assign, readonly) NSInteger bytesPerPixel;

/**
 The number of bits each pixel component (e.g., blue, green, red color channels) uses for images created with this image format.
 */
@property (nonatomic, assign, readonly) NSInteger bitsPerComponent;

/**
 是否为灰度图片
 */
@property (nonatomic, assign, readonly) BOOL isGrayscale;

/**
 The data protection mode that image table files will be created with.
 
 `FICImageFormatProtectionMode` has the following values:
 
 - `FICImageFormatProtectionModeNone`: No data protection is used. image table 文件支持这种图像格式将始终可以进行读取和写入。 - `FICImageFormatProtectionModeComplete`: 一旦系统使数据保护（即，当设备被锁定），图像表文件支持这一形象
格式将不提供用于读取和写入。其结果是，这种格式的图像不应该被快速图像缓存执行后台运行代码时请求 - `FICImageFormatProtectionModeCompleteUntilFirstUserAuthentication`: Partial data protection is used. After a device restart, until the user unlocks the device for the first time, complete data
 protection is in effect. However, after the device has been unlocked for the first time, the image table file backing this image format will remain available for readin and writing. This mode may be
 a good compromise between encrypting image table files after the device powers down and allowing the files to be accessed successfully by Fast Image Cache, whether or not the device is subsequently
 locked.
 
 @note Data protection can prevent Fast Image Cache from accessing its image table files to read and write image data. If the image data being stored in Fast Image Cache is not sensitive in nature,
 consider using `FICImageFormatProtectionModeNone` to prevent any issues accessing image table files when the disk is encrypted.
 */
@property (nonatomic, assign) FICImageFormatProtectionMode protectionMode;

/**
 The string representation of `<protectionMode>`.
 */
@property (nonatomic, assign, readonly) NSString *protectionModeString;

/**
 The dictionary representation of this image format.
 
 @discussion Fast Image Cache automatically serializes the image formats that it uses to disk. If an image format ever changes, Fast Image Cache automatically detects the change and invalidates the
 image table associated with that image format. The image table is then recreated from the updated image format.
 */
@property (nonatomic, copy, readonly) NSDictionary *dictionaryRepresentation;

///-----------------------------------
/// @name Initializing an Image Format
///-----------------------------------

/**
 Convenience initializer to create a new image format.
 
 @param name The name of the image format. Each image format must have a unique name.
 
 @param family The optional family that the image format belongs to. See the `<family>` property description for more information.
 
 @param imageSize The size, in points, of the images stored in the image table created by this format.
 
 @param style The style of the image format. See the `<style>` property description for more information.
 
 @param maximumCount The maximum number of entries that an image table can contain for this image format.
 
 @param devices A bitmask of type `<FICImageFormatDevices>` that defines which devices are managed by an image table.
 
 @param protectionMode The data protection mode to use when creating the backing image table file for this image format. See the `<protectionMode>` property description for more information.
 
 @return An autoreleased instance of `FICImageFormat` or one of its subclasses, if any exist.
 */
+ (instancetype)formatWithName:(NSString *)name family:(NSString *)family imageSize:(CGSize)imageSize style:(FICImageFormatStyle)style maximumCount:(NSInteger)maximumCount devices:(FICImageFormatDevices)devices protectionMode:(FICImageFormatProtectionMode)protectionMode;

@end
