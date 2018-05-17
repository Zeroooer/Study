//
//  RGBColor.m
//  KVODemo
//
//  Created by Hisen on 10/03/2018.
//  Copyright © 2018 Hisen. All rights reserved.
//

#import "RGBColor.h"

@implementation RGBColor

- (id)init {
    if (self == [super init]) {
        _redComponent = 0.0;
        _greenComponent = 0.0;
        _blueComponent = 0.0;
    }
    return self;
}

- (UIColor *)color {
    return [UIColor colorWithRed:_redComponent green:_greenComponent blue:_blueComponent alpha:1.0];
}

+ (NSSet *)keyPathsForValuesAffectingColor {
    return [NSSet setWithObjects:@"redComponent", @"greenComponent", @"blueComponent", nil];
}

@end
