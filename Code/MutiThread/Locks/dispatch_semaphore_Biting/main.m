//
//  main.m
//  dispatch_semaphore_Biting
//
//  Created by Hisen on 27/03/2018.
//  Copyright © 2018 Hisen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSThread+SequenceNumber.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
    
        /*
         * dispatch_semaphore
         */
        
        
        /*
         * 创建一个信号量dispatch_semaphore_t，初始值为传入的参数
         * 参数必须大于等于0
         * 参数为1时可以作为互斥锁使用
         * 一般是用来控制并发量的,初始值为X的信号量，则允许X个线程同时访问临界区资源
         */
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            sleep(1);
            /*
             * dispatch_semaphore_wait(semaphore, timeout)
             * 判断信号量是否大于0，大于0则信号量减1,消耗信号量并执行任务
             * 如果信号量等于0,直接挂起线程，等待timeout时间后唤醒，或者这期间有别的线程调用dispatch_semaphore_signal()发送信号，释放信号量
             * 如果等待timeout时间后唤醒时，dispatch_semaphore_wait()返回值不是0(即没有信号量可消耗)，则任务失败，退出线程
             * 所以一般设置timeout = DISPATCH_TIME_FOREVER 保证在信号量可消耗前线程一直睡眠
             */
            long status = dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            if (status == 0) {
                // status == 0 表示有信号量可以消耗
                NSLog(@"线程%ld尝试加锁成功", (long)[[NSThread currentThread] sequenceNumber]);
                // 发出信号，信号量+1，唤醒一个休眠的线程
                dispatch_semaphore_signal(semaphore);
                NSLog(@"线程%ld解锁成功", (long)[[NSThread currentThread] sequenceNumber]);
            } else {
                NSLog(@"线程%ld尝试加锁失败", (long)[[NSThread currentThread] sequenceNumber]);
            }
        });
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            NSLog(@"线程%ld尝试加锁成功", (long)[[NSThread currentThread] sequenceNumber]);
            sleep(10);
            dispatch_semaphore_signal(semaphore);
            NSLog(@"线程%ld解锁成功", (long)[[NSThread currentThread] sequenceNumber]);
        });
       
        [[NSRunLoop currentRunLoop] run];
    }
    return 0;
}
