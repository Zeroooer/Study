//
//  main.m
//  NSLockBiting
//
//  Created by Hisen on 27/03/2018.
//  Copyright © 2018 Hisen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSThread+SequenceNumber.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        /*
         * NSLock 内部封装了一个pthread_mutex_t，属性为 PTHREAD_MUTEX_ERRORCHECK
         * 比pthread_mutex略慢，因为需要经过方法调用，但是由于方法缓存，多次调用性能损耗也不会太大
         */
        NSLock *lock = [NSLock new];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            sleep(1);
            
            /*
             * lock
             * 加锁失败线程会有两个阶段
             * 1.由于从挂起到唤醒有一定开销，所以在挂起前会空转一段时间，这期间会不断循环check锁的状态,如果获取到马上进入
             * 2.如果还是没有获取到锁就会挂起线程，进入阻塞状态，释放CPU
             * 等锁可用，系统会激活这个线程，重新放入队列等待CPU调度
             */
//            [lock lock];
//            NSLog(@"线程%ld加锁成功", (long)[[NSThread currentThread] sequenceNumber]);
//            [lock unlock];
//            NSLog(@"线程%ld解锁成功", (long)[[NSThread currentThread] sequenceNumber]);
            
            /*
             * tryLock
             * 返回YES：尝试加锁成功
             * 返回NO：尝试加锁失败，不会阻塞线程
             * 如果尝试加锁失败，当锁可用的时候线程不会被激活
             */
//            if ([lock tryLock]) {
//                NSLog(@"线程%ld尝试加锁成功", (long)[[NSThread currentThread] sequenceNumber]);
//                [lock unlock];
//                NSLog(@"线程%ld解锁成功", (long)[[NSThread currentThread] sequenceNumber]);
//            } else {
//                NSLog(@"线程%ld尝试加锁失败", (long)[[NSThread currentThread] sequenceNumber]);
//            }
            
            /*
             * lockBeforeDate
             * 返回YES：指定时间内尝试加锁成功
             * 返回NO：指定时间内尝试加锁失败，不会阻塞线程
             * 如果尝试加锁失败，当锁可用的时候线程不会被激活
             */
            if ([lock lockBeforeDate:[NSDate dateWithTimeIntervalSinceNow:1]]) {
                NSLog(@"没有超时，线程%ld尝试加锁成功", (long)[[NSThread currentThread] sequenceNumber]);
                [lock unlock];
                NSLog(@"线程%ld解锁成功", (long)[[NSThread currentThread] sequenceNumber]);
            } else {
                NSLog(@"超时，线程%ld尝试加锁失败", (long)[[NSThread currentThread] sequenceNumber]);
            }

        });
        
        // 由于上面的线程sleep(1),所以这个线程首先获取到锁
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [lock lock];
            NSLog(@"线程%ld加锁成功", (long)[[NSThread currentThread] sequenceNumber]);
            // 这里sleep的时间足够长，上面的线程才会被挂起
            sleep(5);
            [lock unlock];
            NSLog(@"线程%ld解锁成功", (long)[[NSThread currentThread] sequenceNumber]);
        });
        
        [[NSRunLoop mainRunLoop] run];
    }
    return 0;
}
