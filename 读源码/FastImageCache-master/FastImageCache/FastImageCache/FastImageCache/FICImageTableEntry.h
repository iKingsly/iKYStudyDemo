//
//  FICImageTableEntry.h
//  FastImageCache
//
//  Copyright (c) 2013 Path, Inc.
//  See LICENSE for full license agreement.
//

#import "FICImports.h"

@class FICImageTableChunk;
@class FICImageCache;

typedef struct {
    // 这个图像的UUID
    CFUUIDBytes _entityUUIDBytes;
    // 原图像的UUID
    CFUUIDBytes _sourceImageUUIDBytes;
} FICImageTableEntryMetadata;

/**
 ` FICImageTableEntry`代表在image table中的入口。它包含必要的数据和元数据存储的图象数据的单个入口。Entry 从< FICImageTableChunk >实例中创建`
 */
@interface FICImageTableEntry : NSObject

///---------------------------------------------
/// @name Accessing Image Table Entry Properties
///---------------------------------------------

/**
 entry 中 data 的字节长度
 @discussion Entries begin with the image data, followed by the metadata struct.
 */
@property (nonatomic, assign, readonly) size_t length;

/**
 image 的字节大小
 */
@property (nonatomic, assign, readonly) size_t imageLength;

/**
 表示Entry的数据中的字节。
 */
@property (nonatomic, assign, readonly) void *bytes;

/**
 实体UUID 与 entry 关联
 */
@property (nonatomic, assign) CFUUIDBytes entityUUIDBytes;

/**
 源的UUID 与 entry 关联
 */
@property (nonatomic, assign) CFUUIDBytes sourceImageUUIDBytes;

/**
 包含着歌entry的 chunk对象
 */
@property (nonatomic, readonly) FICImageTableChunk *imageTableChunk;

/**
 A weak reference to the image cache that contains the image table chunk that contains this entry.
 一个weak指针指向image cache（包含的chunk 包含了这个 entry的cache）
 */
@property (nonatomic, weak) FICImageCache *imageCache;

/**
 The index where this entry exists in the image table.
 这个entry在 image table 中的下标
 */
@property (nonatomic, assign) NSInteger index;

///----------------------------------
/// @name Image Table Entry Lifecycle
///----------------------------------

/**
 Initializes a new image table entry from an image table chunk.
 
 @param imageTableChunk The image table chunk that contains the entry data.
 
 @param bytes The bytes from the chunk that contain the entry data.
 
 @param length The length, in bytes, of the entry data.
 
 @return A new image table entry.
 */
- (instancetype)initWithImageTableChunk:(FICImageTableChunk *)imageTableChunk bytes:(void *)bytes length:(size_t)length;

/**
 Adds a block to be executed when this image table entry is deallocated.
 
 @param block A block that will be called when this image table entry is deallocated.
 
 @note Because of the highly-concurrent nature of Fast Image Cache, image tables must know when any of their entries are about to be deallocated to disassociate them with its internal data structures.
 */
- (void)executeBlockOnDealloc:(dispatch_block_t)block;

/**
 Forces the kernel to page in the memory-mapped, on-disk data backing this entry right away.
 */
- (void)preheat;

///--------------------------------------------
/// @name Flushing a Modified Image Table Entry
///--------------------------------------------

/**
 Writes a modified image table entry back to disk.
 */
- (void)flush;

///--------------------------------------------
/// @name Versioning Image Table Entry Metadata
///--------------------------------------------

/**
 Returns the current metadata version for image table entries.
 
 @return The integer version number of the current metadata version.
 
 @discussion Whenever the `<FICImageTableEntryMetadata>` struct is changed in any way, the metadata version must be changed.
 */
+ (NSInteger)metadataVersion;

@end
