//
//  main.m
//  studyAlloc
//
//  Created by 郑钦洪 on 16/6/27.
//  Copyright © 2016年 iKingsly. All rights reserved.
//

#import <Foundation/Foundation.h>
struct Person {
    int pid;//四个字节
};

struct Man {
    int mid;//四个字节
    int sex;//四个字节
};

static struct Man* instance() {
    
    // 分配总长度的内存空间
    size_t p_s = sizeof(struct Person);
    size_t m_s = sizeof(struct Man);
    size_t size = p_s + m_s;
    printf("p_s = %ld, m_s = %ld, size = %ld\n", p_s, m_s, size);
    
    // 分配内存空间
    void *news = calloc(1, size);
    printf("整个长度内存空间起始地址: %p\n", news);
    
    // 将头部空间先转换成Person类型
    struct Person *p = (struct Person *)news;
    printf("Person地址: %p\n", p);
    p->pid = 1111;
    
    // 再将后面的空间转换成Man类型
    struct Man *m = (struct Man *)(p + 1);
    printf("Man地址: %p\n", m);
    m->mid = 2222;
    m->sex = 1;
    
    // 先对哪一种类型转换，就决定了谁先谁后存放.
    
    return m;
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        struct Man *m = instance();
        printf("mid = %d, sex = %d\n", m->mid, m->sex);
    }
    return 0;
}
