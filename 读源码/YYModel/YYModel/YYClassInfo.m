//
//  YYClassInfo.m
//  YYModel <https://github.com/ibireme/YYModel>
//
//  Created by ibireme on 15/5/9.
//  Copyright (c) 2015 ibireme.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import "YYClassInfo.h"
#import <objc/runtime.h>
// 获得Type的 encode 返回枚举的YYEncodingType类型
YYEncodingType YYEncodingGetType(const char *typeEncoding) {
    // 转换const char 为 char
    char *type = (char *)typeEncoding;
    // 如果获取不到type或者type长度<1 则返回未知类型
    if (!type) return YYEncodingTypeUnknown;
    size_t len = strlen(type);
    if (len == 0) return YYEncodingTypeUnknown;
    
    // 用qualifier来确定当前type的encode
    YYEncodingType qualifier = 0;
    bool prefix = true;
    // 判断method的类型，如果有就type指针＋1，判断下一个字符，如果没有则跳出循环
    while (prefix) {
        switch (*type) {
            case 'r': {
                qualifier |= YYEncodingTypeQualifierConst;
                type++;
            } break;
            case 'n': {
                qualifier |= YYEncodingTypeQualifierIn;
                type++;
            } break;
            case 'N': {
                qualifier |= YYEncodingTypeQualifierInout;
                type++;
            } break;
            case 'o': {
                qualifier |= YYEncodingTypeQualifierOut;
                type++;
            } break;
            case 'O': {
                qualifier |= YYEncodingTypeQualifierBycopy;
                type++;
            } break;
            case 'R': {
                qualifier |= YYEncodingTypeQualifierByref;
                type++;
            } break;
            case 'V': {
                qualifier |= YYEncodingTypeQualifierOneway;
                type++;
            } break;
            default: { prefix = false; } break;
        }
    }

    // 获得变化后的type长度
    len = strlen(type);
    // 再一次判断是否为未知类型
    if (len == 0) return YYEncodingTypeUnknown | qualifier;
    // 判断变量的类型
    switch (*type) {
        case 'v': return YYEncodingTypeVoid | qualifier;
        case 'B': return YYEncodingTypeBool | qualifier;
        case 'c': return YYEncodingTypeInt8 | qualifier;
        case 'C': return YYEncodingTypeUInt8 | qualifier;
        case 's': return YYEncodingTypeInt16 | qualifier;
        case 'S': return YYEncodingTypeUInt16 | qualifier;
        case 'i': return YYEncodingTypeInt32 | qualifier;
        case 'I': return YYEncodingTypeUInt32 | qualifier;
        case 'l': return YYEncodingTypeInt32 | qualifier;
        case 'L': return YYEncodingTypeUInt32 | qualifier;
        case 'q': return YYEncodingTypeInt64 | qualifier;
        case 'Q': return YYEncodingTypeUInt64 | qualifier;
        case 'f': return YYEncodingTypeFloat | qualifier;
        case 'd': return YYEncodingTypeDouble | qualifier;
        case 'D': return YYEncodingTypeLongDouble | qualifier;
        case '#': return YYEncodingTypeClass | qualifier;
        case ':': return YYEncodingTypeSEL | qualifier;
        case '*': return YYEncodingTypeCString | qualifier;
        case '^': return YYEncodingTypePointer | qualifier;
        case '[': return YYEncodingTypeCArray | qualifier;
        case '(': return YYEncodingTypeUnion | qualifier;
        case '{': return YYEncodingTypeStruct | qualifier;
        case '@': {
            if (len == 2 && *(type + 1) == '?') // block类型
                return YYEncodingTypeBlock | qualifier;
            else // 返回自定义类型或者NSObject类型
                return YYEncodingTypeObject | qualifier;
        }
        default: return YYEncodingTypeUnknown | qualifier;
    }
}

@implementation YYClassIvarInfo

- (instancetype)initWithIvar:(Ivar)ivar {
    // 判断是否为一个合法的ivar
    if (!ivar) return nil;
    self = [super init];
    _ivar = ivar;
    // 获得ivar的名称
    const char *name = ivar_getName(ivar);
    if (name) { // 转化const char 属性为NSString
        _name = [NSString stringWithUTF8String:name];
    }
    // 取得相对偏移量，这样做可以增加命中率
    _offset = ivar_getOffset(ivar);
    const char *typeEncoding = ivar_getTypeEncoding(ivar);
    if (typeEncoding) { // 获得编码的同时 也转为YYType
        _typeEncoding = [NSString stringWithUTF8String:typeEncoding];
        _type = YYEncodingGetType(typeEncoding);
    }
    return self;
}

@end

@implementation YYClassMethodInfo

