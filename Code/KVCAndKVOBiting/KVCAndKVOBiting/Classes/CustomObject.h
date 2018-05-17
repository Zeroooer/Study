//
//  CustomObject.h
//  KVCAndKVOBiting
//
//  Created by Hisen on 04/03/2018.
//  Copyright © 2018 Hisen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CustomObject : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) NSInteger amount;

- (id)initWithName:(NSString *)name andAmount:(NSInteger)amount;


@end
