//
//  main.m
//  DispatchSemaphore
//
//  Created by Hisen on 2017/5/28.
//  Copyright © 2017年 Hisen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSThread+SequenceNumber.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        /*
         NSOperationQueue多线程编程的时候可以使用[queue setMaxConcurrentOperationCount:5]来设置线程池中最多并行的线程数
         GCD中的信号量可以做这个类似的事情
         
         dispatch_semaphore_create 创建一个信号量,设置一个初始值
         dispatch_semaphore_signal 发送一个信号,信号通知,信号量＋1
         dispatch_semaphore_wait 等待信号,信号量－1
         
         当信号量<0时，线程阻塞，知道信号量>0，线程会再次启动执行
         所以当初始值为1时，可以起到加锁的效果
         
         */
        dispatch_queue_t queue = dispatch_queue_create("com.hisen.semaphore", DISPATCH_QUEUE_CONCURRENT);
        dispatch_semaphore_t countSemaphore = dispatch_semaphore_create(10);//允许最多并行的线程数为10
        
        for (int i = 0; i < 100; i++) {
            dispatch_semaphore_wait(countSemaphore, DISPATCH_TIME_FOREVER);
            dispatch_async(queue, ^{
                NSLog(@"task %d in Thread-%lu", i, [[NSThread currentThread] sequenceNumber]);
                dispatch_semaphore_signal(countSemaphore);
            });
        }
        
        dispatch_barrier_async(queue, ^{
            sleep(3);
            NSLog(@"----------------------------------------------------");
        });
        
        dispatch_semaphore_t lockSemaphore = dispatch_semaphore_create(1);//允许最多并行的线程数为1
        __block int count = 1000;
        for (int i = 0; i < 100; i++) {
            dispatch_semaphore_wait(lockSemaphore, DISPATCH_TIME_FOREVER);
            dispatch_async(queue, ^{
                int value = (arc4random() % 4) + 6;
                NSLog(@"%d-%d=%d in Thread-%lu", count, value, count-value, [[NSThread currentThread] sequenceNumber]);
                count -= value;
                dispatch_semaphore_signal(lockSemaphore);
            });
        }
        
        [[NSRunLoop mainRunLoop] run];
    }
    return 0;
}
