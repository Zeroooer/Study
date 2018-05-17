//
//  main.m
//  DispatchAfter
//
//  Created by Hisen on 2017/5/28.
//  Copyright © 2017年 Hisen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSThread+SequenceNumber.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        //创建串行队列
        dispatch_queue_t queue = dispatch_queue_create("com.hisen.after", DISPATCH_QUEUE_CONCURRENT);
        //立即打印一条信息
        NSLog(@"Begin add block in Thread-%lu", [[NSThread currentThread] sequenceNumber]);
        
        //提交一个block
        dispatch_async(queue, ^{
            //Sleep 10秒
            [NSThread sleepForTimeInterval:10];
            NSLog(@"First block in Thread-%lu", [[NSThread currentThread] sequenceNumber]);
        });
        
        //5 秒以后提交block
        /*
         dispatch_after 延时提交block，不是延时执行
         */
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), queue, ^{
            NSLog(@"After block in Thread-%lu", [[NSThread currentThread] sequenceNumber]);
        });
        
        NSLog(@"End add block in Thread-%lu", [[NSThread currentThread] sequenceNumber]);

        [[NSRunLoop mainRunLoop] run];
    }
    return 0;
}
