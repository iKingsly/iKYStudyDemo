/*
 * Copyright (c) 1999-2007 Apple Inc.  All Rights Reserved.
 * 
 * @APPLE_LICENSE_HEADER_START@
 * 
 * This file contains Original Code and/or Modifications of Original Code
 * as defined in and that are subject to the Apple Public Source License
 * Version 2.0 (the 'License'). You may not use this file except in
 * compliance with the License. Please obtain a copy of the License at
 * http://www.opensource.apple.com/apsl/ and read it before using this
 * file.
 * 
 * The Original Code and all software distributed under the License are
 * distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER
 * EXPRESS OR IMPLIED, AND APPLE HEREBY DISCLAIMS ALL SUCH WARRANTIES,
 * INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT.
 * Please see the License for the specific language governing rights and
 * limitations under the License.
 * 
 * @APPLE_LICENSE_HEADER_END@
 */

/***********************************************************************
* objc-initialize.m
* +initialize support
**********************************************************************/

/***********************************************************************
 * Thread-safety during class initialization (GrP 2001-9-24)
 *
 * Initial state: CLS_INITIALIZING and CLS_INITIALIZED both clear. 
 * During initialization: CLS_INITIALIZING is set
 * After initialization: CLS_INITIALIZING clear and CLS_INITIALIZED set.
 * CLS_INITIALIZING and CLS_INITIALIZED are never set at the same time.
 * CLS_INITIALIZED is never cleared once set.
 *
 * Only one thread is allowed to actually initialize a class and send 
 * +initialize. Enforced by allowing only one thread to set CLS_INITIALIZING.
 *
 * Additionally, threads trying to send messages to a class must wait for 
 * +initialize to finish. During initialization of a class, that class's 
 * method cache is kept empty. objc_msgSend will revert to 
 * class_lookupMethodAndLoadCache, which checks CLS_INITIALIZED before 
 * messaging. If CLS_INITIALIZED is clear but CLS_INITIALIZING is set, 
 * the thread must block, unless it is the thread that started 
 * initializing the class in the first place. 
 *
 * Each thread keeps a list of classes it's initializing. 
 * The global classInitLock is used to synchronize changes to CLS_INITIALIZED 
 * and CLS_INITIALIZING: the transition to CLS_INITIALIZING must be 
 * an atomic test-and-set with respect to itself and the transition 
 * to CLS_INITIALIZED.
 * The global classInitWaitCond is used to block threads waiting for an 
 * initialization to complete. The classInitLock synchronizes
 * condition checking and the condition variable.
 **********************************************************************/

/***********************************************************************
 *  +initialize deadlock case when a class is marked initializing while 
 *  its superclass is initialized. Solved by completely initializing 
 *  superclasses before beginning to initialize a class.
 *
 *  OmniWeb class hierarchy:
 *                 OBObject 
 *                     |    ` OBPostLoader
 *                 OFObject
 *                 /     \
 *      OWAddressEntry  OWController
 *                        | 
 *                      OWConsoleController
 *
 *  Thread 1 (evil testing thread):
 *    initialize OWAddressEntry
 *    super init OFObject
 *    super init OBObject		     
 *    [OBObject initialize] runs OBPostLoader, which inits lots of classes...
 *    initialize OWConsoleController
 *    super init OWController - wait for Thread 2 to finish OWController init
 *
 *  Thread 2 (normal OmniWeb thread):
 *    initialize OWController
 *    super init OFObject - wait for Thread 1 to finish OFObject init
 *
 *  deadlock!
 *
 *  Solution: fully initialize super classes before beginning to initialize 
 *  a subclass. Then the initializing+initialized part of the class hierarchy
 *  will be a contiguous subtree starting at the root, so other threads 
 *  can't jump into the middle between two initializing classes, and we won't 
 *  get stuck while a superclass waits for its subclass which waits for the 
 *  superclass.
 **********************************************************************/

#include "objc-private.h"
#include "message.h"
#include "objc-initialize.h"

/* classInitLock protects CLS_INITIALIZED and CLS_INITIALIZING, and 
 * is signalled when any class is done initializing. 
 * Threads that are waiting for a class to finish initializing wait on this. */
static monitor_t classInitLock;


/***********************************************************************
* struct _objc_initializing_classes
* Per-thread list of classes currently being initialized by that thread. 
* During initialization, that thread is allowed to send messages to that 
* class, but other threads have to wait.
* The list is a simple array of metaclasses (the metaclass stores 
* the initialization state). 
**********************************************************************/
typedef struct _objc_initializing_classes {
    int classesAllocated;
    Class *metaclasses;
} _objc_initializing_classes;


