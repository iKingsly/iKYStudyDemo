//
//  YYKVStorage.h
//  YYCache <https://github.com/ibireme/YYCache>
//
//  Created by ibireme on 15/4/22.
//  Copyright (c) 2015 ibireme.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 YYKVStorageItem is used by `YYKVStorage` to store key-value pair and meta data.
 Typically, you should not use this class directly.
 */
@interface YYKVStorageItem : NSObject
/// key
@property (nonatomic, strong) NSString *key;                ///< key
/// value
@property (nonatomic, strong) NSData *value;                ///< value
/// 缓存文件名
@property (nullable, nonatomic, strong) NSString *filename; ///< filename (nil if inline)
/// 缓存大小
@property (nonatomic) int size;                             ///< value's size in bytes
/// 修改时间
@property (nonatomic) int modTime;                          ///< modification unix timestamp
/// 最后访问时间
@property (nonatomic) int accessTime;                       ///< last access unix timestamp
/// 拓展数据
@property (nullable, nonatomic, strong) NSData *extendedData; ///< extended data (nil if no extended data)
@end

/**
 Storage type, indicated where the `YYKVStorageItem.value` stored.
 
 @discussion Typically, write data to sqlite is faster than extern file, but 
 reading performance is dependent on data size. In my test (on iPhone 6 64G), 
 read data from extern file is faster than from sqlite when the data is larger 
 than 20KB.
 
 * If you want to store large number of small datas (such as contacts cache), 
   use YYKVStorageTypeSQLite to get better performance.
 * If you want to store large files (such as image cache),
   use YYKVStorageTypeFile to get better performance.
 * You can use YYKVStorageTypeMixed and choice your storage type for each item.
 
 See <http://www.sqlite.org/intern-v-extern-blob.html> for more information.
 */
/// 缓存类型
typedef NS_ENUM(NSUInteger, YYKVStorageType) {
    
    /// 直接存为File
    YYKVStorageTypeFile = 0,
    
    /// 用数据库进行缓存
    YYKVStorageTypeSQLite = 1,
    
    /// 如果filename != null，则value用文件缓存，缓存的其他参数用数据库缓存；如果filename == null,则用数据库缓存
    YYKVStorageTypeMixed = 2,
};



/**
 YYKVStorage is a key-value storage based on sqlite and file system.
 Typically, you should not use this class directly.
 
 @discussion The designated initializer for YYKVStorage is `initWithPath:type:`. 
 After initialized, a directory is created based on the `path` to hold key-value data.
 Once initialized you should not read or write this directory without the instance.
 
 You may compile the latest version of sqlite and ignore the libsqlite3.dylib in
 iOS system to get 2x~4x speed up.
 
 @warning The instance of this class is *NOT* thread safe, you need to make sure 
 that there's only one thread to access the instance at the same time. If you really 
 need to process large amounts of data in multi-thread, you should split the data
 to multiple KVStorage instance (sharding).
 */
@interface YYKVStorage : NSObject

#pragma mark - Attribute
///=============================================================================
/// @name Attribute
///=============================================================================
/// 缓存路径
@property (nonatomic, readonly) NSString *path;        ///< The path of this storage.
/// 缓存方式
@property (nonatomic, readonly) YYKVStorageType type;  ///< The type of this storage.
/// 是否要打印错误的日志
@property (nonatomic) BOOL errorLogsEnabled;           ///< Set `YES` to enable error logs for debug.

#pragma mark - Initializer
///=============================================================================
/// @name Initializer
///=============================================================================
/// 屏蔽之前使用的初始化方法
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;

/**
 初始化创建一个指定存储类型的YYKVStorage对象
 */
- (nullable instancetype)initWithPath:(NSString *)path type:(YYKVStorageType)type NS_DESIGNATED_INITIALIZER;


#pragma mark - Save Items
///=============================================================================
/// @name Save Items
///=============================================================================

/**
 保存一个YYKVStorageItem item对象
 
 根据YYKVStorageType来选择保存到的文件系统
 */
- (BOOL)saveItem:(YYKVStorageItem *)item;

/**
 对key和value保存一个item到文件系统中，如果key已经存在，则对缓存进行更新
 */
- (BOOL)saveItemWithKey:(NSString *)key value:(NSData *)value;

/**
  对key和value保存一个item到文件系统中，如果key已经存在，则对缓存进行更新
 @param key           The key, should not be empty (nil or zero length).
 @param value         The key, should not be empty (nil or zero length).
 @param filename      The filename.
 @param extendedData  The extended data for this item (pass nil to ignore it).
 
 @return Whether succeed.
 */
- (BOOL)saveItemWithKey:(NSString *)key
                  value:(NSData *)value
               filename:(nullable NSString *)filename
           extendedData:(nullable NSData *)extendedData;

#pragma mark - Remove Items
///=============================================================================
/// @name Remove Items
///=============================================================================

/**
 删除key对应的item
 */
- (BOOL)removeItemForKey:(NSString *)key;

/**
 删除key中对应的一系列item
 
 */
- (BOOL)removeItemForKeys:(NSArray<NSString *> *)keys;

/**
 删除大于size大小的item
 */
- (BOOL)removeItemsLargerThanSize:(int)size;

/**
 删除早于time访问的item
 */
- (BOOL)removeItemsEarlierThanTime:(int)time;

/**
 删除items使得总的size小于maxSize
 会根据LRU算法优先删除最先访问的item
 */
- (BOOL)removeItemsToFitSize:(int)maxSize;

/**
 删除items使得总的count小于maxCount
 会根据LRU算法优先删除最先访问的item
 */
- (BOOL)removeItemsToFitCount:(int)maxCount;

/**
 Remove all items in background queue.
 
 会创建一个容易用来转载数据库或者file，开启子线程在子线程中删除容器中的所有item
 
 @return Whether succeed.
 */
- (BOOL)removeAllItems;

/**
 删除缓存
 */
- (void)removeAllItemsWithProgressBlock:(nullable void(^)(int removedCount, int totalCount))progress
                               endBlock:(nullable void(^)(BOOL error))end;


#pragma mark - Get Items
///=============================================================================
/// @name Get Items
///=============================================================================

/**
 获得key对应的item
 */
- (nullable YYKVStorageItem *)getItemForKey:(NSString *)key;

/**
 获取key对应的itemInfo
 */
- (nullable YYKVStorageItem *)getItemInfoForKey:(NSString *)key;

/**
 获得key对应的NSData数据
 */
- (nullable NSData *)getItemValueForKey:(NSString *)key;

/**
 批量获取key对应的items
 */
- (nullable NSArray<YYKVStorageItem *> *)getItemForKeys:(NSArray<NSString *> *)keys;

/**
 批量获取keys对应的items Info
 */
- (nullable NSArray<YYKVStorageItem *> *)getItemInfoForKeys:(NSArray<NSString *> *)keys;

/**
 批量获取key对应的items data
 */
- (nullable NSDictionary<NSString *, NSData *> *)getItemValueForKeys:(NSArray<NSString *> *)keys;

#pragma mark - Get Storage Status
///=============================================================================
/// @name Get Storage Status
///=============================================================================

/**
 是否存在key对应的数据
 */
- (BOOL)itemExistsForKey:(NSString *)key;

/**
 获得总的item的数量
 */
- (int)getItemsCount;

/**
 获得总的占用的空间大小
 */
- (int)getItemsSize;

@end

NS_ASSUME_NONNULL_END
