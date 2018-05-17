//
//  main.m
//  DispatchGroupAsync
//
//  Created by Hisen on 2017/5/27.
//  Copyright © 2017年 Hisen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSThread+SequenceNumber.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {

        // 1. 调度组
        dispatch_group_t group1 = dispatch_group_create();
        
        // 2.队列
        dispatch_queue_t groupqueue1 = dispatch_queue_create("com.hisen.groupqueue1", DISPATCH_QUEUE_CONCURRENT);

        dispatch_group_async(group1, groupqueue1, ^{
            NSLog(@"task 1 in Thread-%ld", (long)[[NSThread currentThread] sequenceNumber]);
        });
        
        dispatch_group_async(group1, groupqueue1, ^{
            NSLog(@"task 2 in Thread-%ld", (long)[[NSThread currentThread] sequenceNumber]);
        });
        
        dispatch_group_async(group1, groupqueue1, ^{
            NSLog(@"task 3 in Thread-%ld", (long)[[NSThread currentThread] sequenceNumber]);
        });
        
//        dispatch_group_notify(group1, groupqueue1, ^{
//            sleep(10);
//            NSLog(@"after task 1 | 2 | 3 \n before task 4 | 5 | 6 ");
//            dispatch_async(groupqueue1, ^{
//                NSLog(@"task 4 in Thread-%ld", (long)[[NSThread currentThread] sequenceNumber]);
//            });
//            
//            dispatch_async(groupqueue1, ^{
//                NSLog(@"task 5 in Thread-%ld", (long)[[NSThread currentThread] sequenceNumber]);
//            });
//            
//            dispatch_async(groupqueue1, ^{
//                NSLog(@"task 6 in Thread-%ld", (long)[[NSThread currentThread] sequenceNumber]);
//            });
//        });
        
        dispatch_group_notify(group1, groupqueue1, ^{
            dispatch_async(groupqueue1, ^{
                NSLog(@"task 4 in Thread-%ld", (long)[[NSThread currentThread] sequenceNumber]);
            });
        });
        
        dispatch_group_notify(group1, groupqueue1, ^{
            dispatch_async(groupqueue1, ^{
                NSLog(@"task 5 in Thread-%ld", (long)[[NSThread currentThread] sequenceNumber]);
            });
        });
        
        dispatch_group_notify(group1, groupqueue1, ^{
            dispatch_async(groupqueue1, ^{
                NSLog(@"task 6 in Thread-%ld", (long)[[NSThread currentThread] sequenceNumber]);
            });
        });
        
        
        
        [[NSRunLoop mainRunLoop] run];
    }
    return 0;
}
