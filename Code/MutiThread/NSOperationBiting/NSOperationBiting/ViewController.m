//
//  ViewController.m
//  NSOperationBiting
//
//  Created by Hisen on 07/04/2018.
//  Copyright © 2018 Hisen. All rights reserved.
//

#import "ViewController.h"
#import "OperationObject.h"
#import "NSThread+SequenceNumber.h"
#import "CustomOperation.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
//    [self mainQueueBiting];
//    [self customQueueBiting];
//    [self invocationOperationBiting];
//    [self blockOperationBiting];
//    [self customOperationBiting];
//    [self dependencyBiting];
//    [self priorityBiting];
//    [self waitUntilFinishedBiting];
    [self waitAllBiting];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma mark - mainQueue
- (void)mainQueueBiting {
    /*
     * 主队列运行在主线程上，是个串行队列，默认最大并发任务数=1
     */
    NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
    NSLog(@"%ld", (long)mainQueue.maxConcurrentOperationCount);

    
    /*
     * InvocationOperation
     */
    OperationObject *operationObj = [OperationObject new];
    NSInvocationOperation *invocationOperation = [operationObj invocationOperationWithData:@"hello world" andIndex:1];
    
    /*
     * BlockOperation
     */
    NSBlockOperation *blockOperation = [NSBlockOperation blockOperationWithBlock:^{
        const char *queueName = dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL);
        NSLog(@"Start execute block 1 in thread [%ld], in queue [%s]", (long)[[NSThread currentThread] sequenceNumber], queueName);
        sleep(2);
        NSLog(@"Finish block 1 in thread [%ld], in queue [%s]", (long)[[NSThread currentThread] sequenceNumber], queueName);
    }];
    
    /*
     * 主队列只有主线程一个线程，任务顺序执行
     */
    [mainQueue addOperation: invocationOperation];
    [mainQueue addOperation: blockOperation];
    
}

# pragma mark - customQueue
- (void)customQueueBiting {
    NSOperationQueue *customQueue = [NSOperationQueue new];
    NSLog(@"%ld", (long)customQueue.maxConcurrentOperationCount);
    
    /*
     * InvocationOperation
     */
    OperationObject *operationObj = [OperationObject new];
    NSInvocationOperation *invocationOperation = [operationObj invocationOperationWithData:@"hello world" andIndex:1];
    
    /*
     * BlockOperation
     */
    NSBlockOperation *blockOperation1 = [NSBlockOperation blockOperationWithBlock:^{
        const char *queueName = dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL);
        NSLog(@"Start execute block 1 in thread [%ld], in queue [%s]", (long)[[NSThread currentThread] sequenceNumber], queueName);
        sleep(2);
        NSLog(@"Finish block 1 in thread [%ld], in queue [%s]", (long)[[NSThread currentThread] sequenceNumber], queueName);
    }];
    
    NSBlockOperation *blockOperation2 = [NSBlockOperation blockOperationWithBlock:^{
        const char *queueName = dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL);
        NSLog(@"Start execute block 2 in thread [%ld], in queue [%s]", (long)[[NSThread currentThread] sequenceNumber], queueName);
        sleep(2);
        NSLog(@"Finish block 2 in thread [%ld], in queue [%s]", (long)[[NSThread currentThread] sequenceNumber], queueName);
    }];
    
    /*
     * 自定义operationQueue默认是并行的，会开多个线程并行执行
     */
    [customQueue addOperation: invocationOperation];
    [customQueue addOperation: blockOperation1];
    [customQueue addOperation: blockOperation2];
    
}

# pragma mark - operations
- (void)invocationOperationBiting {
    
    NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];

    OperationObject *operationObj = [OperationObject new];
    NSInvocationOperation *invocationOperation = [operationObj invocationOperationWithData:@"hello world" andIndex:1];
    
    [mainQueue addOperation: invocationOperation];
    
}

- (void)blockOperationBiting {
    NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
    
    NSBlockOperation *blockOperation = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"Start execute block 1 in thread %ld", (long)[[NSThread currentThread] sequenceNumber]);
        sleep(2);
        NSLog(@"Finish block 1 in thread %ld", (long)[[NSThread currentThread] sequenceNumber]);
    }];
    
    /*
     * addExecutionBlock的任务是并行的？？？
     */
    [blockOperation addExecutionBlock:^{
        NSLog(@"Start execute block 2 in thread %ld", (long)[[NSThread currentThread] sequenceNumber]);
        sleep(2);
        NSLog(@"Finish block 2 in thread %ld", (long)[[NSThread currentThread] sequenceNumber]);
    }];
    
    [blockOperation addExecutionBlock:^{
        NSLog(@"Start execute block 3 in thread %ld", (long)[[NSThread currentThread] sequenceNumber]);
        sleep(2);
        NSLog(@"Finish block 3 in thread %ld", (long)[[NSThread currentThread] sequenceNumber]);
    }];

    [mainQueue addOperation: blockOperation];
}

- (void)customOperationBiting {
    NSOperationQueue *queue = [NSOperationQueue new];

    CustomOperation *customOp = [CustomOperation new];
    /*
     * operation的finished状态被设置之后调用
     */
    customOp.completionBlock = ^(){
        NSLog(@"customOp completed");
    };
    
    /*
     * 加入queue中自动执行，并发队列自动创建新的线程执行
     */
    [queue addOperation:customOp];
    
    /*
     * 手动执行
     * 直接调用start还是会在当前线程执行，也就是主线程
     */
//    [customOp start];
//    [customOp asyncStart];
    
    /*
     * sleep(1) 在operation开始执行后去cancel它
     */
    sleep(1);
    [customOp cancel];
    
}

