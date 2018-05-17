//
//  RefreshView.h
//  PullToRefresh
//
//  Created by Hisen on 11/03/2018.
//  Copyright © 2018 Hisen. All rights reserved.
//

#import <UIKit/UIKit.h>

/*
* 刷新控件的状态
*/
typedef NS_ENUM(NSUInteger, PTRefreshState) {
    PTRefreshStateIdle = 1,
    PTRefreshStateReadyForRefresh,
    PTRefreshStateFreshing
};

#define REFRESHHEIGHT 60

@interface RefreshView : UIView

@property (nonatomic, assign) PTRefreshState refreshState;
@property (weak, nonatomic, readonly) UIScrollView *scrollView;
@property (assign, nonatomic, readonly) UIEdgeInsets scrollViewOriginalInset;



/** 回调对象 */
@property (weak, nonatomic) id refreshingTarget;
/** 回调方法 */
@property (assign, nonatomic) SEL refreshingAction;

- (void)setRefreshingTarget:(id)target andAction:(SEL)action;
- (void)endRefreshing;


@end
