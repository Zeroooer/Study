//
//  main.m
//  NSRecursiveLockBiting
//
//  Created by Hisen on 27/03/2018.
//  Copyright © 2018 Hisen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSThread+SequenceNumber.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        /*
         * NSRecursiveLock 内部也是封装了一个pthread_mutex_t, 属性是PHREAD_MUTEX_RECURSIVE
         * 可以在一个线程中重复加锁(单线程任务顺序执行，不会出现资源竞争)
         */
        
        NSRecursiveLock *recursiveLock = [NSRecursiveLock new];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            static void (^RecursiveBlock) (int);
            __block int recursiveCount = 0;
            RecursiveBlock = ^(int value) {
                // 同一个线程里重复尝试加锁总是能成功
                if ([recursiveLock tryLock]) {
                    NSLog(@"递归第%d层-线程%ld尝试加锁成功", recursiveCount, (long)[[NSThread currentThread] sequenceNumber]);
                } else {
                    NSLog(@"递归第%d层-线程%ld尝试加锁失败", recursiveCount, (long)[[NSThread currentThread] sequenceNumber]);
                }
                
                if (value > 0) {
                    NSLog(@"递归第%d层-线程%ld - value:%d", recursiveCount, (long)[[NSThread currentThread] sequenceNumber], value);
                    recursiveCount++;
                    RecursiveBlock(value - 1);
                    recursiveCount--;
                }
                [recursiveLock unlock];
                NSLog(@"递归第%d层-线程%ld解锁成功", recursiveCount, (long)[[NSThread currentThread] sequenceNumber]);
            };
            RecursiveBlock(2);
        });
        
        [[NSRunLoop currentRunLoop] run];
    }
    return 0;
}
