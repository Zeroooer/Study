//
//  main.m
//  DispatchBarrierAsync
//
//  Created by Hisen on 2017/5/27.
//  Copyright © 2017年 Hisen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSThread+SequenceNumber.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        dispatch_queue_t queue = dispatch_queue_create("com.hisen.barrier", DISPATCH_QUEUE_CONCURRENT);
        
        dispatch_async(queue, ^{
            NSLog(@"task 1 in Thread-%ld", (long)[[NSThread currentThread] sequenceNumber]);
        });
        
        dispatch_async(queue, ^{
            NSLog(@"task 2 in Thread-%ld", (long)[[NSThread currentThread] sequenceNumber]);
        });
        
        dispatch_async(queue, ^{
            NSLog(@"task 3 in Thread-%ld", (long)[[NSThread currentThread] sequenceNumber]);
        });
        
        // 在异步任务中添加一个同步任务
        dispatch_barrier_async(queue, ^{
            sleep(10);
            NSLog(@"after task 1 | 2 | 3\n before task 4 | 5 | 6");
        });
        
        dispatch_async(queue, ^{
            NSLog(@"task 4 in Thread-%ld", (long)[[NSThread currentThread] sequenceNumber]);
        });
        
        dispatch_async(queue, ^{
            NSLog(@"task 5 in Thread-%ld", (long)[[NSThread currentThread] sequenceNumber]);
        });
        
        dispatch_async(queue, ^{
            NSLog(@"task 6 in Thread-%ld", (long)[[NSThread currentThread] sequenceNumber]);
        });
        
        [[NSRunLoop mainRunLoop] run];
    }
    return 0;
}
