//
//  RefreshHeaderView.h
//  RefreshView
//
//  Created by zhanght on 16/5/19.
//  Copyright © 2016年 zhanght. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^RefreshHeaderHandler)(void);


/**
 *  下拉刷新
 */
@interface RefreshHeaderView : UIView

/**
 *  初始化方法
 *
 *  @param scrollView 需要添加下拉刷新的scrollView
 *  @param handler    回调
 *
 *  @return
 */
- (instancetype)initWithScrollView:(UIScrollView *)scrollView handler:(RefreshHeaderHandler)handler;

/**
 *  自动触发下拉刷新
 */
- (void)startRefreshing;

/**
 *  结束刷新，需要在handler回调中调用
 */
- (void)endRefreshing;


@end
