//
//  ViewController.m
//  GCDBiting
//
//  Created by Hisen on 03/04/2018.
//  Copyright © 2018 Hisen. All rights reserved.
//

#import "ViewController.h"
#import "NSThread+SequenceNumber.h"

static const void * const kDispatchQueueSpecificKey = "com.hs.specific";
static void * kDispatchQueueSpecificContext = "specificContext";


@interface ViewController ()

@property (nonatomic, strong) dispatch_source_t timer;
@property (nonatomic, strong) dispatch_source_t customSource;

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
//    [self queuesBiting];
//    [self mainQueueBiting];
//    [self globalQueueBiting];
//    [self serialQueueBiting];
//    [self concurrentQueueBiting];
//    [self overcommitBiting];
//    [self dispatchAfterBiting];
//    [self dispatchBarrierBiting];
//    [self dispatchApplyBiting];
//    [self dispatchGroupWaitBiting];
//    [self dispatchGroupNotifyBiting];
//    [self deadLockBiting];
//    [self dispatchSourceTimerBiting];
//    [self dispatchSourceCustomBiting];
//    [self dispatchBlockCreateBiting];
//    [self dispatchBlockWaitBiting];
//    [self dispatchBlockNotifyBiting];
//    [self dispatchBlockCancellBiting];
//    [self dispatchSemaphoreBiting];
//    [self asyncInMainQueueWakeupTheRunnloop];
    
    [self dispatchSepcificBiting];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma runloop observer
- (void)configRunloopObserver {
    /*
     * @param1: CFRunLoopObserverRef(观察者)分配内存空间方式
     * @param2: 监听那些状态 kCFRunLoopAllActivities(监听所有状态)
     * @param3: 是否每次都要监听
     * @param4: 优先级
     * @param5: 回调函数
     */
    CFRunLoopObserverRef observer = CFRunLoopObserverCreateWithHandler(CFAllocatorGetDefault(), kCFRunLoopAllActivities, YES, 0, ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {
        // observer监听对象
        // activity Runloop当前状态
        NSLog(@"Current thread Runloop activity: %@", activityDescription(activity));
    });
    /*
     第一个参数: 需要添加观察者的Runloop
     第二个参数: 需要添加的CFRunLoopObserverRef(观察者)
     第三个参数: 把监听添加到RunLoop那个模式中
     */
    CFRunLoopAddObserver(CFRunLoopGetMain(), observer, kCFRunLoopDefaultMode);
}

static inline NSString* activityDescription(CFRunLoopActivity activity)
{
    NSString *activityDescription;
    switch (activity) {
        case kCFRunLoopEntry:
            // 即将进入run loop
            activityDescription = @"kCFRunLoopEntry";
            break;
        case kCFRunLoopBeforeTimers:
            // 即将处理timer
            activityDescription = @"kCFRunLoopBeforeTimers";
            break;
        case kCFRunLoopBeforeSources:
            // 即将处理source
            activityDescription = @"kCFRunLoopBeforeSources";
            break;
        case kCFRunLoopBeforeWaiting:
            // 即将进入休眠
            activityDescription = @"kCFRunLoopBeforeWaiting";
            break;
        case kCFRunLoopAfterWaiting:
            // 被唤醒但是还没开始处理事件
            activityDescription = @"kCFRunLoopAfterWaiting";
            break;
        case kCFRunLoopExit:
            // run loop已经退出
            activityDescription = @"kCFRunLoopExit";
            break;
        default:
            break;
    }
    return activityDescription;
}

