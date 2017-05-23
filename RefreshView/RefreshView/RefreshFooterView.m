//
//  RefreshFooterView.m
//  RefreshView
//
//  Created by zhanght on 16/5/19.
//  Copyright © 2016年 zhanght. All rights reserved.
//

#import "RefreshFooterView.h"

typedef NS_ENUM(NSUInteger, RefreshFooterViewState) {
    RefreshFooterViewStateNormal,
    RefreshFooterViewStateRefreshing,
    RefreshFooterViewStateComplete
};

static NSString *   const kRefreshViewObservingkeyPath  = @"contentOffset";
static CGFloat      const kRefreshViewHeight            = 30.0f;


@interface RefreshFooterView ()
@property (nonatomic, copy) RefreshFooterHandler handler;
@property (nonatomic, assign) RefreshFooterViewState refreshState;
@property (nonatomic, weak) UITableView *tableView;

@property (nonatomic, strong) UILabel *label;
@end

@implementation RefreshFooterView

- (instancetype)initWithTableView:(UITableView *)tableView handler:(RefreshFooterHandler)handler {
    self = [super initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, kRefreshViewHeight)];
    if (self) {
        self.backgroundColor = [UIColor redColor];
        self.handler = handler;
        
        //tableView
        _tableView = tableView;
        _tableView.tableFooterView = self;
        [_tableView addObserver:self forKeyPath:kRefreshViewObservingkeyPath options:NSKeyValueObservingOptionNew context:nil];
        
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
    //label
    _label.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *lcCenterX = [NSLayoutConstraint constraintWithItem:_label attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
    NSLayoutConstraint *lcBottom = [NSLayoutConstraint constraintWithItem:_label attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-5];
    [self addConstraints:@[lcCenterX, lcBottom]];
}

- (void)setRefreshState:(RefreshFooterViewState)refreshState {
    _refreshState = refreshState;
    
    switch (_refreshState) {
        case RefreshFooterViewStateRefreshing: {
            self.label.text = @"努力加载中...";
            if (self.handler) {
                self.handler();
            }
            break;
        }
        case RefreshFooterViewStateNormal: {
            self.label.text = @"上拉加载更多";
            break;
        }
        case RefreshFooterViewStateComplete: {
            self.label.text = @"已加载全部";
            break;
        }
    }
}

- (void)endRefreshingWithState:(RefreshEndState)state {
    if (state == RefreshEndStateNormal) {
        self.refreshState = RefreshFooterViewStateNormal;
    } else if (state == RefreshEndStateComplete) {
        self.refreshState = RefreshFooterViewStateComplete;
    }
}

#pragma mark - observer
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if (![keyPath isEqualToString:kRefreshViewObservingkeyPath]) return;
    if (self.refreshState != RefreshFooterViewStateNormal) return;
    CGFloat offsetY = [[change objectForKey:@"new"] CGPointValue].y;
    CGFloat bottomOffsetY = offsetY + self.tableView.bounds.size.height;
    if (bottomOffsetY < self.tableView.contentSize.height - kRefreshViewHeight) return;
    
    if (bottomOffsetY >= self.tableView.contentSize.height - kRefreshViewHeight) {
        self.refreshState = RefreshFooterViewStateRefreshing;
    }
}



@end
