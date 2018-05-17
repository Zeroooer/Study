//
//  KVCObject.m
//  KVCAndKVOBiting
//
//  Created by Hisen on 04/03/2018.
//  Copyright © 2018 Hisen. All rights reserved.
//

#import "KVCObject.h"

@interface KVCObject ()

@property (nonatomic, copy, readwrite) NSString *readonlyProp;
@property (nonatomic, copy) NSString *privateProp;

@end

@implementation KVCObject

// 设置空值的处理
- (void)setNilValueForKey:(NSString *)key {
    NSLog(@"nil is illegal for key：[%@]", key);
    if ([key isEqualToString:@"scalarProp"]) {
        [self setValue:@0 forKey:key];
    } else {
        [super setNilValueForKey:key];
    }
}

// 传入错误key的处理
- (id)valueForUndefinedKey:(NSString *)key {
    NSLog(@"undefinedKey: %@", key);
    return nil;
}

-(void)setValue:(id)value forUndefinedKey:(NSString *)key{
    NSLog(@"undefinedKey: %@",key);
}

// KVV
- (BOOL)validateStrProp:(NSString **)value error:(out NSError * _Nullable __autoreleasing *)outError {
    NSString *strProp = *value;
    if ([strProp isEqualToString:@"illegal"]) {
        return NO;
    }
    return YES;
}

@end
