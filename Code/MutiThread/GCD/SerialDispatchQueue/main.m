//
//  main.m
//  SerialDispatchQueue
//
//  Created by Hisen on 2017/5/28.
//  Copyright © 2017年 Hisen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSThread+SequenceNumber.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        dispatch_queue_t serialQueue = dispatch_queue_create("com.hisen.serialqueue", DISPATCH_QUEUE_SERIAL);
        
        /*
         串行队列，同步执行
         在当前程执行，任务顺序执行
         */
        
        dispatch_sync(serialQueue, ^{
            NSLog(@"sync task 1 in Thread-%lu", [[NSThread currentThread] sequenceNumber]);
        });
        
        dispatch_sync(serialQueue, ^{
            NSLog(@"sync task 2 in Thread-%lu", [[NSThread currentThread] sequenceNumber]);
        });
        
        dispatch_sync(serialQueue, ^{
            NSLog(@"sync task 3 in Thread-%lu", [[NSThread currentThread] sequenceNumber]);
        });
        
        /*
         串行队列，异步执行
         新开一个子线程执行，任务顺序执行
         */
        
        dispatch_async(serialQueue, ^{
            NSLog(@"async task 1 in Thread-%lu", [[NSThread currentThread] sequenceNumber]);
        });
        
        dispatch_async(serialQueue, ^{
            NSLog(@"async task 2 in Thread-%lu", [[NSThread currentThread] sequenceNumber]);
        });
        
        dispatch_async(serialQueue, ^{
            NSLog(@"async task 3 in Thread-%lu", [[NSThread currentThread] sequenceNumber]);
        });
        
        [[NSRunLoop mainRunLoop] run];
        
    }
    return 0;
}
