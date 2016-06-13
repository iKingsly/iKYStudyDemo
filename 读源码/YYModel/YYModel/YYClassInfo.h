//
//  YYClassInfo.h
//  YYModel <https://github.com/ibireme/YYModel>
//
//  Created by ibireme on 15/5/9.
//  Copyright (c) 2015 ibireme.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Type encoding's type.
 */
typedef NS_OPTIONS(NSUInteger, YYEncodingType) {
    // 低八位的值： 变量的数据类型
    YYEncodingTypeMask       = 0xFF, ///< mask of type value
    // 未知类型
    YYEncodingTypeUnknown    = 0, ///< unknown
    // 变量的数据类型
    // 基础数据类型
    YYEncodingTypeVoid       = 1, ///< void
    YYEncodingTypeBool       = 2, ///< bool
    YYEncodingTypeInt8       = 3, ///< char / BOOL
    YYEncodingTypeUInt8      = 4, ///< unsigned char
    YYEncodingTypeInt16      = 5, ///< short
    YYEncodingTypeUInt16     = 6, ///< unsigned short
    YYEncodingTypeInt32      = 7, ///< int
    YYEncodingTypeUInt32     = 8, ///< unsigned int
    YYEncodingTypeInt64      = 9, ///< long long
    YYEncodingTypeUInt64     = 10, ///< unsigned long long
    YYEncodingTypeFloat      = 11, ///< float
    YYEncodingTypeDouble     = 12, ///< double
    YYEncodingTypeLongDouble = 13, ///< long double
    // 1. 自定义类型 2.NSObject
    YYEncodingTypeObject     = 14, ///< id
    // Class 类型
    YYEncodingTypeClass      = 15, ///< Class
    // SEL字符串
    YYEncodingTypeSEL        = 16, ///< SEL
    YYEncodingTypeBlock      = 17, ///< block
    YYEncodingTypePointer    = 18, ///< void*
    YYEncodingTypeStruct     = 19, ///< struct
    YYEncodingTypeUnion      = 20, ///< union
    // 字符串
    YYEncodingTypeCString    = 21, ///< char*
    // 数组
    YYEncodingTypeCArray     = 22, ///< char[10] (for example)
    
    // 取得8~16位的值类型 ： 方法类型
    YYEncodingTypeQualifierMask   = 0xFF00,   ///< mask of qualifier
    YYEncodingTypeQualifierConst  = 1 << 8,  ///< const
    YYEncodingTypeQualifierIn     = 1 << 9,  ///< in
    YYEncodingTypeQualifierInout  = 1 << 10, ///< inout
    YYEncodingTypeQualifierOut    = 1 << 11, ///< out
    YYEncodingTypeQualifierBycopy = 1 << 12, ///< bycopy
    YYEncodingTypeQualifierByref  = 1 << 13, ///< byref
    YYEncodingTypeQualifierOneway = 1 << 14, ///< oneway
    
    // 取得16～24位的值类型 ： 属性的附加修饰类型
    YYEncodingTypePropertyMask         = 0xFF0000, ///< mask of property
    YYEncodingTypePropertyReadonly     = 1 << 16, ///< readonly
    YYEncodingTypePropertyCopy         = 1 << 17, ///< copy
    YYEncodingTypePropertyRetain       = 1 << 18, ///< retain
    YYEncodingTypePropertyNonatomic    = 1 << 19, ///< nonatomic
    YYEncodingTypePropertyWeak         = 1 << 20, ///< weak
    YYEncodingTypePropertyCustomGetter = 1 << 21, ///< getter=
    YYEncodingTypePropertyCustomSetter = 1 << 22, ///< setter=
    YYEncodingTypePropertyDynamic      = 1 << 23, ///< @dynamic
};

/**
 Get the type from a Type-Encoding string.
 
 @discussion See also:
 https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html
 https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtPropertyIntrospection.html
 
 @param typeEncoding  A Type-Encoding string.
 @return The encoding type.
 */
YYEncodingType YYEncodingGetType(const char *typeEncoding);


/**
 Instance variable information.
 增加了对IVar的描述
 */
