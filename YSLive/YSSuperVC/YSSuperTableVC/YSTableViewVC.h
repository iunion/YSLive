//
//  YSTableViewVC.h
//  YSAll
//
//  Created by jiang deng on 2020/2/5.
//  Copyright © 2020 YS. All rights reserved.
//

#import "YSSuperNetVC.h"
#import "YSTableView.h"

NS_ASSUME_NONNULL_BEGIN

@interface YSTableViewVC : YSSuperNetVC
<
    UITableViewDelegate,
    UITableViewDataSource,
    YSTableViewDelegate
>
{
    // 当前页
    NSUInteger s_LoadedPage;
    // 备份当前页，用于发请求
    NSUInteger s_BakLoadedPage;
    // 总页数
    NSUInteger s_TotalPage;
    // 读取完全
    BOOL s_IsNoMorePage;
}

// 每页项数/每次读取个数，默认: 20
@property (nonatomic, assign) NSUInteger countPerPage;

// 用于初始化
@property (nonatomic, assign) UITableViewStyle tableViewStyle;

// 上拉下拉类型
@property (nonatomic, assign, readonly) BMFreshViewType freshViewType;

// 加载数据模式：按页加载/按个数
@property (nonatomic, assign) YSAPILoadDataType loadDataType;

@property (nonatomic, strong, readonly) YSTableView *tableView;

// 内容数据
@property (nullable, nonatomic, strong, readonly) NSMutableArray *dataArray;

// 是否刷新数据
@property (nonatomic, assign, readonly) BOOL isLoadNew;
// 显示空数据页
@property (nonatomic, assign) BOOL showEmptyView;
// 网络请求
@property (nullable, nonatomic, strong) NSURLSessionDataTask *dataTask;

- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil freshViewType:(BMFreshViewType)freshViewType;

- (void)setFreshTitles:(nullable NSDictionary *)titles;
- (void)setHeaderFreshTitles:(nullable NSDictionary *)titles;
- (void)setFooterFreshTitles:(nullable NSDictionary *)titles;

- (void)showEmptyViewWithType:(BMEmptyViewType)type;
- (void)showEmptyViewWithType:(BMEmptyViewType)type action:(BMEmptyViewActionBlock)actionBlock;
- (void)showEmptyViewWithType:(BMEmptyViewType)type customImageName:(nullable NSString *)customImageName customMessage:(nullable NSString *)customMessage customView:(nullable UIView *)customView;
- (void)showEmptyViewWithType:(BMEmptyViewType)type customImageName:(nullable NSString *)customImageName customMessage:(nullable NSString *)customMessage customView:(nullable UIView *)customView action:(BMEmptyViewActionBlock)actionBlock;
- (void)setEmptyViewActionBlock:(BMEmptyViewActionBlock)actionBlock;

- (void)hideEmptyView;

// 获取api成功时无数据类型
- (BMEmptyViewType)getNoDataEmptyViewType;
- (nullable NSString *)getNoDataEmptyViewCustomImageName;
- (nullable NSString *)getNoDataEmptyViewCustomMessage;
- (nullable UIView *)getNoDataEmptyViewCustomView;

@end

NS_ASSUME_NONNULL_END