/***********************************************************************
* _fetchInitializingClassList
* Return the list of classes being initialized by this thread.
* If create == YES, create the list when no classes are being initialized by this thread.
* If create == NO, return nil when no classes are being initialized by this thread.
**********************************************************************/
static _objc_initializing_classes *_fetchInitializingClassList(BOOL create)
{
    _objc_pthread_data *data;
    _objc_initializing_classes *list;
    Class *classes;

    data = _objc_fetch_pthread_data(create);
    if (data == nil) return nil;

    list = data->initializingClasses;
    if (list == nil) {
        if (!create) {
            return nil;
        } else {
            list = (_objc_initializing_classes *)
                calloc(1, sizeof(_objc_initializing_classes));
            data->initializingClasses = list;
        }
    }

    classes = list->metaclasses;
    if (classes == nil) {
        // If _objc_initializing_classes exists, allocate metaclass array, 
        // even if create == NO.
        // Allow 4 simultaneous class inits on this thread before realloc.
        list->classesAllocated = 4;
        classes = (Class *)
            calloc(list->classesAllocated, sizeof(Class));
        list->metaclasses = classes;
    }
    return list;
}


/***********************************************************************
* _destroyInitializingClassList
* Deallocate memory used by the given initialization list. 
* Any part of the list may be nil.
* Called from _objc_pthread_destroyspecific().
**********************************************************************/

void _destroyInitializingClassList(struct _objc_initializing_classes *list)
{
    if (list != nil) {
        if (list->metaclasses != nil) {
            free(list->metaclasses);
        }
        free(list);
    }
}


/***********************************************************************
* _thisThreadIsInitializingClass
* Return TRUE if this thread is currently initializing the given class.
**********************************************************************/
static BOOL _thisThreadIsInitializingClass(Class cls)
{
    int i;

    _objc_initializing_classes *list = _fetchInitializingClassList(NO);
    if (list) {
        cls = cls->getMeta();
        for (i = 0; i < list->classesAllocated; i++) {
            if (cls == list->metaclasses[i]) return YES;
        }
    }

    // no list or not found in list
    return NO;
}


/***********************************************************************
 记录当前这个线程正在初始化给定的class。这个线程允许对这个class 发送消息
 但其他线程必须等待这个线程完成之后才能对它发送消息
**********************************************************************/
static void _setThisThreadIsInitializingClass(Class cls)
{
    int i;
    _objc_initializing_classes *list = _fetchInitializingClassList(YES);
    cls = cls->getMeta();
  
    // paranoia: explicitly disallow duplicates
    for (i = 0; i < list->classesAllocated; i++) {
        if (cls == list->metaclasses[i]) {
            _objc_fatal("thread is already initializing this class!");
            return; // already the initializer
        }
    }
  
    for (i = 0; i < list->classesAllocated; i++) {
        if (! list->metaclasses[i]) {
            list->metaclasses[i] = cls;
            return;
        }
    }

    // class list is full - reallocate
    list->classesAllocated = list->classesAllocated * 2 + 1;
    list->metaclasses = (Class *) 
        realloc(list->metaclasses,
                          list->classesAllocated * sizeof(Class));
    // zero out the new entries
    list->metaclasses[i++] = cls;
    for ( ; i < list->classesAllocated; i++) {
        list->metaclasses[i] = nil;
    }
}


/***********************************************************************
* _setThisThreadIsNotInitializingClass
* Record that this thread is no longer initializing the given class. 
**********************************************************************/
static void _setThisThreadIsNotInitializingClass(Class cls)
{
    int i;

    _objc_initializing_classes *list = _fetchInitializingClassList(NO);
    if (list) {
        cls = cls->getMeta();
        for (i = 0; i < list->classesAllocated; i++) {
            if (cls == list->metaclasses[i]) {
                list->metaclasses[i] = nil;
                return;
            }
        }
    }

    // no list or not found in list
    _objc_fatal("thread is not initializing this class!");  
}


typedef struct PendingInitialize {
    Class subclass;
    struct PendingInitialize *next;
} PendingInitialize;

static NXMapTable *pendingInitializeMap;

