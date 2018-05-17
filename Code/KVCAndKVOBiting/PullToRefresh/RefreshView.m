//
//  RefreshView.m
//  PullToRefresh
//
//  Created by Hisen on 11/03/2018.
//  Copyright © 2018 Hisen. All rights reserved.
//

#import "RefreshView.h"

@interface RefreshView()

@property (nonatomic, strong) UILabel *refreshLabel;

@end

@implementation RefreshView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)init {
    if (self == [super init]) {
        self.refreshState = PTRefreshStateIdle;
        
        self.refreshLabel = [UILabel new];
        self.refreshLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.refreshLabel.textAlignment = NSTextAlignmentCenter;
        self.refreshLabel.textColor = [UIColor blackColor];
        [self addSubview: self.refreshLabel];
        
        // 自动调整宽度，保证与superView左右边距不变
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    
    if (newSuperview && ![newSuperview isKindOfClass:[UIScrollView class]]) {
        return;
    }
    
    [self removeObservers];
    
    if (newSuperview) {
        self.frame = CGRectMake(newSuperview.frame.origin.x, newSuperview.frame.origin.y - REFRESHHEIGHT, newSuperview.frame.size.width, REFRESHHEIGHT);
        
        _scrollView = (UIScrollView *)newSuperview;
        // 设置永远支持垂直弹簧效果
        _scrollView.alwaysBounceVertical = YES;
        _scrollViewOriginalInset = _scrollView.adjustedContentInset;
        
        [self addObservers];
    }
}

- (void)dealloc {
    [self removeObservers];
}

#pragma mark - public
- (void)setRefreshingTarget:(id)target andAction:(SEL)action {
    _refreshingTarget = target;
    _refreshingAction = action;
}

- (void)endRefreshing {
    _refreshState = PTRefreshStateIdle;
}

- (void)beginRefreshing {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.refreshState = PTRefreshStateIdle;
    });
}

# pragma mark - private
- (void)addObservers {
    [self.scrollView addObserver:self
                      forKeyPath:@"contentOffset"
                         options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                         context:nil];
}

- (void)removeObservers {
    [self.scrollView removeObserver:self
                         forKeyPath:@"contentOffset"
                            context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"contentOffset"]) {
        [self scrollViewContentOffsetDidChange:change];
    }
}

- (void)scrollViewContentOffsetDidChange:(NSDictionary *)change {
    if (_refreshState == PTRefreshStateFreshing) {
        return;
    }
    
    _scrollViewOriginalInset = self.scrollView.adjustedContentInset;
    
    CGFloat offsetY = self.scrollView.contentOffset.y;
    CGFloat happenOffsetY = -self.scrollViewOriginalInset.top;

    
    // 如果是向上滚动到看不见头部控件，直接返回
    if (offsetY > happenOffsetY) return;
    
    // 普通 和 即将刷新 的临界点
    CGFloat criticalOffsetY = happenOffsetY - REFRESHHEIGHT;
    
    if (self.scrollView.isDragging) { // 如果正在拖拽
        if (self.refreshState == PTRefreshStateIdle && offsetY < criticalOffsetY) {
            // 转为即将刷新状态
            self.refreshState = PTRefreshStateReadyForRefresh;
        } else if (self.refreshState == PTRefreshStateReadyForRefresh && offsetY >= criticalOffsetY) {
            // 转为普通状态
            self.refreshState = PTRefreshStateIdle;
        }
    } else if (self.refreshState == PTRefreshStateReadyForRefresh) {// 即将刷新 && 手松开
        // 开始刷新
        self.refreshState = PTRefreshStateFreshing;
        [self beginRefreshing];
    }
}

- (void)setRefreshState:(PTRefreshState)refreshState {
    _refreshState = refreshState;
    switch (refreshState) {
        case PTRefreshStateIdle: {
            self.refreshLabel.text = @"idle";
            self.backgroundColor = [UIColor clearColor];
            if (!self.scrollView.isDragging) {
                [UIView animateWithDuration:0.3 animations:^{
                    self.scrollView.contentInset = UIEdgeInsetsMake(0, _scrollViewOriginalInset.left, _scrollViewOriginalInset.bottom, _scrollViewOriginalInset.right);
                }];
            }
        }
            break;
        case PTRefreshStateReadyForRefresh: {
            self.refreshLabel.text = @"readyForRefresh";
            self.backgroundColor = [UIColor greenColor];
        }
            break;
        case PTRefreshStateFreshing: {
            self.refreshLabel.text = @"refreshing";
            self.backgroundColor = [UIColor redColor];
            [UIView animateWithDuration:0.3 animations:^{
                self.scrollView.contentInset = UIEdgeInsetsMake(REFRESHHEIGHT, _scrollViewOriginalInset.left, _scrollViewOriginalInset.bottom, _scrollViewOriginalInset.right);
            }];
        }
            break;
    }
}

@end
