//
//  YSEyeCareManager.h
//  YSAll
//
//  Created by jiang deng on 2019/12/25.
//  Copyright © 2019 YS. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^YSEyeCareManagerShowRemindBlock)(void);

@interface YSEyeCareManager : NSObject

/// 提醒事件
@property (nullable, nonatomic, copy) YSEyeCareManagerShowRemindBlock showRemindBlock;

+ (instancetype)shareInstance;

- (void)startRemindtime;
- (void)stopRemindtime;

- (BOOL)getEyeCareNeverRemind;
- (void)setEyeCareNeverRemind:(BOOL)neverRemind;

- (BOOL)getEyeCareModeStatus;
- (NSUInteger)getEyeCareModeRemindTime;
- (void)setEyeCareModeRemindTime:(NSUInteger)remindTime;

- (void)switchEyeCareWithWindowMode:(BOOL)on;
- (void)switchEyeCareMode:(BOOL)on;

- (void)freshWindowWithShowStatusBar:(BOOL)showStatusBar isRientationPortrait:(BOOL)isRientationPortrait;

/// 改变Window层模式蒙层颜色
- (void)changeSkinCoverColor:(UIColor *)color;

@end

NS_ASSUME_NONNULL_END
