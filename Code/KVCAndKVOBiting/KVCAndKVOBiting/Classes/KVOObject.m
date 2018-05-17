//
//  KVOObject.m
//  KVCAndKVOBiting
//
//  Created by Hisen on 09/03/2018.
//  Copyright © 2018 Hisen. All rights reserved.
//

#import "KVOObject.h"

@implementation KVOObject

/*
 * 自动KVO or 手动KVO
 * 默认返回YES, 表示自动发送通知
 * 可以自定义某些key返回NO
 * 同时手动重写该key对应属性的setter方法，手动调用willChangeValueForKey:和didChangeValueForKey:实现手动KVO
 */
+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key {
    if ([key isEqualToString:@"manualKVOProp"]) {
        return NO;
    } else {
        return [super automaticallyNotifiesObserversForKey:key];
    }
}

- (void)setManualKVOProp:(NSString *)manualKVOProp {
    if (_manualKVOProp == manualKVOProp) {
        return;
    }
    [self willChangeValueForKey:@"manualKVOProp"];
    _manualKVOProp = manualKVOProp;
    [self didChangeValueForKey:@"manualKVOProp"];
}


/*
 * 计算属性(注册依赖)
 */
- (NSString *)computedProp {
    return [NSString stringWithFormat:@"_strProp: %@, _intProp: %ld", _strProp, (long)_intProp];
}

// 注册依赖建的方法1
//+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
//
//    NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
//
//    if ([key isEqualToString:@"computedProp"]) {
//        keyPaths = [keyPaths setByAddingObjectsFromArray:@[@"strProp", @"intProp"]];
//    }
//
//    return keyPaths;
//}

// 注册依赖建的方法2
+ (NSSet *)keyPathsForValuesAffectingComputedProp {
    return [NSSet setWithArray:@[@"strProp", @"intProp"]];
}

// 可变数组与KVO - 集合代理对象
//- (NSUInteger)countOfMutableArrProp {
//    return [_mutableArrProp count];
//}
//
//- (id)objectInMutableArrPropAtIndex:(NSUInteger)index {
//    return [_mutableArrProp objectAtIndex:index];
//}
//
//- (void)insertObject:(id)object inMutableArrPropAtIndex:(NSUInteger)index {
//    [_mutableArrProp insertObject:object atIndex:index];
//}
//
//- (void)removeObjectFromMutableArrPropAtIndex:(NSUInteger)index {
//    [_mutableArrProp removeObjectAtIndex:index];
//}

@end
