//
//  main.m
//  SynchronizedBiting
//
//  Created by Hisen on 26/03/2018.
//  Copyright © 2018 Hisen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSThread+SequenceNumber.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        NSObject *obj = [NSObject new];
        
        /*
         * @synchronized(obj) {}
         * @synchronized内部实现大概是
         * id synchronizeTarget = (id)obj
         * @try {
         *     objc_sync_enter(synchronizeTarget);
         *      do work
         * } @finally {
         *     objc_sync_exit(synchronizeTarget);
         * }
         * 1.以传入的obj为该锁的唯一标识
         * 2.@synchronized会保证objc_sync_enter()和objc_sync_exit()接收的是相同对象，这样加锁和解锁才能成对，在block中将obj置为nil也不会有影响
         * 3.@synchronized(nil)是空操作，不会得到锁，代码也不是线程安全的
         * 4.@synchronized([NSNull null])可以加锁成功，保证线程安全
         */
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            // 这个线程sleep(1),所以下面的线程首先拿到互斥锁
            sleep(1);
            
            // obj
            @synchronized(obj) {
                NSLog(@"线程%ld同步操作", (long)[[NSThread currentThread] sequenceNumber]);
            }
            
            // nil
//            @synchronized(nil) {
//                NSLog(@"线程%ld同步操作", (long)[[NSThread currentThread] sequenceNumber]);
//            }
            
            // [NSNull null]
//            @synchronized([NSNull null]) {
//                NSLog(@"线程%ld同步操作", (long)[[NSThread currentThread] sequenceNumber]);
//            }
        });
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            // obj
            @synchronized(obj) {
                NSLog(@"线程%ld同步操作开始", (long)[[NSThread currentThread] sequenceNumber]);
                sleep(2);
                NSLog(@"线程%ld同步操作结束", (long)[[NSThread currentThread] sequenceNumber]);
            }
            
            // nil
//            @synchronized(nil) {
//                NSLog(@"线程%ld同步操作开始", (long)[[NSThread currentThread] sequenceNumber]);
//                sleep(3);
//                NSLog(@"线程%ld同步操作结束", (long)[[NSThread currentThread] sequenceNumber]);
//            }
            
            // [NSNull null]
//            @synchronized([NSNull null]) {
//                NSLog(@"线程%ld同步操作开始", (long)[[NSThread currentThread] sequenceNumber]);
//                sleep(3);
//                NSLog(@"线程%ld同步操作结束", (long)[[NSThread currentThread] sequenceNumber]);
//            }
        });

        // 手动开启主线程runloop
        [[NSRunLoop mainRunLoop] run];
    }
    return 0;
}
