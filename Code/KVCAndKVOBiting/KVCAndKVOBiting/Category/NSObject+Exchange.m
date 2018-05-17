//
//  NSObject+Exchange.m
//  KVCAndKVOBiting
//
//  Created by Hisen on 01/03/2018.
//  Copyright © 2018 Hisen. All rights reserved.
//

#import "NSObject+Exchange.h"
#import <objc/runtime.h>

@implementation NSObject (Exchange)

+ (void)swizzleInstanceSelector:(SEL)originSel withSelector:(SEL)newSel {
    Method originMethod = class_getInstanceMethod(self, originSel);
    Method newMethod = class_getInstanceMethod(self, newSel);
    if (!originMethod || !newMethod) {
        return;
    }
    
    if (!originMethod) {
        class_addMethod(
                        self,
                        originSel,
                        class_getMethodImplementation(self, originSel),
                        method_getTypeEncoding(originMethod)
                        );
    }
    
    if (!newMethod) {
        class_addMethod(
                        self,
                        newSel,
                        class_getMethodImplementation(self, newSel),
                        method_getTypeEncoding(newMethod)
                        );
    }
    
    method_exchangeImplementations(class_getInstanceMethod(self, originSel),
                                   class_getInstanceMethod(self, newSel));
    
}

@end
