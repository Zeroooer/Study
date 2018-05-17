//
//  CustomOperation.m
//  NSOperationBiting
//
//  Created by Hisen on 07/04/2018.
//  Copyright © 2018 Hisen. All rights reserved.
//

#import "CustomOperation.h"
#import "NSThread+SequenceNumber.h"

@implementation CustomOperation

/*
 * 手动合成这些属性，手动添加这些属性的KVO
 */
@synthesize executing = _executing;
@synthesize cancelled = _cancelled;
@synthesize finished = _finished;

//- (void)main {
//    NSLog(@"Start Custom Operation [%@] in thread [%ld]", NSStringFromSelector(_cmd), (long)[[NSThread currentThread] sequenceNumber]);
//    sleep(3);
//    NSLog(@"Finish Custom Operation [%@] in thread [%ld]", NSStringFromSelector(_cmd), (long)[[NSThread currentThread] sequenceNumber]);
//    [self willChangeValueForKey:@"isFinished"];
//    _finished = YES;
//    [self didChangeValueForKey:@"isFinished"];
//}

- (void)asyncStart {
    if (self.isAsynchronous) {
        /*
         * 如果是可并发的，新建线程执行
         */
        [NSThread detachNewThreadSelector:@selector(start) toTarget:self withObject:nil];
    } else {
        [self start];
    }
}

/*
 * 如果实现了start方法，则不会执行main方法
 * start 方法需要手动设置operation的finished状态，main 方法执行完会自动设置operation的finished状态
 * 手动执行operation就是调用其start方法
 * 所谓的operation可以cancell其实是在任务的执行过程中多次check这个operation的isCancelled属性来判定operation是否被取消了
 */
- (void)start {
    /*
     * 任务开始执行前先进行cancel检查，有可能在执行前就已经被取消了
     */
    if ([self cancelCheck]) {
        return;
    }
    self.executing = YES;
    /*
     * 任务代码
     */
    {
        NSLog(@"Start Custom Operation [%@] in thread [%ld]", NSStringFromSelector(_cmd), (long)[[NSThread currentThread] sequenceNumber]);
        // 假装执行任务
        sleep(3);
        /*
         * 任务中间手动插入isCancelled的检查，如果 isCancelled = YES 就取消任务
         */
        if ([self cancelCheck]) {
            return;
        }
        NSLog(@"Finish Custom Operation [%@] in thread [%ld]", NSStringFromSelector(_cmd), (long)[[NSThread currentThread] sequenceNumber]);
    }
    /*
     * 同步型的任务在start方法最后调用finish
     */
    [self finish];
}

/*
 * 对operation的isCancelled做检查
 */
- (BOOL)cancelCheck {
    if (self.isCancelled) {
        NSLog(@"Cancelled Custom Operation in thread [%ld]", (long)[[NSThread currentThread] sequenceNumber]);
        /*
         * operation如果取消，需要将其finished置为YES,保证依赖它的其他operation可以正常执行
         */
        [self finish];
        return YES;
    }
    return NO;
}

/*
 * 设置_cancelled = YES;
 * operation调用cancell方法，只是设置其isCancelled=YES; 不会马上取消operation
 * 然后operation的运行过程中check到其isCancelled=YES直接return来实现取消operation
 */
- (void)cancel {
    self.cancelled = YES;
}

/*
 * operation执行完成，设置其状态
 */
- (void)finish {
    self.executing = NO;
    self.finished = YES;
}

# pragma mark - setter
- (void)setExecuting:(BOOL)executing {
    [self willChangeValueForKey:@"isExecuting"];
    _executing = executing;
    [self didChangeValueForKey:@"isExecuting"];
}

- (void)setCancelled:(BOOL)cancelled {
    [self willChangeValueForKey:@"isCancelled"];
    _cancelled = cancelled;
    [self didChangeValueForKey:@"isCancelled"];
}

- (void)setFinished:(BOOL)finished {
    [self willChangeValueForKey:@"isFinished"];
    _finished = finished;
    [self didChangeValueForKey:@"isFinished"];
}

# pragma mark - getter
- (BOOL)isExecuting {
    return _executing;
}

- (BOOL)isCancelled {
    return _cancelled;
}

- (BOOL)isFinished {
    return _finished;
}

/*
 * 取代isConcurrent
 */
- (BOOL)isAsynchronous {
    return YES;
}

# pragma mark - autoKVO
+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key {
    if ([key isEqualToString:@"isExecuting"] || [key isEqualToString:@"isFinished"] || [key isEqualToString:@"isCancelled"]) {
        return NO;
    }
    return YES;
}

@end
