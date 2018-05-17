//
//  main.m
//  NSConditionBiting
//
//  Created by Hisen on 27/03/2018.
//  Copyright © 2018 Hisen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSThread+SequenceNumber.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        /*
         * NSCondition的底层是通过条件变量(Condition variable) pthread_cond_t 来实现的
         * NSCondition对象是一个锁和一个线程检查器，多个线程可以同时上锁
         * 如果任务不能安全执行，需要手动调用wait，挂起线程
         * 当其他线程的该锁调用signal或者broadcast方法，挂起的线程会被唤醒
         * signal只是一个信号量，只能唤醒一个等待的线程，broadcast可以唤醒所有在等待的线程
         * 如果没有线程在等待，signal和broadcast的发送的信号都是无效的
         */
        
        NSCondition *condition = [NSCondition new];
        NSMutableArray *products = [NSMutableArray new];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            while (1) {
                [condition lock];
                if (products.count == 0) {
                    NSLog(@"线程%ld wait for product", (long)[[NSThread currentThread] sequenceNumber]);
                    [condition wait];
                }
                [products removeObjectAtIndex:0];
                NSLog(@"线程%ld custom a product, 剩余总量：%lu", (long)[[NSThread currentThread] sequenceNumber], (unsigned long)products.count);
                [condition unlock];
            }
        });
        
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            while (1) {
                [condition lock];
                [products addObject:[NSObject new]];
                NSLog(@"线程%ld produce a product, 剩余总量：%lu", (long)[[NSThread currentThread] sequenceNumber], (unsigned long)products.count);
                [condition signal];
                NSLog(@"唤醒睡眠线程");
                [condition unlock];
                sleep(1);
            }
        });
        
        [[NSRunLoop currentRunLoop] run];
        
    }
    return 0;
}
