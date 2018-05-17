//
//  main.m
//  ConcurrentDispatchQueue
//
//  Created by Hisen on 2017/5/28.
//  Copyright © 2017年 Hisen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSThread+SequenceNumber.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        dispatch_queue_t concurrentQueue = dispatch_queue_create("com.hisen.concurrentQueue", DISPATCH_QUEUE_CONCURRENT);
        dispatch_queue_t serialQueue = dispatch_queue_create("com.hisen.serialqueue", DISPATCH_QUEUE_SERIAL);
        dispatch_queue_t globalQueue = dispatch_get_global_queue(0, 0);
        dispatch_queue_t mainQueue = dispatch_get_main_queue();


        
        /*
         并行队列，同步执行
         在当前线程执行，任务按顺序执行
         */
        
        dispatch_sync(concurrentQueue, ^{
            NSLog(@"sync task 1 in Thread-%lu", [[NSThread currentThread] sequenceNumber]);
        });
        
        dispatch_sync(concurrentQueue, ^{
            NSLog(@"sync task 2 in Thread-%lu", [[NSThread currentThread] sequenceNumber]);
        });
        
        dispatch_sync(concurrentQueue, ^{
            NSLog(@"sync task 3 in Thread-%lu", [[NSThread currentThread] sequenceNumber]);
        });
        
        /*
         并行队列，异步执行
         开多个线程执行，执行顺序随机
         */
        
        dispatch_async(concurrentQueue, ^{
            NSLog(@"async task 1 in Thread-%lu", [[NSThread currentThread] sequenceNumber]);
        });
        
        dispatch_async(concurrentQueue, ^{
            NSLog(@"async task 2 in Thread-%lu", [[NSThread currentThread] sequenceNumber]);
        });
        
        dispatch_async(concurrentQueue, ^{
            NSLog(@"async task 3 in Thread-%lu", [[NSThread currentThread] sequenceNumber]);
        });
        
        [[NSRunLoop currentRunLoop] run];
    }
    return 0;
}
