//
//  main.m
//  Queues
//
//  Created by Hisen on 02/04/2018.
//  Copyright © 2018 Hisen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSThread+SequenceNumber.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        /*
         * GCD的内置的队列可以分为两层,一共是15个
         * 第一层
         * 1是主队列 定义在init.c文件，2-3 是内部管理queue用的，定义在queue.c文件
         * 1 com.apple.main-thread 以11号queue作为target queue，提交到main queue的任务最终会提交给它的target queue
         * 2 com.apple.libdispatch-manager
         * 3 com.apple.root.libdispatch-manager
         * 第二层
         * 4-15 是根据6个优先级和是否overcommit(控制线层数是否能超过物理核数)一共有6*2=12个global root queue(早期版本只有4个优先级，8个global root queue)存储在一个数组里，dispatch_get_global_queue(priority, flag)就是根据参数从这个数组中取相应的queue返回,root queue就是最终block提交的地方，通过dispatch_queue_create(label, attr)自定义queue，会通过attr从root queue数组中找出相应的queue作为其target queue来接收其提交的block
         * 4 com.apple.root.maintenance-qos
         * 5 com.apple.root.maintenance-qos.overcommit
         * 6 com.apple.root.background-qos
         * 7 com.apple.root.background-qos.overcommit
         * 8 com.apple.root.utility-qos
         * 9 com.apple.root.utility-qos.overcommit
         * 10 com.apple.root.default-qos
         * 11 com.apple.root.default-qos.overcommit
         * 12 com.apple.root.user-initiated-qos
         * 13 com.apple.root.user-initiated-qos.overcommit
         * 14 com.apple.root.user-interactive-qos
         * 15 com.apple.root.user-interactive-qos.overcommit
         * GCD 在global root queue的下层维护了一个线层池，所有的通过GCD提交的block，不管是main queue，global queue，还是自定义queue，最终都会提交给4-15这12个global root queue，这12个queue直接与线程池交互，主线程也在这个线层池里。
         */
        
        
        /*
         * mainQueue 的target = com.apple.root.default-qos.overcommit
         */
        dispatch_queue_t mainQueue = dispatch_get_main_queue();
//        <OS_dispatch_queue_main: com.apple.main-thread[0x100366100] = { xref = -2147483648, ref = -2147483648, sref = 1, target = com.apple.root.default-qos.overcommit[0x1003678c0], width = 0x1, state = 0x001ffe1000000304, in-flight = 0, thread = 0x307 }>
        
        /*
         * global queue 都是并行队列
         * 通过dispatch_get_global_queue()拿到的queue默认都是非overcommit的，优先级也只暴露了5种QOS_CLASS_[USER_INTERACTIVE, USER_INITIATED, DEFAULT, UTILITY, BACKGROUND]
         * USER_INITIATED <=> PRIORITY_HIGH
         * DEFAULT <=> PRIORITY_DEFAULT
         * UTILITY <=> PRIORITY_LOW
         * BACKGROUND <=> PRIORITY_BACKGROUND
         * identifier = 0x05(QOS_CLASS_MAINTENANCE)，flag = 0x2ull(DISPATCH_QUEUE_OVERCOMMIT)是翻源码找到的
         */
        dispatch_queue_t globalQueue = dispatch_get_global_queue(0x05, 0);
        dispatch_queue_t globalQueueOvercommit = dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0x2ull);
        
        /*
         * 自定义queue，可以指定队列是并行还是串行以及队列的优先级，最终任务都会提交到他们的target(global root queue)中
         * 串行队列的width是1，一次只能执行一个任务，多个串行队列之间是并行的
         * 传入参数是串行的，则target queue是overcommit的(这种设计的原因？我猜是串行的队列不会有新开很多线程的情况)
         * 传入参数是并行的, 则target queue是非overcommit的
         */
        dispatch_queue_attr_t serialAttr = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_UTILITY, -1);
        dispatch_queue_attr_t concurrentAttr = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_CONCURRENT, QOS_CLASS_USER_INITIATED, -1);
        dispatch_queue_t serialQueue = dispatch_queue_create("com.hisen.serialqueue", serialAttr);
        dispatch_queue_t concurrentQueue = dispatch_queue_create("com.hisen.concurrentqueue", concurrentAttr);

        
        NSLog(@"%@", mainQueue);
        NSLog(@"%@", globalQueue);
        NSLog(@"%@", globalQueueOvercommit);
        NSLog(@"%@", serialQueue);
        NSLog(@"%@", concurrentQueue);

        
        [[NSRunLoop currentRunLoop] run];
    }
    return 0;
}
