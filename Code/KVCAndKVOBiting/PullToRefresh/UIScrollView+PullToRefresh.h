//
//  UIScrollView+PullToRefresh.h
//  PullToRefresh
//
//  Created by Hisen on 11/03/2018.
//  Copyright © 2018 Hisen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIScrollView (PullToRefresh)

- (void)addRefreshingTarget:(id)target andAction:(SEL)action;

@end
