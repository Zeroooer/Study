//
//  main.m
//  phread_mutex_Biting
//
//  Created by Hisen on 27/03/2018.
//  Copyright © 2018 Hisen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <pthread.h>
#import "NSThread+SequenceNumber.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        /*
         * pthread_mutex 是 C 语言下多线程加互斥锁的方式
         * 1.静态加锁 pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;
         * 2.动态加锁 pthread_mutex_t mutex = pthread_mutex_init()
         */
//        static pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;
        
        static pthread_mutex_t lock;
        /*
         * 初始化pthread_mutex_t
         * @param1: pthread_mutex_t *
         * @param2: 锁的类型
         * PTHREAD_MUTEX_NORMAL      缺省类型，也就是普通锁。当一个线程加锁以后，其余请求锁的线程将形成一个等待队列，并在解锁后先进先出原则获得锁。
         * PTHREAD_MUTEX_ERRORCHECK  检错锁，如果同一个线程请求同一个锁，则返回 EDEADLK，否则与普通锁类型动作相同。这样就保证当不允许多次加锁时不会出现嵌套情况下的死锁。
         * PTHREAD_MUTEX_RECURSIVE   递归锁，允许同一个线程对同一个锁成功获得多次，并通过多次 unlock 解锁。
         * PTHREAD_MUTEX_DEFAULT     适应锁，动作最简单的锁类型，仅等待解锁后重新竞争，没有等待队列。
         */
        pthread_mutexattr_t attr;
        pthread_mutexattr_init(&attr);
        pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_ERRORCHECK);
        pthread_mutex_init(&lock, &attr);
        pthread_mutexattr_destroy(&attr);
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            sleep(1);
//            pthread_mutex_lock(&lock);
            /*
             * pthread_mutex_trylock
             * return 0; 加锁成功
             * 返回其他表示没有加锁成功
             */
            int status = pthread_mutex_trylock(&lock);
            if (status == 0) {
                NSLog(@"线程%ld尝试加锁成功", (long)[[NSThread currentThread] sequenceNumber]);
                pthread_mutex_unlock(&lock);
                NSLog(@"线程%ld解锁成功", (long)[[NSThread currentThread] sequenceNumber]);
            } else {
                NSLog(@"线程%ld尝试加锁失败", (long)[[NSThread currentThread] sequenceNumber]);
            }
        });
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            pthread_mutex_lock(&lock);
            NSLog(@"线程%ld加锁成功", (long)[[NSThread currentThread] sequenceNumber]);
            // sleep时间越接近1，上面的线程尝试获取锁成功的几率越大
            sleep(1.1);
            pthread_mutex_unlock(&lock);
            NSLog(@"线程%ld解锁成功", (long)[[NSThread currentThread] sequenceNumber]);
        });
        
        [[NSRunLoop currentRunLoop] run];
    }
    return 0;
}
