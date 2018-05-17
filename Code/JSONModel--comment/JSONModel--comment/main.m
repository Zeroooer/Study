//
//  main.m
//  JSONModel--comment
//
//  Created by Hisen on 15/03/2018.
//  Copyright © 2018 Hisen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "Model/OrderModel.h"

int main(int argc, char * argv[]) {
    @autoreleasepool {
//        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
                
        // get json data
        NSString *path = [[NSBundle mainBundle] pathForResource:@"order" ofType:@"json"];
        NSData *data = [NSData dataWithContentsOfFile:path];
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];

        NSError *error;
        OrderModel *order = [[OrderModel alloc] initWithDictionary:json error:&error];
        NSLog(@"order: %@", order);
        if (error) {
            NSLog(@"error: %@", error);
        }
        
//        NSString *str = nil;
//        NSScanner *scanner = [NSScanner scannerWithString:@"Hello world"];
//
//        BOOL b = [scanner scanUpToString:@"e" intoString:&str];
//        BOOL a = [scanner scanString:@"e" intoString:&str];
//        NSLog(@"%c, %c", a, b);
        
    }
}
