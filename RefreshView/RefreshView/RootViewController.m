//
//  RootViewController.m
//  RefreshView
//
//  Created by zhanght on 16/5/19.
//  Copyright © 2016年 zhanght. All rights reserved.
//

#import "RootViewController.h"
#import "RefreshHeaderView.h"
#import "RefreshFooterView.h"

@interface RootViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) NSMutableArray *array;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) RefreshHeaderView *refreshView;
@property (nonatomic, strong) RefreshFooterView *refreshFooterView;

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.array = [[NSMutableArray alloc] init];
    for (int i = 0; i < 30; i++) {
        [self.array addObject:@""];
    }
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"123"];
    
    __weak typeof(self) weakSelf = self;
    self.refreshView = [[RefreshHeaderView alloc] initWithScrollView:self.tableView  handler:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf.refreshView endRefreshing];
        });
    }];
    
    self.refreshFooterView = [[RefreshFooterView alloc] initWithTableView:self.tableView handler:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            for (int i = 0; i < 20; i++) {
                [weakSelf.array addObject:@""];
            }
            [weakSelf.tableView reloadData];
            
            if (weakSelf.array.count > 100) {
                [weakSelf.refreshFooterView endRefreshingWithState:RefreshEndStateComplete];
            } else {
                [weakSelf.refreshFooterView endRefreshingWithState:RefreshEndStateNormal];
            }
        });
    }];
    
    
    
    
}

#pragma mark - tableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"123" forIndexPath:indexPath];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%ld", indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    [self.refreshView startRefreshing];
}

@end