@interface YYClassIvarInfo : NSObject
@property (nonatomic, assign, readonly) Ivar ivar;              ///< ivar
@property (nonatomic, strong, readonly) NSString *name;         ///< 变量名
@property (nonatomic, assign, readonly) ptrdiff_t offset;       ///< 变量偏移地址
@property (nonatomic, strong, readonly) NSString *typeEncoding; ///< 变量的编码类型
@property (nonatomic, assign, readonly) YYEncodingType type;    ///< 转化成YYType类型

/**
 通过一个ivar 将YYClassIvarInfo属性描述填充
 */
- (instancetype)initWithIvar:(Ivar)ivar;
@end


/**
 增加对方法的描述信息
 */
@interface YYClassMethodInfo : NSObject
@property (nonatomic, assign, readonly) Method method;                  ///< method
@property (nonatomic, strong, readonly) NSString *name;                 ///< 方法名
@property (nonatomic, assign, readonly) SEL sel;                        ///< sel:即C字符串
@property (nonatomic, assign, readonly) IMP imp;                        ///< SEL对应的IMP
@property (nonatomic, strong, readonly) NSString *typeEncoding;         ///< 方法的编码
@property (nonatomic, strong, readonly) NSString *returnTypeEncoding;   ///< 返回值的类型
@property (nullable, nonatomic, strong, readonly) NSArray<NSString *> *argumentTypeEncodings; ///< 方法参数的类型，用数组来装

/**
 通过传入一个Method对Method进行填充描述信息
 */
- (instancetype)initWithMethod:(Method)method;
@end


/**
 属性的描述信息.
 */
@interface YYClassPropertyInfo : NSObject
@property (nonatomic, assign, readonly) objc_property_t property; ///< property
@property (nonatomic, strong, readonly) NSString *name;           ///< 属性名
@property (nonatomic, assign, readonly) YYEncodingType type;      ///< 属性类型
@property (nonatomic, strong, readonly) NSString *typeEncoding;   ///< 属性编码
@property (nonatomic, strong, readonly) NSString *ivarName;       ///< 属性对应的ivar名字
@property (nullable, nonatomic, assign, readonly) Class cls;      ///< 属性的Class
@property (nonatomic, assign, readonly) SEL getter;               ///< getter (nonnull)
@property (nonatomic, assign, readonly) SEL setter;               ///< setter (nonnull)

/**
 根据property取得填充对应的描述
 */
- (instancetype)initWithProperty:(objc_property_t)property;
@end


/**
 class的描述信息.对一个class进行封装
 */
@interface YYClassInfo : NSObject
@property (nonatomic, assign, readonly) Class cls; ///< class
@property (nullable, nonatomic, assign, readonly) Class superCls; ///< super class
@property (nullable, nonatomic, assign, readonly) Class metaCls;  ///< 元类
@property (nonatomic, readonly) BOOL isMeta; ///< 是否为元类
@property (nonatomic, strong, readonly) NSString *name; ///< 类名
@property (nullable, nonatomic, strong, readonly) YYClassInfo *superClassInfo; ///< 父类的描述信息
@property (nullable, nonatomic, strong, readonly) NSDictionary<NSString *, YYClassIvarInfo *> *ivarInfos; ///< ivars 用字典来装，与YYClassIvarInfo一一对应
@property (nullable, nonatomic, strong, readonly) NSDictionary<NSString *, YYClassMethodInfo *> *methodInfos; ///< methods用字典来装，与YYClassMethodInfo一一对应
@property (nullable, nonatomic, strong, readonly) NSDictionary<NSString *, YYClassPropertyInfo *> *propertyInfos; ///< properties用字典来装，与YYClassPropertyInfo一一对应

/**
 当class中有内容被修改了，如增加了一个新的方法，需要调用这个方法进行刷新class的信息，这个方法调用后会将needUpdate方法中的返回值设置为YES，从而需要调用classInfoWithClass或者classInfoWithClassName来获取刷新class的信息
 */
- (void)setNeedUpdate;

/**
 classInfo是否需要刷新，当返回值为YES的时候，需要停止使用改Instance
 */
- (BOOL)needUpdate;

/**
 获得cls的详细信息，并刷新
 */
+ (nullable instancetype)classInfoWithClass:(Class)cls;

/**
  获得cls的详细信息，并刷新
 */
+ (nullable instancetype)classInfoWithClassName:(NSString *)className;

@end

NS_ASSUME_NONNULL_END