# pragma GCD
# pragma mark - queues
- (void)queuesBiting {
    /*
     * GCD的内置的队列可以分为两层,一共是15个
     * 第一层
     * 1是主队列 定义在init.c文件，2-3 是内部管理queue用的，定义在queue.c文件
     * 1 com.apple.main-thread
     * 2 com.apple.libdispatch-manager
     * 3 com.apple.root.libdispatch-manager
     * 第二层
     * 4-15 是根据6个优先级和是否overcommit(控制线层数是否能超过物理核数)一共有6*2=12个global root queue(早期版本只有4个优先级，8个global root queue)存储在一个数组里，dispatch_get_global_queue(priority, flag)就是根据参数从这个数组中取相应的queue返回,root queue就是最终block提交的地方，通过dispatch_queue_create(label, attr)自定义queue，会通过attr从root queue数组中找出相应的queue作为其target queue来接收其提交的block
     * 4 com.apple.root.maintenance-qos
     * 5 com.apple.root.maintenance-qos.overcommit
     * 6 com.apple.root.background-qos
     * 7 com.apple.root.background-qos.overcommit
     * 8 com.apple.root.utility-qos
     * 9 com.apple.root.utility-qos.overcommit
     * 10 com.apple.root.default-qos
     * 11 com.apple.root.default-qos.overcommit
     * 12 com.apple.root.user-initiated-qos
     * 13 com.apple.root.user-initiated-qos.overcommit
     * 14 com.apple.root.user-interactive-qos
     * 15 com.apple.root.user-interactive-qos.overcommit
     * GCD 在global root queue的下层维护了一个线层池，所有的通过GCD提交的block，不管是main queue，global queue，还是自定义queue，最终都会提交给4-15这12个global root queue，这12个queue直接与线程池交互，主线程也在这个线层池里。
     */
    
    /*
     * mainQueue是串行队列，width=1，target=com.apple.root.default-qos.overcommit
     * 既然mainQueue的target是com.apple.root.default-qos.overcommit,那理论上提交到mainQueue的任务会提交给它的target，然后由内部线程池分配线程执行，那它是怎么保证mainQueue的任务在主线程执行的呢？
     * dispatch_async到mainQueue的时候，任务不会往下层target提交，不由线程池处理，而是libdispatch向主线程的runloop发送消息，Runloop会被唤醒并从消息中取出block执行，从而保证提交到mainQueue上的任务在主线程执行
     */
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    
    
    /*
     * global queue 都是并行队列
     * 通过dispatch_get_global_queue()拿到的queue默认都是非overcommit的，优先级也只暴露了5种QOS_CLASS_[USER_INTERACTIVE, USER_INITIATED, DEFAULT, UTILITY, BACKGROUND]
     * USER_INITIATED <=> PRIORITY_HIGH
     * DEFAULT <=> PRIORITY_DEFAULT
     * UTILITY <=> PRIORITY_LOW
     * BACKGROUND <=> PRIORITY_BACKGROUND
     * identifier = 0x05(QOS_CLASS_MAINTENANCE)，flag = 0x2ull(DISPATCH_QUEUE_OVERCOMMIT)是翻源码找到的
     */
    dispatch_queue_t globalQueue = dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0);
    dispatch_queue_t globalQueueMaintenance = dispatch_get_global_queue(0x05, 0);
    dispatch_queue_t globalQueueOvercommit = dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0x2ull);

    /*
     * 自定义串行队列的target是overcommit的
     * 自定义并行队列的target是非overcommit的
     */
    dispatch_queue_t serialQueue = dispatch_queue_create("com.hs.serialQueue", DISPATCH_QUEUE_SERIAL);
    dispatch_queue_t concurrentQueue = dispatch_queue_create("com.hs.concurrentQueue", DISPATCH_QUEUE_CONCURRENT);

    NSLog(@"%@", mainQueue);
    NSLog(@"%@", globalQueue);
    NSLog(@"%@", globalQueueMaintenance);
    NSLog(@"%@", globalQueueOvercommit);
    NSLog(@"%@", serialQueue);
    NSLog(@"%@", concurrentQueue);
}

- (void)mainQueueBiting {
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    
    /*
     * 在主队列同步执行任务会crash
     * 队列死锁
     */
    
    /*
     * main queue 异步执行，不会新开线程，在主线程顺序执行
     */
    dispatch_async(mainQueue, ^{
        const char *queueName = dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL);
        NSLog(@"async task 1 in thread %ld, in queue [%s]", (long)[[NSThread currentThread] sequenceNumber], queueName);
    });
    
    dispatch_async(mainQueue, ^{
        const char *queueName = dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL);
        NSLog(@"async task 2 in thread %ld, in queue [%s]", (long)[[NSThread currentThread] sequenceNumber], queueName);
    });
    
    dispatch_async(mainQueue, ^{
        const char *queueName = dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL);
        NSLog(@"async task 3 in thread %ld, in queue [%s]", (long)[[NSThread currentThread] sequenceNumber], queueName);
    });
    
}