- (instancetype)initWithMethod:(Method)method {
    // 判断method的合法性
    if (!method) return nil;
    self = [super init];
    _method = method;
    // 取得对应的sel
    _sel = method_getName(method);
    // 取得对应的IMP 即方法的内存地址
    _imp = method_getImplementation(method);
    // 取得sel的名字
    const char *name = sel_getName(_sel);
    if (name) { // 转换成NSString
        _name = [NSString stringWithUTF8String:name];
    }
    // 取得Method对应的类型
    const char *typeEncoding = method_getTypeEncoding(method);
    if (typeEncoding) {
        _typeEncoding = [NSString stringWithUTF8String:typeEncoding];
    }
    // 取得返回内容的类型
    char *returnType = method_copyReturnType(method);
    if (returnType) {
        _returnTypeEncoding = [NSString stringWithUTF8String:returnType];
        free(returnType);
    }
    // 循环取得一个方法的参数，并且取得每一个参数的类型，加入到数组中
    unsigned int argumentCount = method_getNumberOfArguments(method);
    if (argumentCount > 0) {
        NSMutableArray *argumentTypes = [NSMutableArray new];
        for (unsigned int i = 0; i < argumentCount; i++) {
            char *argumentType = method_copyArgumentType(method, i);
            NSString *type = argumentType ? [NSString stringWithUTF8String:argumentType] : nil;
            [argumentTypes addObject:type ? type : @""];
            if (argumentType) free(argumentType);
        }
        _argumentTypeEncodings = argumentTypes;
    }
    return self;
}

@end

@implementation YYClassPropertyInfo

- (instancetype)initWithProperty:(objc_property_t)property {
    // 判断property的合法性
    if (!property) return nil;
    self = [self init];
    _property = property;
    // 取得property名
    const char *name = property_getName(property);
    if (name) {
        _name = [NSString stringWithUTF8String:name];
    }
    
    YYEncodingType type = 0;
    unsigned int attrCount;
    // 取得属性的附加属性，就是关于原子性，内存管理等
    objc_property_attribute_t *attrs = property_copyAttributeList(property, &attrCount);
    for (unsigned int i = 0; i < attrCount; i++) {
        switch (attrs[i].name[0]) {
            case 'T': { // 第一个是属性的类型
                if (attrs[i].value) {
                    _typeEncoding = [NSString stringWithUTF8String:attrs[i].value];
                    type = YYEncodingGetType(attrs[i].value);
                    if ((type & YYEncodingTypeMask) == YYEncodingTypeObject) {
                        size_t len = strlen(attrs[i].value);
                        if (len > 3) {
                            char name[len - 2];
                            name[len - 3] = '\0';
                            memcpy(name, attrs[i].value + 2, len - 3);
                            _cls = objc_getClass(name); // 取得对应class类
                        }
                    }
                }
            } break;
            case 'V': { // 变量ivar名
                if (attrs[i].value) {
                    _ivarName = [NSString stringWithUTF8String:attrs[i].value];
                }
            } break;
            case 'R': {
                type |= YYEncodingTypePropertyReadonly;
            } break;
            case 'C': {
                type |= YYEncodingTypePropertyCopy;
            } break;
            case '&': {
                type |= YYEncodingTypePropertyRetain;
            } break;
            case 'N': {
                type |= YYEncodingTypePropertyNonatomic;
            } break;
            case 'D': {
                type |= YYEncodingTypePropertyDynamic;
            } break;
            case 'W': {
                type |= YYEncodingTypePropertyWeak;
            } break;
            case 'G': { // get 方法
                type |= YYEncodingTypePropertyCustomGetter;
                if (attrs[i].value) {
                    _getter = NSSelectorFromString([NSString stringWithUTF8String:attrs[i].value]);
                }
            } break;
            case 'S': { // set方法
                type |= YYEncodingTypePropertyCustomSetter;
                if (attrs[i].value) {
                    _setter = NSSelectorFromString([NSString stringWithUTF8String:attrs[i].value]);
                }
            }
            default: break;
        }
    }
    if (attrs) { // 需要释放指针
        free(attrs);
        attrs = NULL;
    }
    
    _type = type;
    if (_name.length) {
        if (!_getter) { // 如果没有指定get方法和set方法的名字，则按默认情况自动拼接
            _getter = NSSelectorFromString(_name);
        }
        if (!_setter) {
            _setter = NSSelectorFromString([NSString stringWithFormat:@"set%@%@:", [_name substringToIndex:1].uppercaseString, [_name substringFromIndex:1]]);
        }
    }
    return self;
}

@end

@implementation YYClassInfo {
    // 是否需要刷新
    BOOL _needUpdate;
}

