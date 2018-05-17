//
//  OperationObject.h
//  NSOperationBiting
//
//  Created by Hisen on 07/04/2018.
//  Copyright © 2018 Hisen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OperationObject : NSObject

- (NSInvocationOperation *)invocationOperationWithData:(id)data andIndex:(NSInteger)index;

@end
