//
//  OrderModel.m
//  JSONModel--comment
//
//  Created by Hisen on 15/03/2018.
//  Copyright © 2018 Hisen. All rights reserved.
//

#import "OrderModel.h"

@implementation ProductModel

+ (JSONKeyMapper *)keyMapper {
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{
                                                                  @"productId": @"id",
                                                                  @"name": @"productDetails.name",
                                                                  @"price": @"productDetails.price.rmb",
                                                                  @"productDate": @"productDetails.productDate"
                                                                  }];
}

+ (BOOL)propertyIsOptional:(NSString*)propertyName {
    return YES;
}

@end

@implementation OrderModel

+ (BOOL)propertyIsOptional:(NSString*)propertyName {
    return YES;
}

@end

@interface JSONValueTransformer(OrderModel)

@end

@implementation JSONValueTransformer(OrderModel)

- (NSDate *)NSDateFromNSString:(NSString *)dateStr {
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    // 设置日期格式 为了转换成功
    format.dateFormat = @"EEE-MMM-dd HH:mm:ss Z yyyy";
    NSDate *date = [format dateFromString:dateStr];
    return date;
}

@end
