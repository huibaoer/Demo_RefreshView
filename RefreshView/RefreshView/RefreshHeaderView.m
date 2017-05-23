//
//  RefreshView.m
//  RefreshView
//
//  Created by zhanght on 16/5/19.
//  Copyright © 2016年 zhanght. All rights reserved.
//

#import "RefreshHeaderView.h"

typedef NS_ENUM(NSUInteger, RefreshHeaderViewState) {
    RefreshHeaderViewStateNormal,
    RefreshHeaderViewStateWillRefresh,
    RefreshHeaderViewStateRefreshing,
};

static NSString *   const kRefreshViewObservingkeyPath  = @"contentOffset";
static CGFloat      const kRefreshViewHeight            = 500.0f;
static CGFloat      const kRefreshContentOffsetDelta    = 80.0f;

@interface RefreshHeaderView ()
@property (nonatomic, copy) RefreshHeaderHandler handler;
@property (nonatomic, assign) RefreshHeaderViewState refreshState;
@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, assign) UIEdgeInsets originalContentInsets;
@property (nonatomic, assign) UIEdgeInsets refreshingContentInsets;

@property (nonatomic, strong) UILabel *label;
@end

@implementation RefreshHeaderView

#pragma mark - lazy loading
- (UIEdgeInsets)refreshingContentInsets {
    UIEdgeInsets insets =
    UIEdgeInsetsMake(self.originalContentInsets.top + kRefreshContentOffsetDelta, self.originalContentInsets.left, self.originalContentInsets.bottom, self.originalContentInsets.right);
    return insets;
}

#pragma mark - life cycle
- (void)dealloc {
    [_scrollView removeObserver:self forKeyPath:kRefreshViewObservingkeyPath];
}

- (instancetype)initWithScrollView:(UIScrollView *)scrollView handler:(RefreshHeaderHandler)handler {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.backgroundColor = [UIColor redColor];
        self.handler = handler;
        
        //scrollView
        _scrollView = scrollView;
        [_scrollView addSubview:self];
        [_scrollView addObserver:self forKeyPath:kRefreshViewObservingkeyPath options:NSKeyValueObservingOptionNew context:nil];
        
        //label
        _label = [[UILabel alloc] init];
        _label.textAlignment = NSTextAlignmentCenter;
        _label.text = @"下拉刷新...";
        [self addSubview:_label];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    static BOOL hasSet = NO;
    if (!hasSet) {
        self.originalContentInsets = self.scrollView.contentInset;
        hasSet = YES;
    }
    
    //scrollView
    self.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *lcWidth = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:_scrollView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0];
    NSLayoutConstraint *lcHeight = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:kRefreshViewHeight];
    NSLayoutConstraint *lcCenterX = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_scrollView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
    NSLayoutConstraint *lcBottom = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_scrollView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    [_scrollView addConstraints:@[lcWidth, lcHeight, lcCenterX, lcBottom]];
    
    //label
    _label.translatesAutoresizingMaskIntoConstraints = NO;
    lcCenterX = [NSLayoutConstraint constraintWithItem:_label attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
    lcBottom = [NSLayoutConstraint constraintWithItem:_label attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-15];
    [self addConstraints:@[lcCenterX, lcBottom]];
}

- (void)setRefreshState:(RefreshHeaderViewState)refreshState {
    _refreshState = refreshState;
    switch (_refreshState) {
        case RefreshHeaderViewStateRefreshing: {
            [UIView animateWithDuration:0.1 animations:^{
                self.scrollView.contentInset = self.refreshingContentInsets;
            }];
            self.label.text = @"刷新中...";
            if (self.handler) {
                self.handler();
            }
            break;
        }
        case RefreshHeaderViewStateWillRefresh: {
            self.label.text = @"放开刷新...";
            break;
        }
        case RefreshHeaderViewStateNormal: {
            self.label.text = @"下拉刷新...";
            break;
        }
    }
}

- (void)startRefreshing {
    //模拟下拉
    [UIView animateWithDuration:0.2 animations:^{
        self.scrollView.contentOffset = CGPointMake(0, -kRefreshContentOffsetDelta-self.scrollView.contentInset.top);
    } completion:^(BOOL finished) {
        self.refreshState = RefreshHeaderViewStateRefreshing;
    }];
}

- (void)endRefreshing {
    [UIView animateWithDuration:0.2 animations:^{
        self.scrollView.contentInset = self.originalContentInsets;
    } completion:^(BOOL finished) {
        self.refreshState = RefreshHeaderViewStateNormal;
    }];
}


#pragma mark - observer
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if (![keyPath isEqualToString:kRefreshViewObservingkeyPath]) return;
    if (self.refreshState == RefreshHeaderViewStateRefreshing) return;
    float offsetY = [[change objectForKey:@"new"] CGPointValue].y;
    if ((offsetY > 0) || (self.scrollView.bounds.size.height == 0)) return;
    
    CGFloat detal = -kRefreshContentOffsetDelta - self.scrollView.contentInset.top;
    
    //触发 RefreshViewStateRefreshing
    if (offsetY <= detal && (self.refreshState == RefreshHeaderViewStateWillRefresh) && !self.scrollView.isDragging) {
        self.refreshState = RefreshHeaderViewStateRefreshing;
        return;
    }
    
    //触发 RefreshViewStateWillRefresh
    if (offsetY < detal && (self.refreshState == RefreshHeaderViewStateNormal)) {
        self.refreshState = RefreshHeaderViewStateWillRefresh;
        return;
    }
    
    //触发 RefreshViewStateNormal
    if (offsetY > detal && (self.refreshState != RefreshHeaderViewStateNormal) && self.scrollView.isDragging) {
        self.refreshState = RefreshHeaderViewStateNormal;
        return;
    }
}


@end
