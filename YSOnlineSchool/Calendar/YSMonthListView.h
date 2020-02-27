//
//  YSMonthListView.h
//  YSLive
//
//  Created by 迁徙鸟 on 2020/2/26.
//  Copyright © 2020 YS. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YSMonthListView : UIView

@property (nonatomic,weak) UITableView *tabView;

///可切换的月份数组
@property(nonatomic,strong)NSMutableArray *dateArr;


@property(nonatomic,assign)CGFloat viewHeight;

///选中的月份
@property(nonatomic,copy,nullable)NSString *selectMonth;

@property(nonatomic,copy)void (^selectMonthCellClick)(NSString *dateStr,NSIndexPath *indexPath);

@end

NS_ASSUME_NONNULL_END