- (void)globalQueueBiting {
    dispatch_queue_t globalQueue = dispatch_get_global_queue(0, 0);
    
    /*
     * 全局队列同步执行
     * 在当前线程顺序执行
     */
    dispatch_sync(globalQueue, ^{
        const char *queueName = dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL);
        NSLog(@"sync task 1 in thread [%ld], in queue [%s]", (long)[[NSThread currentThread] sequenceNumber], queueName);
    });
    
    dispatch_sync(globalQueue, ^{
        const char *queueName = dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL);
        NSLog(@"sync task 2 in thread [%ld], in queue [%s]", (long)[[NSThread currentThread] sequenceNumber], queueName);
    });
    
    dispatch_sync(globalQueue, ^{
        const char *queueName = dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL);
        NSLog(@"sync task 3 in thread [%ld], in queue [%s]", (long)[[NSThread currentThread] sequenceNumber], queueName);
    });
    
    /*
     * 全局队列异步执行
     * 新开线程随机顺序执行
     */
    for (int i = 1; i <= 10; i++) {
        dispatch_async(globalQueue, ^{
            sleep(1);
            const char *queueName = dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL);
            NSLog(@"async task %d in thread [%ld], in queue [%s]", i, (long)[[NSThread currentThread] sequenceNumber], queueName);
        });
    }
}

- (void)serialQueueBiting {
    dispatch_queue_t serialQueue = dispatch_queue_create("com.hs.serialQueue", DISPATCH_QUEUE_SERIAL);
    
    /*
     * 串行队列，同步执行
     * 在当前线程顺序执行
     */
    
    dispatch_sync(serialQueue, ^{
        const char *queueName = dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL);
        NSLog(@"sync task 1 in thread [%ld], in queue [%s]", (long)[[NSThread currentThread] sequenceNumber], queueName);
    });
    
    dispatch_sync(serialQueue, ^{
        const char *queueName = dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL);
        NSLog(@"sync task 2 in thread [%ld], in queue [%s]", (long)[[NSThread currentThread] sequenceNumber], queueName);
    });
    
    dispatch_sync(serialQueue, ^{
        const char *queueName = dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL);
        NSLog(@"sync task 3 in thread [%ld], in queue [%s]", (long)[[NSThread currentThread] sequenceNumber], queueName);
    });
    
    /*
     * 串行队列，异步执行
     * 新开一个子线程执行，任务顺序执行
     */
    
    for (int i = 1; i <= 10; i++) {
        dispatch_async(serialQueue, ^{
            sleep(1);
            const char *queueName = dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL);
            NSLog(@"async task %d in thread [%ld], in queue [%s]", i, (long)[[NSThread currentThread] sequenceNumber], queueName);
        });
    }
}

- (void)concurrentQueueBiting {
    dispatch_queue_t concurrentQueue = dispatch_queue_create("com.hs.concurrentQueue", DISPATCH_QUEUE_CONCURRENT);
    
    /*
     * 并行队列，同步执行
     * 在当前线程顺序执行
     */
    
    dispatch_sync(concurrentQueue, ^{
        const char *queueName = dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL);
        NSLog(@"sync task 1 in thread [%ld], in queue [%s]", (long)[[NSThread currentThread] sequenceNumber], queueName);
    });
    
    dispatch_sync(concurrentQueue, ^{
        const char *queueName = dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL);
        NSLog(@"sync task 2 in thread [%ld], in queue [%s]", (long)[[NSThread currentThread] sequenceNumber], queueName);
    });
    
    dispatch_sync(concurrentQueue, ^{
        const char *queueName = dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL);
        NSLog(@"sync task 3 in thread [%ld], in queue [%s]", (long)[[NSThread currentThread] sequenceNumber], queueName);
    });
    
    /*
     * 并行队列，异步执行
     * 开多个线程执行，任务随机顺序执行
     */
    for (int i = 1; i <= 10; i++) {
        dispatch_async(concurrentQueue, ^{
            sleep(1);
            const char *queueName = dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL);
            NSLog(@"async task %d in thread [%ld], in queue [%s]", i, (long)[[NSThread currentThread] sequenceNumber], queueName);
        });
    }
}

# pragma mark - overcommit
- (void)overcommitBiting {
    /*
     * 切换使用overcommit的globalQueue和非overcommit的globalQueue进行测试
     * 非overcommit的globalQueue会根据系统状况创建线程，不会创建太多线程
     * overcommit的globalQueue会给每个任务创建一个线程，但线程数不会超过workqueue 中支持的最大线程数
     * 用这个命令 sysctl kern.wq_max_threads 可以查看workqueue 中支持的最大线程数
     */
    // 非overcommit的globalQueue
//    dispatch_queue_t globalQueue = dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0);
    // overcommit的globalQueue
    dispatch_queue_t globalQueue = dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0x2ull);
    
    for (int i = 1; i <= 600; i++) {
        dispatch_async(globalQueue, ^{
            sleep(1);
            const char *queueName = dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL);
            NSLog(@"async task %d in thread [%ld], in queue [%s]", i, (long)[[NSThread currentThread] sequenceNumber], queueName);
        });
    }
    
}

