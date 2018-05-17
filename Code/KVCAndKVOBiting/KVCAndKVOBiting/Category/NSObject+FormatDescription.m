//
//  NSObject+FormatDescription.m
//  KVCAndKVOBiting
//
//  Created by Hisen on 01/03/2018.
//  Copyright © 2018 Hisen. All rights reserved.
//

#import "NSObject+FormatDescription.h"
#import "NSObject+Exchange.h"
#import <objc/runtime.h>

@implementation NSObject (FormatDescription)

+ (void)load {
    [self swizzleInstanceSelector:@selector(description) withSelector:@selector(fm_description)];
}

- (NSString *)fm_description {
    
    unsigned int numIvars;
    Ivar *vars = class_copyIvarList([self class], &numIvars);
    NSString *name = nil;
    NSString *type = nil;
    
    NSMutableDictionary *ivarDic = [NSMutableDictionary new];
    for(int i = 0; i < numIvars; i++) {
        Ivar thisIvar = vars[i];
        name = [NSString stringWithUTF8String:ivar_getName(thisIvar)];
        type = [NSString stringWithUTF8String:ivar_getTypeEncoding(thisIvar)];
        id value = [self valueForKey:name] ? [self valueForKey:name] : [NSNull null];
        if ([type hasPrefix:@"@"] && ![type isEqualToString:@"@\"NSNumber\""] && ![type isEqualToString:@"@\"NSString\""]) {
            [ivarDic setObject:[NSString stringWithFormat:@"<%@: %p>", [value class], value] forKey:name];
        } else {
            [ivarDic setObject:value forKey:name];
        }
    }
    
    free(vars);
    
    return [NSString stringWithFormat:@"<%@: %p, %@>", [self class], self, [ivarDic copy]];

}

@end