- (instancetype)initWithClass:(Class)cls {
    // 判断cls的合法性
    if (!cls) return nil;
    self = [super init];
    // cls
    _cls = cls;
    // superClass
    _superCls = class_getSuperclass(cls);
    // 判断是否为meta
    _isMeta = class_isMetaClass(cls);
    if (!_isMeta) {
        _metaCls = objc_getMetaClass(class_getName(cls));
    }
    // 获得类名
    _name = NSStringFromClass(cls);
    [self _update];
    
    // 获得_superInfo
    _superClassInfo = [self.class classInfoWithClass:_superCls];
    return self;
}

- (void)_update {
    // 刷新ivar，method，property信息
    _ivarInfos = nil;
    _methodInfos = nil;
    _propertyInfos = nil;
    
    Class cls = self.cls;
    
    // 取得类中的methods
    unsigned int methodCount = 0;
    Method *methods = class_copyMethodList(cls, &methodCount);
    if (methods) {
        // 创建dictionary来进行缓存method信息
        NSMutableDictionary *methodInfos = [NSMutableDictionary new];
        _methodInfos = methodInfos;
        // 遍历methods
        for (unsigned int i = 0; i < methodCount; i++) {
            YYClassMethodInfo *info = [[YYClassMethodInfo alloc] initWithMethod:methods[i]];
            // 用方法名做key info做value
            if (info.name) methodInfos[info.name] = info;
        }
        free(methods);
    }
    
    // 获取类中的property信息
    unsigned int propertyCount = 0;
    objc_property_t *properties = class_copyPropertyList(cls, &propertyCount);
    if (properties) {
        // 创建dictionary来进行缓存property信息
        NSMutableDictionary *propertyInfos = [NSMutableDictionary new];
        _propertyInfos = propertyInfos;
        // 遍历property
        for (unsigned int i = 0; i < propertyCount; i++) {
            YYClassPropertyInfo *info = [[YYClassPropertyInfo alloc] initWithProperty:properties[i]];
            // 用属性名做key info做value
            if (info.name) propertyInfos[info.name] = info;
        }
        free(properties);
    }
    
    // 取得类中的变量信息
    unsigned int ivarCount = 0;
    Ivar *ivars = class_copyIvarList(cls, &ivarCount);
    if (ivars) {
        // 创建dictionary来进行缓存ivar信息
        NSMutableDictionary *ivarInfos = [NSMutableDictionary new];
        _ivarInfos = ivarInfos;
        // 遍历ivar
        for (unsigned int i = 0; i < ivarCount; i++) {
            YYClassIvarInfo *info = [[YYClassIvarInfo alloc] initWithIvar:ivars[i]];
            // 用变量名做key info做value
            if (info.name) ivarInfos[info.name] = info;
        }
        free(ivars);
    }
    
    // 如果当中有不存在的内容，把缓存dict置为空
    if (!_ivarInfos) _ivarInfos = @{};
    if (!_methodInfos) _methodInfos = @{};
    if (!_propertyInfos) _propertyInfos = @{};
    
    // 刷新结束
    _needUpdate = NO;
}

// 需要刷新信息
- (void)setNeedUpdate {
    _needUpdate = YES;
}

- (BOOL)needUpdate {
    return _needUpdate;
}

// 通过class获取对应class的信息，并且对这些信息进行处理
+ (instancetype)classInfoWithClass:(Class)cls {
    if (!cls) return nil;
    // class 缓存容器
    static CFMutableDictionaryRef classCache;
    // metaclass 缓存容器
    static CFMutableDictionaryRef metaCache;
    static dispatch_once_t onceToken;
    // 为了线程安全 同步信号量
    static dispatch_semaphore_t lock;
    dispatch_once(&onceToken, ^{
        classCache = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        metaCache = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        lock = dispatch_semaphore_create(1);
    });
    dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
    // 是元类还是Class，从结果的容器中进行查找
    YYClassInfo *info = CFDictionaryGetValue(class_isMetaClass(cls) ? metaCache : classCache, (__bridge const void *)(cls));
    // 是否找到info并且需要进行刷新
    if (info && info->_needUpdate) {
        [info _update];
    }
    // 释放信号量
    dispatch_semaphore_signal(lock);
    if (!info) { // info不在缓存容器中
        // 通过initWithClass重新创建一个info
        info = [[YYClassInfo alloc] initWithClass:cls];
        if (info) {
            // 缓存到对应的容器中
            dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
            // 再一次判断是meta还是class
            CFDictionarySetValue(info.isMeta ? metaCache : classCache, (__bridge const void *)(cls), (__bridge const void *)(info));
            dispatch_semaphore_signal(lock);
        }
    }
    return info;
}

// 创建入口，从一个className中获取Class来获取class内容
+ (instancetype)classInfoWithClassName:(NSString *)className {
    // 取得className对应的class
    Class cls = NSClassFromString(className);
    // 调用classInfoWithClass
    return [self classInfoWithClass:cls];
}

@end
