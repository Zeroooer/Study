//
//  CustomObject.m
//  KVCAndKVOBiting
//
//  Created by Hisen on 04/03/2018.
//  Copyright © 2018 Hisen. All rights reserved.
//

#import "CustomObject.h"

@implementation CustomObject

- (id)initWithName:(NSString *)name andAmount:(NSInteger)amount {
    if (self = [super init]) {
        _name = name;
        _amount = amount;
    }
    return self;
}

@end