/***********************************************************************
 cls和其父类 完成了初始化操作
 标记cls和其父类完成了初始化操作
**********************************************************************/
static void _finishInitializing(Class cls, Class supercls)
{
    PendingInitialize *pending;

    classInitLock.assertLocked();
    assert(!supercls  ||  supercls->isInitialized());

    if (PrintInitializing) {
        _objc_inform("INITIALIZE: %s is fully +initialized",
                     cls->nameForLogging());
    }

    // propagate finalization affinity.
    if (UseGC && supercls && supercls->shouldFinalizeOnMainThread()) {
        cls->setShouldFinalizeOnMainThread();
    }

    // 标记完成了 初始化操作
    cls->setInitialized();
    // 通知其他等待的线程
    classInitLock.notifyAll();
    // 标记线程没有在初始化class操作
    _setThisThreadIsNotInitializingClass(cls);

    // 标记在等待这个class的子类
    if (!pendingInitializeMap) return;
    pending = (PendingInitialize *)NXMapGet(pendingInitializeMap, cls);
    // 没有在等待的话 就退出
    if (!pending) return;

    // 从 等待初始化的列表中移除class 中移除
    NXMapRemove(pendingInitializeMap, cls);

    // 删除后如果MapTable的count为0 则释放MapTable
    if (NXCountMapTable(pendingInitializeMap) == 0) {
        NXFreeMapTable(pendingInitializeMap);
        pendingInitializeMap = nil;
    }

    // 有在等待的 在链表中进行循环通知
    while (pending) {
        PendingInitialize *next = pending->next;
        // 通知子类完成了初始化
        if (pending->subclass) _finishInitializing(pending->subclass, cls);
        free(pending);
        pending = next;
    }
}


/***********************************************************************
* _finishInitializingAfter
* cls has completed its +initialize method, but its superclass has not.
* Wait until supercls finishes before marking cls as initialized.
**********************************************************************/
static void _finishInitializingAfter(Class cls, Class supercls)
{
    PendingInitialize *pending;

    classInitLock.assertLocked();

    if (PrintInitializing) {
        _objc_inform("INITIALIZE: %s waiting for superclass +[%s initialize]",
                     cls->nameForLogging(), supercls->nameForLogging());
    }

    // 没有的话进行初始化
    if (!pendingInitializeMap) {
        pendingInitializeMap = 
            NXCreateMapTable(NXPtrValueMapPrototype, 10);
        // fixme pre-size this table for CF/NSObject +initialize
    }

    // 创建一个节点，在父类完成初始化后再被通知
    pending = (PendingInitialize *)malloc(sizeof(*pending));
    pending->subclass = cls;
    pending->next = (PendingInitialize *)
        NXMapGet(pendingInitializeMap, supercls);
    NXMapInsert(pendingInitializeMap, supercls, pending);
}


/***********************************************************************
* class_initialize.  Send the '+initialize' message on demand to any
* uninitialized class. Force initialization of superclasses first.
**********************************************************************/
void _class_initialize(Class cls)
{
    assert(!cls->isMetaClass());

    Class supercls;
    BOOL reallyInitialize = NO;

    // 确保父类在子类之前调用 initialize
    supercls = cls->superclass;
    if (supercls  &&  !supercls->isInitialized()) {
        _class_initialize(supercls);
    }

    // 原子设定 cls->setInitializing()
    {
        monitor_locker_t lock(classInitLock);
        if (!cls->isInitialized() && !cls->isInitializing()) {
            cls->setInitializing();
            reallyInitialize = YES;
        }
    }
    
    if (reallyInitialize) {
        // We successfully set the CLS_INITIALIZING bit. Initialize the class.
        
        // Record that we're initializing this class so we can message it.
        // 记录当前发送消息的线程
        _setThisThreadIsInitializingClass(cls);

        // 开始发送 initialize消息
        // 如果这个类没有重写 initialize 方法，会调用其父类的initialize方法
        if (PrintInitializing) {
            _objc_inform("INITIALIZE: calling +[%s initialize]",
                         cls->nameForLogging());
        }

        // 发送initialize消息
        ((void(*)(Class, SEL))objc_msgSend)(cls, SEL_initialize);

        // 结束发送消息
        if (PrintInitializing) {
            _objc_inform("INITIALIZE: finished +[%s initialize]",
                         cls->nameForLogging());
        }        

        // 完成初始化
        // 如果父类也完成了初始化操作，更新info 信息 通知等待的线程可以继续进行
        // 如果没有 就加进父类的MapTable中 在父类完成初始化后被通知
        monitor_locker_t lock(classInitLock);
        if (!supercls  ||  supercls->isInitialized()) {
            _finishInitializing(cls, supercls);
        } else {
            _finishInitializingAfter(cls, supercls);
        }
        return;
    }
    // 如果正在初始化
    else if (cls->isInitializing()) {
        // 因为class正在初始化中，我们不能进行设置
        // 如果是当前线程设置的，就继续执行
        // 如果是其它现场设置的，就进行阻塞，知道其它线程初始化class完成
        // 这里操作是安全的，因为我们在等待中又进行了判断是否为INItialized
        if (_thisThreadIsInitializingClass(cls)) {
            return;
        } else {
            monitor_locker_t lock(classInitLock);
            while (!cls->isInitialized()) {
                classInitLock.wait();
            }
            return;
        }
    }
    
    else if (cls->isInitialized()) {
        // 设置失败，因为有其它线程对其做了初始化，所以只需要直接返回就行
        return;
    }
    
    else {
        // We shouldn't be here. 
        _objc_fatal("thread-safe class init in objc runtime is buggy!");
    }
}
