//
//  RefreshFooterView.h
//  RefreshView
//
//  Created by zhanght on 16/5/19.
//  Copyright © 2016年 zhanght. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, RefreshEndState) {
    RefreshEndStateNormal,//!<结束刷新，还能继续加载更多
    RefreshEndStateComplete,//!<结束刷新，已经加载全部
};


typedef void(^RefreshFooterHandler)(void);

/**
 *  上拉加载更多
 */
@interface RefreshFooterView : UIView

/**
 *  初始化方法
 *
 *  @param tableView  需要上提加载更多的tableView
 *  @param handler    回调
 *
 *  @return
 */
- (instancetype)initWithTableView:(UITableView *)tableView handler:(RefreshFooterHandler)handler;

/**
 *  结束刷新状态，需要在handler回调中调用
 *
 *  @param state 结束刷新的状态
 */
- (void)endRefreshingWithState:(RefreshEndState)state;

@end
