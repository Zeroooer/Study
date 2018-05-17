//
//  NSObject+Exchange.h
//  KVCAndKVOBiting
//
//  Created by Hisen on 01/03/2018.
//  Copyright © 2018 Hisen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Exchange)

+ (void)swizzleInstanceSelector:(SEL)originSel withSelector:(SEL)newSel;

@end
