//
//  main.m
//  NSConditionLockBiting
//
//  Created by Hisen on 27/03/2018.
//  Copyright © 2018 Hisen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSThread+SequenceNumber.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        /*
         * NSConditionLock 遵循NSLocking协议
         * 与NSLock类似，多了一个condition属性，每个操作都多了一个关于Condition属性的方法
         * 只有condition与初始化的condition相等才能加锁成功
         * unlockWithCondition:是解锁然后设置condition的值
         * 可以用来做任务依赖，任务B开始的加锁condition是任务A解锁后解锁设置的condition
         */
        
        NSConditionLock *conditionLock = [[NSConditionLock alloc] initWithCondition:0];
        NSMutableArray *products = [NSMutableArray new];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            while(1) {
                [conditionLock lockWhenCondition:0];
                NSLog(@"线程%ld 尝试加 NSConditionLock 成功", (long)[[NSThread currentThread] sequenceNumber]);
                [products addObject:[NSObject new]];
                NSLog(@"线程%ld produce a product, 总量剩余：%lu", (long)[[NSThread currentThread] sequenceNumber], (unsigned long)products.count);
                [conditionLock unlockWithCondition:1];
                NSLog(@"线程%ld 解锁成功，并将condition置为1", (long)[[NSThread currentThread] sequenceNumber]);
                sleep(1);
            }
        });
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            while (1) {
                NSLog(@"线程%ld wait for product", (long)[[NSThread currentThread] sequenceNumber]);
                [conditionLock lockWhenCondition:1];
                NSLog(@"线程%ld 尝试加 NSConditionLock 成功", (long)[[NSThread currentThread] sequenceNumber]);
                if (products.count > 0) {
                    [products removeObjectAtIndex:0];
                }
                NSLog(@"线程%ld custom a product, 总量剩余：%lu", (long)[[NSThread currentThread] sequenceNumber], (unsigned long)products.count);
                [conditionLock unlockWithCondition:0];
                NSLog(@"线程%ld 解锁成功，并将condition置为0", (long)[[NSThread currentThread] sequenceNumber]);
            }
        });
        
        
        [[NSRunLoop currentRunLoop] run];
    }
    return 0;
}