# pragma mark - dispatch_after
- (void)dispatchAfterBiting {
    /*
     * @param1  延时时长
     * @param2  延时时长后提交block的队列
     * @param3  block任务
     * dispatch_after()  是延时提交block，不是延时执行任务,任务执行是异步的
     * 内部依赖一个dispatch_source定时器
     */
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        const char *queueName = dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL);
        NSLog(@"after task 1 in thread [%ld], in queue [%s]", (long)[[NSThread currentThread] sequenceNumber], queueName);
    });
}

# pragma mark - dispatch_barrier_async
- (void)dispatchBarrierBiting {
    /*
     * 切换自定义并行队列和全局队列进行测试
     * 必须在自定义并行队列才有效果
     * dispatch_barrier_async() 是在多个异步任务中插入一个同步任务，它会保证在它之前添加的所有异步任务执行完毕后执行，同时在它后面添加的异步任务会等待它执行完毕后执行
     * 内部实现的核心是从队列中取任务的时候通过标记位来识别出任务是barrier_async的任务，来将其前后的异步任务分割开
     */
    dispatch_queue_t queue = dispatch_queue_create("com.hs.barrierQueue", DISPATCH_QUEUE_CONCURRENT);
    
    // 在global queue上表现和普通async没有区别
//    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    
    dispatch_async(queue, ^{
        sleep(3);
        const char *queueName = dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL);
        NSLog(@"async task 1 in thread [%ld], in queue [%s]", (long)[[NSThread currentThread] sequenceNumber], queueName);
    });
    
    dispatch_async(queue, ^{
        const char *queueName = dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL);
        NSLog(@"async task 2 in thread [%ld], in queue [%s]", (long)[[NSThread currentThread] sequenceNumber], queueName);
    });
    
    dispatch_async(queue, ^{
        const char *queueName = dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL);
        NSLog(@"async task 3 in thread [%ld], in queue [%s]", (long)[[NSThread currentThread] sequenceNumber], queueName);
    });
    
    // 在异步任务中添加一个同步任务
    dispatch_barrier_async(queue, ^{
        const char *queueName = dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL);
        NSLog(@"barrier async task in thread [%ld], in queue [%s]", (long)[[NSThread currentThread] sequenceNumber], queueName);
    });
    
    dispatch_async(queue, ^{
        const char *queueName = dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL);
        NSLog(@"async task 4 in thread [%ld], in queue [%s]", (long)[[NSThread currentThread] sequenceNumber], queueName);
    });
    
    dispatch_async(queue, ^{
        const char *queueName = dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL);
        NSLog(@"async task 5 in thread [%ld], in queue [%s]", (long)[[NSThread currentThread] sequenceNumber], queueName);
    });
    
    dispatch_async(queue, ^{
        const char *queueName = dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL);
        NSLog(@"async task 6 in thread [%ld], in queue [%s]", (long)[[NSThread currentThread] sequenceNumber], queueName);
    });
}

# pragma mark - dispatch_apply
- (void)dispatchApplyBiting {
    /*
     * 切换并行队列和串行队列进行测试
     * 串行队列在当前线程顺序执行
     * 并行队列会开多个线程并行执行
     * dispatch_apply会等待全部处理执行结束，所以直接在主线程dispatch_apply会阻塞主线程
     * ref: https://stackoverflow.com/questions/45669625/dispatch-apply-submit-block-to-main-queue-occasionally
     */
//    dispatch_queue_t queue = dispatch_queue_create("com.hs.concurrentQueue", DISPATCH_QUEUE_SERIAL);
    dispatch_queue_t queue = dispatch_queue_create("com.hs.concurrentQueue", DISPATCH_QUEUE_CONCURRENT);
    
    // 在主线程执行dispatch_apply()会阻塞主线程
    NSLog(@"-----主线程-----");
    dispatch_apply(10, queue, ^(size_t i) {
        const char *queueName = dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL);
        NSLog(@"async task %zu in thread [%ld], in queue [%s]", i, (long)[[NSThread currentThread] sequenceNumber], queueName);
    });

    
    // 在其他线程执行dispatch_apply()就不会阻塞主线程
    NSLog(@"-----其他线程-----");
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        const char *queueName = dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL);
        NSLog(@"dispatch to queue [%s], thread [%ld]", queueName, (long)[[NSThread currentThread] sequenceNumber]);
        dispatch_apply(10, queue, ^(size_t i) {
            const char *queueName = dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL);
            NSLog(@"async task %zu in thread [%ld], in queue [%s]", i, (long)[[NSThread currentThread] sequenceNumber], queueName);
        });
    });
    
    NSLog(@"The end");
}