# pragma mark - custom execute performance
/*
 * operation的执行顺序取决于以下要素:
 * 1.isReady状态
 * 2.在队列中的优先级
 * 首先operation得是ready状态，operationQueue才会去根据其优先级决定哪个先执行
 */
- (void)dependencyBiting {
    NSOperationQueue *queue1 = [NSOperationQueue new];
    NSOperationQueue *queue2 = [NSOperationQueue new];


    NSBlockOperation *blockOperation1 = [NSBlockOperation blockOperationWithBlock:^{
        const char *queueName = dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL);
        NSLog(@"Start execute block 1 in thread [%ld], in queue [%s]", (long)[[NSThread currentThread] sequenceNumber], queueName);
        sleep(2);
        NSLog(@"Finish block 1 in thread [%ld], in queue [%s]", (long)[[NSThread currentThread] sequenceNumber], queueName);
    }];
    
    NSBlockOperation *blockOperation2 = [NSBlockOperation blockOperationWithBlock:^{
        const char *queueName = dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL);
        NSLog(@"Start execute block 2 in thread [%ld], in queue [%s]", (long)[[NSThread currentThread] sequenceNumber], queueName);
        sleep(2);
        NSLog(@"Finish block 2 in thread [%ld], in queue [%s]", (long)[[NSThread currentThread] sequenceNumber], queueName);
    }];
    
    /*
     * operation依赖添加的时机在加入operationQueue之前
     * 依赖关系与其添加到哪个operationQueue无关
     * 添加了依赖关系的operation的isReady状态取决于其依赖的operation，其依赖的operation结束是它会收到通知并修改为ready状态
     * blockOperation1 依赖于 blockOperation2，也就是blockOperation1需要等待blockOperation2完成后才开始
     */
    [blockOperation1 addDependency:blockOperation2];
    
    [queue1 addOperation:blockOperation1];
    [queue2 addOperation:blockOperation2];
    
}

- (void)priorityBiting {
    NSOperationQueue *queue = [NSOperationQueue new];
    
    /*
     * 默认优先级是normal的
     */
    NSBlockOperation *blockOperation1 = [NSBlockOperation blockOperationWithBlock:^{
        const char *queueName = dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL);
        NSLog(@"Start execute block 1 in thread [%ld], in queue [%s]", (long)[[NSThread currentThread] sequenceNumber], queueName);
        sleep(2);
        NSLog(@"Finish block 1 in thread [%ld], in queue [%s]", (long)[[NSThread currentThread] sequenceNumber], queueName);
    }];
    
    NSBlockOperation *blockOperation2 = [NSBlockOperation blockOperationWithBlock:^{
        const char *queueName = dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL);
        NSLog(@"Start execute block 2 in thread [%ld], in queue [%s]", (long)[[NSThread currentThread] sequenceNumber], queueName);
        sleep(2);
        NSLog(@"Finish block 2 in thread [%ld], in queue [%s]", (long)[[NSThread currentThread] sequenceNumber], queueName);
    }];
    
    /*
     * operation的优先级只应用于相同operationQueue中的operation
     */
    [blockOperation2 setQueuePriority: NSOperationQueuePriorityVeryHigh];
    
    [queue addOperation:blockOperation1];
    [queue addOperation:blockOperation2];
}

#pragma mark - APIs
- (void)waitUntilFinishedBiting {
    NSOperationQueue *queue = [NSOperationQueue new];
    
    NSBlockOperation *blockOperation1 = [NSBlockOperation blockOperationWithBlock:^{
        const char *queueName = dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL);
        NSLog(@"Start execute block 1 in thread [%ld], in queue [%s]", (long)[[NSThread currentThread] sequenceNumber], queueName);
        sleep(2);
        NSLog(@"Finish block 1 in thread [%ld], in queue [%s]", (long)[[NSThread currentThread] sequenceNumber], queueName);
    }];
    
    NSBlockOperation *blockOperation2 = [NSBlockOperation blockOperationWithBlock:^{
        const char *queueName = dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL);
        NSLog(@"Start execute block 2 in thread [%ld], in queue [%s]", (long)[[NSThread currentThread] sequenceNumber], queueName);
        sleep(2);
        NSLog(@"Finish block 2 in thread [%ld], in queue [%s]", (long)[[NSThread currentThread] sequenceNumber], queueName);
    }];
    
    /*
     * 添加一组operation
     * 通过第二个参数决定是否到阻塞线程，等待任务执行完成
     */
    [queue addOperations:@[blockOperation1, blockOperation2] waitUntilFinished:NO];
    
    NSLog(@"operations done");
}

- (void)waitAllBiting {
    NSOperationQueue *queue = [NSOperationQueue new];
    
    NSBlockOperation *blockOperation1 = [NSBlockOperation blockOperationWithBlock:^{
        const char *queueName = dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL);
        NSLog(@"Start execute block 1 in thread [%ld], in queue [%s]", (long)[[NSThread currentThread] sequenceNumber], queueName);
        sleep(2);
        NSLog(@"Finish block 1 in thread [%ld], in queue [%s]", (long)[[NSThread currentThread] sequenceNumber], queueName);
    }];
    
    NSBlockOperation *blockOperation2 = [NSBlockOperation blockOperationWithBlock:^{
        const char *queueName = dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL);
        NSLog(@"Start execute block 2 in thread [%ld], in queue [%s]", (long)[[NSThread currentThread] sequenceNumber], queueName);
        sleep(2);
        NSLog(@"Finish block 2 in thread [%ld], in queue [%s]", (long)[[NSThread currentThread] sequenceNumber], queueName);
    }];
    
    [queue addOperation: blockOperation1];
    [queue addOperation: blockOperation2];
    
    /*
     * 阻塞线程，等待所有operation执行完成
     */
    [queue waitUntilAllOperationsAreFinished];
    
    NSLog(@"all operations done");

}



@end
