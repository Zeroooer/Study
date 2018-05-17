//
//  NSThread+SequenceNumber.m
//  Locks
//
//  Created by Hisen on 26/03/2018.
//  Copyright © 2018 Hisen. All rights reserved.
//

#import "NSThread+SequenceNumber.h"

@implementation NSThread (SequenceNumber)

- (NSInteger)sequenceNumber {
    return [[self valueForKeyPath:@"private.seqNum"] integerValue];
}


@end
