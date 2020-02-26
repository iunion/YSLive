//
//  YSMonthsListTableView.h
//  YSLive
//
//  Created by 迁徙鸟 on 2020/2/26.
//  Copyright © 2020 YS. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YSMonthsListTableView : UITableView

///可切换的月份数组
@property(nonatomic,strong)NSMutableArray *dateArr;

@end

NS_ASSUME_NONNULL_END
