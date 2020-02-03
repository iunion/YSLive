//
//  YSPrizeAlertView.h
//  YSLive
//
//  Created by fzxm on 2019/10/21.
//  Copyright © 2019 FS. All rights reserved.
//

#import <BMKit/BMNoticeView.h>

NS_ASSUME_NONNULL_BEGIN

@interface YSPrizeAlertView : BMNoticeView

@property (nonatomic, strong) NSArray <NSString *> *dataSource;

@property (nonatomic, strong) NSString *endTime;

/// show 弹窗
/// @param isResult YES-- 结果页  NO-- 抽奖中
+ (YSPrizeAlertView *)showPrizeWithStatus:(BOOL)isResult inView:(UIView *)inView backgroundEdgeInsets:(UIEdgeInsets)backgroundEdgeInsets topDistance:(CGFloat)topDistance;

@end



NS_ASSUME_NONNULL_END