# pragma mark - dispatch_group_async
/*
 * dispatch_group_t 是一个初始value=0的信号量，每添加一个任务信号量+1，完成一个任务信号量-1
 * dispatch_wait() 和 dispatch_group_notify() 都会在dispatch_group_t重新变为0时被调用
 * dispatch_wait() 会阻塞线程
 * dispatch_group_notify() 不会阻塞线程
 */
- (void)dispatchGroupWaitBiting {
    
    dispatch_queue_t queue = dispatch_queue_create("com.hs.concurrentQueue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_group_async(group, queue, ^{
        sleep(3);
        const char *queueName = dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL);
        NSLog(@"group async task1 in thread [%ld], in queue [%s]", (long)[[NSThread currentThread] sequenceNumber], queueName);
    });
    
    dispatch_group_async(group, queue, ^{
        const char *queueName = dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL);
        NSLog(@"group async task2 in thread [%ld], in queue [%s]", (long)[[NSThread currentThread] sequenceNumber], queueName);
    });
    
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    NSLog(@"group async tasks done");
    
}

- (void)dispatchGroupNotifyBiting {
    
    dispatch_queue_t queue = dispatch_queue_create("com.hs.concurrentQueue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_group_async(group, queue, ^{
        sleep(3);
        const char *queueName = dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL);
        NSLog(@"group async task1 in thread [%ld], in queue [%s]", (long)[[NSThread currentThread] sequenceNumber], queueName);
    });
    
    dispatch_group_async(group, queue, ^{
        const char *queueName = dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL);
        NSLog(@"group async task2 in thread [%ld], in queue [%s]", (long)[[NSThread currentThread] sequenceNumber], queueName);
    });
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        const char *queueName = dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL);
        NSLog(@"group async tasks done in thread [%ld], in queue [%s]", (long)[[NSThread currentThread] sequenceNumber], queueName);
    });
    
    NSLog(@"不阻塞");
    
}

# pragma mark - deadlock
- (void)deadLockBiting {
    /*
     * 在main queue dispatch_sync()为什么会死锁？
     * 死锁的本质在于队列阻塞，而不是线程阻塞
     * 下面的代码，一共两个队列，主队列和一个串行队列，主队列的任务是dispatch_sync(queue, block)，它会等待block完成后返回，串行队列的任务就是block，所以顺序是串行队列完成block任务，然后dispatch_sync()返回，主队列完成任务
     */
    dispatch_queue_t queue = dispatch_queue_create("com.hs.serialQueue", DISPATCH_QUEUE_SERIAL);
    
    dispatch_sync(queue, ^{
        const char *queueName = dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL);
        NSLog(@"sync task1 in thread [%ld], in queue [%s]", (long)[[NSThread currentThread] sequenceNumber], queueName);
    });
    
    /*
     * 下面这段代码就会死锁
     * 一种只有一个主队列
     * 主队列的任务1：dispatch_sync(dispatch_get_main_queue(), block), 它会等待block完成后返回了完成
     * 主队列的任务2：block, 由于FIFO的原则，block得等待任务1完成，而任务1得等待block完成后返回了才完成，两者互相等待造成死锁
     */
    dispatch_sync(dispatch_get_main_queue(), ^{
        const char *queueName = dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL);
        NSLog(@"sync task1 in thread [%ld], in queue [%s]", (long)[[NSThread currentThread] sequenceNumber], queueName);
    });
    

}

