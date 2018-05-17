//
//  OperationObject.m
//  NSOperationBiting
//
//  Created by Hisen on 07/04/2018.
//  Copyright © 2018 Hisen. All rights reserved.
//

#import "OperationObject.h"
#import "NSThread+SequenceNumber.h"

@implementation OperationObject

- (NSInvocationOperation *)invocationOperationWithData:(id)data andIndex:(NSInteger)index {
    NSInvocationOperation *invocationOperation = [self invocationOperationWithData:data];
    
    if (index == 2) {
        invocationOperation.invocation.selector = @selector(operation2:);
    }
    
    return invocationOperation;
}

- (NSInvocationOperation *)invocationOperationWithData:(id)data {
    return [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(operation1:) object:data];
}

- (void)operation1:(id)data {
    NSLog(@"Start Invocation Operation1 [%@] with data: [%@] in thread [%ld]", NSStringFromSelector(_cmd), data, (long)[[NSThread currentThread] sequenceNumber]);
    sleep(3);
    NSLog(@"Finish Invocation Operation1 [%@] in thread [%ld]", NSStringFromSelector(_cmd), (long)[[NSThread currentThread] sequenceNumber]);
}

- (void)operation2:(id)data {
    NSLog(@"Start Invocation Operation2 [%@] with data: [%@] in thread [%ld]", NSStringFromSelector(_cmd), data, (long)[[NSThread currentThread] sequenceNumber]);
    sleep(3);
    NSLog(@"Finish Invocation Operation2 [%@] in thread [%ld]", NSStringFromSelector(_cmd), (long)[[NSThread currentThread] sequenceNumber]);
}

@end
