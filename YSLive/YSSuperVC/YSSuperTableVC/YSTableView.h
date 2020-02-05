//
//  YSTableView.h
//  YSAll
//
//  Created by jiang deng on 2020/2/5.
//  Copyright © 2020 YS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BMKit/BMKit.h>
#import <BMKit/UIScrollView+BMEmpty.h>
#import <BMKit/UIScrollView+BMFresh.h>

NS_ASSUME_NONNULL_BEGIN

@protocol YSTableViewDelegate;

@interface YSTableView : UITableView

@property (nullable,nonatomic, weak) id <YSTableViewDelegate> tableViewDelegate;

// 上拉下拉类型
@property (nonatomic, assign, readonly) BMFreshViewType freshViewType;

// 允许同时识别多个手势，默认NO
@property (nonatomic, assign) BOOL multiResponse;

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style freshViewType:(BMFreshViewType)freshViewType;
- (void)bringSomeViewToFront;

@end

@protocol YSTableViewDelegate <NSObject>

- (void)freshDataWithTableView:(YSTableView *)tableView;

- (void)loadNextDataWithTableView:(YSTableView *)tableView;

@optional

- (void)resetTableViewFreshState:(BMFreshBaseView *)freshView;

- (void)tableViewFreshFromNoDataView:(YSTableView *)tableView;

@end

NS_ASSUME_NONNULL_END
