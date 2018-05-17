//
//  KVCObject.h
//  KVCAndKVOBiting
//
//  Created by Hisen on 04/03/2018.
//  Copyright © 2018 Hisen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CustomObject.h"


@interface KVCObject : NSObject

@property (nonatomic, assign) NSInteger scalarProp;
@property (nonatomic, assign) CGRect structProp;
@property (nonatomic, copy) NSString *strProp;
@property (nonatomic, strong) CustomObject *customObjProp;
@property (nonatomic, strong) NSArray<CustomObject *> *arrProp;
@property (nonatomic, copy, readonly) NSString *readonlyProp;

@end
