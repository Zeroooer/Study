//
//  UIScrollView+PullToRefresh.m
//  PullToRefresh
//
//  Created by Hisen on 11/03/2018.
//  Copyright © 2018 Hisen. All rights reserved.
//

#import "UIScrollView+PullToRefresh.h"
#import "RefreshView.h"

@implementation UIScrollView (PullToRefresh)

- (void)addRefreshingTarget:(id)target andAction:(SEL)action {
    RefreshView *refresh = [RefreshView new];
    [refresh setRefreshingTarget:target andAction:action];
    [self addSubview:refresh];
}

@end
