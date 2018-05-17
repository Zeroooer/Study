//
//  KVOObject.h
//  KVCAndKVOBiting
//
//  Created by Hisen on 09/03/2018.
//  Copyright © 2018 Hisen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KVOObject : NSObject

@property (nonatomic, assign) NSInteger intProp;
@property (nonatomic, copy) NSString *strProp;
@property (nonatomic, strong) NSMutableArray *mutableArrProp;

@property (nonatomic, copy) NSString *manualKVOProp;

@property (nonatomic, copy, readonly) NSString *computedProp;

@end
