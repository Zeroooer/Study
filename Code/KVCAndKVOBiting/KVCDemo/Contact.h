//
//  Contact.h
//  KVCDemo
//
//  Created by Hisen on 10/03/2018.
//  Copyright © 2018 Hisen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Contact : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *nickName;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *city;

- (id)initWithName:(NSString *)name
       andNickName:(NSString *)nickName
          andEmail:(NSString *)email
           andCity:(NSString *)city;

+ (instancetype)contactWithRancomName;


@end
