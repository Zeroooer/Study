//
//  main.m
//  MainQueue
//
//  Created by Hisen on 29/03/2018.
//  Copyright © 2018 Hisen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSThread+SequenceNumber.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        dispatch_queue_t mainQueue = dispatch_get_main_queue();
        dispatch_queue_t serialQueue = dispatch_queue_create("com.hisen.sericalQueue", DISPATCH_QUEUE_SERIAL);
        
        // 主队列的任务一定在主线程执行
        dispatch_async(mainQueue, ^{
            NSLog(@"async task 1 in Thread-%lu", [[NSThread currentThread] sequenceNumber]);
            if (strcmp(dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL), dispatch_queue_get_label(mainQueue)) == 0) {
                NSLog(@"async task 1 运行在主队列，队列是: %s", dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL));
            } else {
                NSLog(@"async task 1 没有运行在主队列, 队列是：%s", dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL));
            }
        });
        
        // 主线程执行的代码不一定在主队列上
        dispatch_sync(serialQueue, ^{
            NSLog(@"sync task 2 in Thread-%lu", [[NSThread currentThread] sequenceNumber]);
            if (strcmp(dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL), dispatch_queue_get_label(mainQueue)) == 0) {
                NSLog(@"sync task 2 运行在主队列，队列是: %s", dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL));
            } else {
                NSLog(@"sync task 2 没有运行在主队列, 队列是：%s", dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL));
            }
        });
        
//        dispatch_async(globalQueue, ^{
//            dispatch_async(mainQueue, ^{
//                if (strcmp(dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL), dispatch_queue_get_label(mainQueue)) == 0) {
//                    NSLog(@"is main queue? 1, is main thread? %i", (int)[NSThread isMainThread]);
//                }
//            });
//        });
//
//        dispatch_async(globalQueue, ^{
//            NSLog(@"%s", dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL));
//            NSLog(@"async task 3 in Thread-%lu", [[NSThread currentThread] sequenceNumber]);
//            dispatch_sync(customSerialQueue1, ^{
//                NSLog(@"%s", dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL));
//                NSLog(@"sync task 4 in Thread-%lu", [[NSThread currentThread] sequenceNumber]);
//            });
//        });
//
//
//        // 主线程dispatch_sync(mainQueue, ^{}); crash
////        dispatch_sync(mainQueue, ^{
////            NSLog(@"sync task 1 in Thread-%lu", [[NSThread currentThread] sequenceNumber]);
////        });
//
//
//        dispatch_async(globalQueue, ^{
//            NSLog(@"async task in globalQueue in Thread-%lu", [[NSThread currentThread] sequenceNumber]);
//        });
//
//        dispatch_async(globalQueueOverCommit, ^{
//            NSLog(@"async task in globalQueueOverCommit in Thread-%lu", [[NSThread currentThread] sequenceNumber]);
//        });
//
//        dispatch_async(mainQueue, ^{
//            NSLog(@"async task 1 in Thread-%lu", [[NSThread currentThread] sequenceNumber]);
//        });
//
//        dispatch_async(mainQueue, ^{
//            NSLog(@"async task 2 in Thread-%lu", [[NSThread currentThread] sequenceNumber]);
//        });
//
//        dispatch_async(mainQueue, ^{
//            NSLog(@"async task 3 in Thread-%lu", [[NSThread currentThread] sequenceNumber]);
//        });
        
        [[NSRunLoop currentRunLoop] run];
        
    }
    return 0;
}
