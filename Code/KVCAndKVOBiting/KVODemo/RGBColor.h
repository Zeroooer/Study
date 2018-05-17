//
//  RGBColor.h
//  KVODemo
//
//  Created by Hisen on 10/03/2018.
//  Copyright © 2018 Hisen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface RGBColor : NSObject


@property (nonatomic, assign) double redComponent;
@property (nonatomic, assign) double greenComponent;
@property (nonatomic, assign) double blueComponent;

@property (nonatomic, strong, readonly) UIColor *color;

@end
