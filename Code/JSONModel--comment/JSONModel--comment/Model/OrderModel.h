//
//  OrderModel.h
//  JSONModel--comment
//
//  Created by Hisen on 15/03/2018.
//  Copyright © 2018 Hisen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSONModel.h"

struct StructProp {
    CGFloat a;
    CGFloat b;
};
typedef struct StructProp StructProp;

@interface ProductModel : JSONModel

@property (nonatomic, assign) NSInteger productId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) float price;
@property (nonatomic, strong) NSDate *productDate;
@property (nonatomic, assign) BOOL isSale;
@property (nonatomic, assign) NSInteger count;

@end

@protocol ProductModel;

@interface OrderModel : JSONModel

@property (nonatomic, assign) NSInteger orderId;
@property (nonatomic, assign) float totalPrice;
@property (nonatomic, strong) NSArray<ProductModel> *products;

@end
