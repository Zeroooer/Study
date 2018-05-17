//
//  main.m
//  DispatchApply
//
//  Created by Hisen on 2017/5/31.
//  Copyright © 2017年 Hisen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSThread+SequenceNumber.h"


int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        NSArray *array = @[@1, @2, @3, @4, @5];
        
        dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        
        dispatch_async(globalQueue, ^{
            dispatch_apply([array count], globalQueue, ^(size_t index) {
                NSLog(@"array[%zu]=%@ in Thread-%lu", index, array[index], [[NSThread mainThread] sequenceNumber]);
            });
            
            dispatch_async(globalQueue, ^{
                NSLog(@"done in Thread-%lu", [[NSThread currentThread] sequenceNumber]);
            });
        });
        
        [[NSRunLoop currentRunLoop] run];
        
    }
    return 0;
}