# pragma mark - dispatch_source
- (void)dispatchSourceTimerBiting {

    __block int count = 1;
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(0, 0));
    /*
     * @param1 dispatch_source_t
     * @param2 开始时间
     * @param3 循环间隔
     * @param4 允许误差
     */
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC, 0); // 每隔1秒触发timer，允许误差0秒
    dispatch_source_set_event_handler(timer, ^{
        const char *queueName = dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL);
        NSLog(@"timing task %d in thread [%ld], in queue [%s]", count, (long)[[NSThread currentThread] sequenceNumber], queueName);
        if (count < 10) {
            count += 1;
        } else {
            // 触发cancel_handler
            dispatch_source_cancel(timer);
        }
    });
    /*
     * 关闭dispatch_source，设置的event_handler不会被执行，已经执行的event_handler不会被取消
     */
    dispatch_source_set_cancel_handler(timer, ^{
        const char *queueName = dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL);
        NSLog(@"cancel timing tasks in thread [%ld], in queue [%s]", (long)[[NSThread currentThread] sequenceNumber], queueName);
        
    });
    dispatch_resume(timer);
    self.timer = timer;
}

- (void)dispatchSourceCustomBiting {
    __block int process = 0;
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    dispatch_queue_t globalQueue = dispatch_get_global_queue(0, 0);
    dispatch_source_t customSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_DATA_ADD, 0, 0, mainQueue);
    dispatch_source_set_event_handler(customSource, ^{
        NSUInteger value = dispatch_source_get_data(customSource);
        process += value;
        NSLog(@"process：%@", @((CGFloat)process/100));
        if (process/100 == 1) {
            dispatch_source_cancel(customSource);
        }
    });
    dispatch_source_set_cancel_handler(customSource, ^{
        const char *queueName = dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL);
        NSLog(@"process totally completed in thread [%ld], in queue [%s]", (long)[[NSThread currentThread] sequenceNumber], queueName);
    });
    dispatch_resume(customSource);
    
    dispatch_async(globalQueue, ^{
        dispatch_apply(100, globalQueue, ^(size_t index) {
            usleep(20000); //0.02秒
            //向分派源发送事件，需要注意的是，不可以传递0值(事件不会被触发)，同样也不可以传递负数。
            dispatch_source_merge_data(customSource, 1);
        });
    });
    self.customSource = customSource;
}

# pragma mark - dispatch_once
- (void)dispatchOnceBiting {
    static dispatch_once_t onceToken;
    
    /*
     * 内部通过一个静态变量来标记block是否已经执行，同时使用信号量确保一次只有一个线程能执行，执行完block会唤醒其他所有等待的线程
     */
    dispatch_once(&onceToken, ^{
        /*
         * 这里的代码只会执行一次
         */
    });
}

# pragma mark - dispatch_block
- (void)dispatchBlockCreateBiting {
    dispatch_queue_t queue = dispatch_queue_create("com.hs.concurrentQueue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_block_t normalBlock = dispatch_block_create(0, ^{
        const char *queueName = dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL);
        NSLog(@"async normal block in thread %ld, in queue [%s]", (long)[[NSThread currentThread] sequenceNumber], queueName);
    });
    dispatch_async(queue, normalBlock);
    
    dispatch_block_t qosBlock = dispatch_block_create_with_qos_class(0, QOS_CLASS_USER_INITIATED, -1, ^{
        const char *queueName = dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL);
        NSLog(@"async qos block in thread %ld, in queue [%s]", (long)[[NSThread currentThread] sequenceNumber], queueName);
    });
    
    dispatch_async(queue, qosBlock);
}

- (void)dispatchBlockWaitBiting {
    dispatch_queue_t queue = dispatch_queue_create("com.hs.concurrentQueue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_block_t block1 = dispatch_block_create(0, ^{
        const char *queueName = dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL);
        NSLog(@"async block1 begin in thread %ld, in queue [%s]", (long)[[NSThread currentThread] sequenceNumber], queueName);
        sleep(3);
        NSLog(@"async block1 done in thread %ld, in queue [%s]", (long)[[NSThread currentThread] sequenceNumber], queueName);
    });
    dispatch_async(queue, block1);
    
    /*
     * 方法不会立刻返回，会阻塞线程，等待block完成或者超时返回
     */
    dispatch_block_wait(block1, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)));
    
    NSLog(@"after waiting block");
}

