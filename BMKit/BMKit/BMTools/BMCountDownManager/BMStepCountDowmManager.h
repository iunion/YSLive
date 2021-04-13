//
//  BMStepCountDowmManager.h
//  BMKit
//
//  Created by jiang deng on 2021/4/12.
//  Copyright © 2021 DennisDeng. All rights reserved.
//

#import <Foundation/Foundation.h>

#define BMStepCountDown_DefaultStepMultiplier   (1000)
#define BMStepCountDown_DefaultCount            (60)

#define BMStepCountDownTime_Milliseconds        (1)
#define BMStepCountDownTime_10Milliseconds      (10)
#define BMStepCountDownTime_100Milliseconds     (100)
#define BMStepCountDownTime_1000Milliseconds    (1000)

typedef NS_ENUM(NSUInteger, BMStepCountDowmTimeMillisecondsType)
{
    BMStepCountDowmTimeMillisecondsType_1,
    BMStepCountDowmTimeMillisecondsType_10,
    BMStepCountDowmTimeMillisecondsType_100,
    BMStepCountDowmTimeMillisecondsType_1000,
};

NS_ASSUME_NONNULL_BEGIN

//typedef void(^BMStepCountDownProcessBlock)(id identifier, NSUInteger stepMultiplier, NSUInteger count, NSUInteger remainderCount, BOOL reStart, BOOL forcedStop);
typedef void(^BMStepCountDownProcessBlock)(id identifier, NSUInteger remainderCount, BOOL reStart, BOOL forcedStop);

/// 默认每毫秒计数一次
@interface BMStepCountDowmManager : NSObject

/// 初始化单例
/// @param milliseconds 计数间隔设置(毫秒)
+ (instancetype)shareManagerWithMilliseconds:(NSUInteger)milliseconds;

/// 变更计数间隔，如果有正在计数的项目不能修改
- (BOOL)changeTimeInterval:(NSUInteger)milliseconds;

- (void)startCountDownWithIdentifier:(id)identifier processBlock:(BMStepCountDownProcessBlock)processBlock;
- (void)startCountDownWithIdentifier:(id)identifier stepMultiplier:(NSUInteger)stepMultiplier processBlock:(BMStepCountDownProcessBlock)processBlock;
- (void)startCountDownWithIdentifier:(id)identifier stepMultiplier:(NSUInteger)stepMultiplier count:(NSUInteger)count processBlock:(BMStepCountDownProcessBlock)processBlock;

/// 开始倒计数
/// @param identifier 唯一标识
/// @param stepMultiplier 计次间隔
/// @param count 计次次数
/// @param autoRestart 是否重新启动计数
/// @param processBlock 计数回调
- (void)startCountDownWithIdentifier:(id)identifier stepMultiplier:(NSUInteger)stepMultiplier count:(NSUInteger)count autoRestart:(BOOL)autoRestart processBlock:(BMStepCountDownProcessBlock)processBlock;

/// 获取计数单位乘数
- (NSUInteger)stepMultiplierWithIdentifier:(id)identifier;
/// 获取原始倒计时
- (NSUInteger)countWithIdentifier:(id)identifier;
/// 获取剩余倒计时
- (NSUInteger)remainderCountWithIdentifier:(id)identifier;

/// 是否正在倒计时
- (BOOL)isCountingWithIdentifier:(id)identifier;
/// 是否暂停倒计时
- (BOOL)isPauseWithIdentifier:(id)identifier;
 
/// 设置变更响应事件，如果有变更将调用旧的响应事件(强制停止)
- (void)setProcessBlock:(BMStepCountDownProcessBlock)processBlock withIdentifier:(id)identifier;

/// 暂停倒计时
- (void)pauseCountDownIdentifier:(id)identifier;
/// 继续倒计时
- (void)continueCountDownIdentifier:(id)identifier;

/// 停止倒计时
- (void)stopCountDownIdentifier:(id)identifier;

/// 停止所有倒计时，并调用 processBlock 响应事件
- (void)stopAllCountDown;
/// 停止所有倒计时，不调用 processBlock 响应事件
- (void)stopAllCountDownDoNothing;

@end


NS_ASSUME_NONNULL_END
