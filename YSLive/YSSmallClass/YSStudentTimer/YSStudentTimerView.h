//
//  YSStudentTimerView.h
//  YSAll
//
//  Created by 宁杰英 on 2020/2/21.
//  Copyright © 2020 YS. All rights reserved.
//

#import <BMKit/BMKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger, YSStudentTimerViewType)
{
    /// 计时中
    YSStudentTimerViewType_Ing,
    /// 计时结束
    YSStudentTimerViewType_End,

};

@interface YSStudentTimerView : BMNoticeView

/// 是否背景蒙版可穿透点击
@property (nonatomic, assign) BOOL isPenetration;

- (void)showYSStudentTimerViewInView:(UIView *)inView
                backgroundEdgeInsets:(UIEdgeInsets)backgroundEdgeInsets
                         topDistance:(CGFloat)topDistance;
- (void)showTimeInterval:(NSInteger)timeInterval;
- (void)showResponderWithType:(YSStudentTimerViewType)timerType;
@end

NS_ASSUME_NONNULL_END
