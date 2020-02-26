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


///可切换的月份数组
@property(nonatomic,strong)NSMutableArray *dateArr;


@property(nonatomic,assign)CGFloat viewHeight;

@end

NS_ASSUME_NONNULL_END