- (void)dispatchBlockNotifyBiting {
    dispatch_queue_t queue = dispatch_queue_create("com.hs.concurrentQueue", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_block_t block1 = dispatch_block_create(0, ^{
        const char *queueName = dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL);
        NSLog(@"async block1 begin in thread %ld, in queue [%s]", (long)[[NSThread currentThread] sequenceNumber], queueName);
        sleep(3);
        NSLog(@"async block1 done in thread %ld, in queue [%s]", (long)[[NSThread currentThread] sequenceNumber], queueName);
    });
    
    dispatch_block_t block2 = dispatch_block_create(0, ^{
        const char *queueName = dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL);
        NSLog(@"async block2 in thread %ld, in queue [%s]", (long)[[NSThread currentThread] sequenceNumber], queueName);
    });
    
    dispatch_async(queue, block1);
    /*
     * block2 需要等待 block1 结束
     * 方法会立刻返回，不会阻塞
     */
    dispatch_block_notify(block1, queue, block2);
}

- (void)dispatchBlockCancellBiting {
    dispatch_queue_t queue = dispatch_queue_create("com.hs.concurrentQueue", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_block_t block1 = dispatch_block_create(0, ^{
        const char *queueName = dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL);
        NSLog(@"async block1 begin in thread %ld, in queue [%s]", (long)[[NSThread currentThread] sequenceNumber], queueName);
        sleep(3);
        NSLog(@"async block1 done in thread %ld, in queue [%s]", (long)[[NSThread currentThread] sequenceNumber], queueName);
    });
    
    dispatch_block_t block2 = dispatch_block_create(0, ^{
        const char *queueName = dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL);
        NSLog(@"async block2 in thread %ld, in queue [%s]", (long)[[NSThread currentThread] sequenceNumber], queueName);
    });
    
    dispatch_async(queue, block1);
    dispatch_async(queue, block2);
    
    sleep(1);
    
    /*
     * 可以取消还在队列中暂未执行的block
     */
    dispatch_block_cancel(block1);

}

# pragma mark - dispatch_semaphore
- (void)dispatchSemaphoreBiting {
    /*
     * 控制并发量
     * 初始化X的信号量，则最多允许X个线程并行
     * X = 1时，可以当做互斥锁
     */
    dispatch_semaphore_t sema = dispatch_semaphore_create(3);
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        dispatch_apply(100, dispatch_get_global_queue(0, 0), ^(size_t index) {
            /*
             * 观察控制台输出，一次只有三个线程同时执行
             */
            dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
            sleep(1);
            const char *queueName = dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL);
            NSLog(@"async task %zu begin in thread %ld, in queue [%s]", index, (long)[[NSThread currentThread] sequenceNumber], queueName);
            dispatch_semaphore_signal(sema);
        });
    });
    
}

# pragma mark - GCD & Runloop
/*
 * 一旦添加了Runloop observer,就会收到runloop状态各种通知产生干扰
 * 为了观察当前runloop通知是否由dispatch_async导致
 * 利用dispatch_after的特性，延迟10秒提交block
 * 可以清楚的看到dispatch_async到mainQueue，libdispatch会发消息给主线程runloop唤醒主线程runloop，然后runloop从消息中拿出block执行
 */
- (void)asyncInMainQueueWakeupTheRunnloop {
    [self configRunloopObserver];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        const char *queueName = dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL);
        NSLog(@"async task 1 in thread %ld, in queue [%s]", (long)[[NSThread currentThread] sequenceNumber], queueName);
        dispatch_async(dispatch_get_main_queue(), ^{
            const char *queueName = dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL);
            NSLog(@"async task 2 in thread %ld, in queue [%s]", (long)[[NSThread currentThread] sequenceNumber], queueName);
        });
    });
}

# pragma mark - dispatch specific
- (void)dispatchSepcificBiting {
    
    NSString *context = @"specificContext";
    
    dispatch_queue_t queue = dispatch_queue_create(kDispatchQueueSpecificKey, DISPATCH_QUEUE_SERIAL);
    dispatch_queue_set_specific(queue, kDispatchQueueSpecificKey, (__bridge void*)context, NULL);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *context = (__bridge id)dispatch_get_specific(kDispatchQueueSpecificKey);
        const char *queueName = dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL);
        NSLog(@"async task in thread %ld, in queue [%s], in context [%@]", (long)[[NSThread currentThread] sequenceNumber], queueName, context);
    });
    
    dispatch_async(queue, ^{
        NSString *context = (__bridge id)dispatch_get_specific(kDispatchQueueSpecificKey);
        const char *queueName = dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL);
        NSLog(@"async task in thread %ld, in queue [%s], in context [%@]", (long)[[NSThread currentThread] sequenceNumber], queueName, context);
    });
    
    NSLog(@"hello");
}

@end
