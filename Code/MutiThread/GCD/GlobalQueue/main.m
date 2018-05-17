//
//  main.m
//  GlobalQueue
//
//  Created by Hisen on 2017/5/28.
//  Copyright © 2017年 Hisen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSThread+SequenceNumber.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        // 非overcommit的globalQueue
//        dispatch_queue_t globalQueue = dispatch_get_global_queue(0, 0);
        
        // overcommit的globalQueue，不论系统状况如何都会新开一个线程
        dispatch_queue_t globalQueue = dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0x2ull);
        
        /*
         全局队列本质就是并发队列
         同步执行不开新线程，在当前线程顺序执行
         */
        dispatch_sync(globalQueue, ^{
            NSLog(@"sync task 1 in Thread-%lu", [[NSThread currentThread] sequenceNumber]);
        });
        
        dispatch_sync(globalQueue, ^{
            NSLog(@"sync task 2 in Thread-%lu", [[NSThread currentThread] sequenceNumber]);
        });
        
        dispatch_sync(globalQueue, ^{
            NSLog(@"sync task 3 in Thread-%lu", [[NSThread currentThread] sequenceNumber]);
        });
        
        /*
         全局队列本质就是并发队列
         异步执行会开多个线程，执行顺序随机
         */
        
        for (int i = 1; i <= 100; i++) {
            dispatch_async(globalQueue, ^{
                sleep(1);
                NSLog(@"async task %d in Thread-%lu", i, [[NSThread currentThread] sequenceNumber]);
            });
        }
        
        [[NSRunLoop mainRunLoop] run];
    }
    return 0;
}
