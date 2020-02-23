//
//  YSTeacherTimerView.h
//  YSAll
//
//  Created by 宁杰英 on 2020/2/20.
//  Copyright © 2020 YS. All rights reserved.
//

#import <BMKit/BMKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger, YSTeacherTimerViewType)
{
    /// 开始计时
    YSTeacherTimerViewType_Start,
    /// 计时中
    YSTeacherTimerViewType_Ing,
    /// 计时结束
    YSTeacherTimerViewType_End,

};

@protocol YSTeacherTimerViewDelegate <NSObject>

- (void)startWithTime:(NSInteger)time;
- (void)pasueWithTime:(NSInteger)time pasue:(BOOL)pasue;
- (void)resetWithTIme:(NSInteger)time pasue:(BOOL)pasue;
- (void)againTimer;
- (void)timerClose;
@end

@interface YSTeacherTimerView : BMNoticeView
@property(nonatomic,weak) id<YSTeacherTimerViewDelegate> delegate;

- (void)showYSTeacherTimerViewInView:(UIView *)inView
                backgroundEdgeInsets:(UIEdgeInsets)backgroundEdgeInsets
                         topDistance:(CGFloat)topDistance;
- (void)showResponderWithType:(YSTeacherTimerViewType)timerType;
- (void)showTimeInterval:(NSInteger)timeInterval;
@end

NS_ASSUME_NONNULL_END
