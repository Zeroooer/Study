//
//  Observer.m
//  KVCAndKVOBiting
//
//  Created by Hisen on 09/03/2018.
//  Copyright © 2018 Hisen. All rights reserved.
//

#import "Observer.h"

@implementation Observer

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    
    if ([change[NSKeyValueChangeNotificationIsPriorKey] boolValue]) {
        // 改变之前
        NSLog(@"---before change---");
        id oldValue = change[NSKeyValueChangeOldKey];
        NSLog(@"keyPath = %@, change = %@, context = %s, oldValue = %@", keyPath, change, (char *)context, oldValue);
    } else {
        // 改变之后
        NSLog(@"---after change---");
        id newValue = change[NSKeyValueChangeNewKey];
        NSLog(@"keyPath = %@, change = %@, context = %s, newValue = %@", keyPath, change, (char *)context, newValue);
    }
    
    

}

@end
