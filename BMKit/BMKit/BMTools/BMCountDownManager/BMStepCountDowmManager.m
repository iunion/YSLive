//
//  BMStepCountDowmManager.m
//  BMKit
//
//  Created by jiang deng on 2021/4/12.
//  Copyright © 2021 DennisDeng. All rights reserved.
//

#import "BMStepCountDowmManager.h"

@interface BMStepCountDownItem : NSObject

/// 计数单位乘数，即 1 * stepMultiplier 毫秒计数一次
@property (nonatomic, assign) NSUInteger stepMultiplier;
/// 真实计数次数
@property (nonatomic, assign) NSUInteger realCount;

/// 原始计数次数
@property (nonatomic, assign) NSUInteger count;
/// 剩余次数
@property (nonatomic, assign) NSUInteger remainderCount;

/// 是否自动重新计数
@property (nonatomic, assign) BOOL autoRestart;
/// 重新计数次数
@property (nonatomic, assign) NSUInteger restartCount;

/// 是否暂停
@property (nonatomic, assign) BOOL isPause;
/// 暂停时是否清空 realCount，默认: NO
@property (nonatomic, assign) BOOL isPauseReCount;

/// 每此计数触发响应事件
@property (nullable, nonatomic, copy) BMStepCountDownProcessBlock processBlock;

+ (instancetype)countDownItemWithStepMultiplier:(NSUInteger)stepMultiplier count:(NSUInteger)count processBlock:(BMStepCountDownProcessBlock)processBlock;
+ (instancetype)countDownItemWithStepMultiplier:(NSUInteger)stepMultiplier count:(NSUInteger)count autoRestart:(BOOL)autoRestart processBlock:(BMStepCountDownProcessBlock)processBlock;

- (instancetype)initWithStepMultiplier:(NSUInteger)stepMultiplier count:(NSUInteger)count processBlock:(BMStepCountDownProcessBlock)processBlock;
- (instancetype)initWithStepMultiplier:(NSUInteger)stepMultiplier count:(NSUInteger)count autoRestart:(BOOL)autoRestart processBlock:(BMStepCountDownProcessBlock)processBlock;

@end


#pragma mark - BMStepCountDowmManager

@interface BMStepCountDowmManager ()

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSUInteger milliseconds;

/// 倒计时项目存储 identifier : BMStepCountDownItem
@property (nonatomic, strong) NSMutableDictionary<id, BMStepCountDownItem *> *countDownDict;

@end

@implementation BMStepCountDowmManager

+ (instancetype)shareManagerWithMilliseconds:(NSUInteger)milliseconds
{
    static BMStepCountDowmManager *stepCountDownManager = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        stepCountDownManager = [[self alloc] init];
        if (milliseconds == 0)
        {
            stepCountDownManager.milliseconds = BMStepCountDownTime_1000Milliseconds;
        }
        else
        {
            stepCountDownManager.milliseconds = milliseconds;
        }
    });
    
    return stepCountDownManager;
}

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        _countDownDict = [[NSMutableDictionary alloc] init];
        _milliseconds = BMStepCountDownTime_1000Milliseconds;
    }
    
    return self;
}

- (BOOL)changeTimeInterval:(NSUInteger)milliseconds
{
    // 如果有正在运行的，不能更改计数间隔
    if ([self.countDownDict.allKeys bm_isNotEmpty])
    {
        return NO;
    }
    
    if (milliseconds == 0)
    {
        milliseconds = BMStepCountDownTime_1000Milliseconds;
    }

    self.milliseconds = milliseconds;
    
    return YES;
}

- (void)startCountDownWithIdentifier:(id)identifier processBlock:(BMStepCountDownProcessBlock)processBlock
{
    [self startCountDownWithIdentifier:identifier stepMultiplier:BMStepCountDown_DefaultStepMultiplier count:BMStepCountDown_DefaultCount processBlock:processBlock];
}

- (void)startCountDownWithIdentifier:(id)identifier stepMultiplier:(NSUInteger)stepMultiplier processBlock:(BMStepCountDownProcessBlock)processBlock
{
    [self startCountDownWithIdentifier:identifier stepMultiplier:stepMultiplier count:BMStepCountDown_DefaultCount processBlock:processBlock];
}

- (void)startCountDownWithIdentifier:(id)identifier stepMultiplier:(NSUInteger)stepMultiplier count:(NSUInteger)count processBlock:(BMStepCountDownProcessBlock)processBlock
{
    [self startCountDownWithIdentifier:identifier stepMultiplier:stepMultiplier count:count autoRestart:NO processBlock:processBlock];
}

- (void)startCountDownWithIdentifier:(id)identifier stepMultiplier:(NSUInteger)stepMultiplier count:(NSUInteger)count autoRestart:(BOOL)autoRestart processBlock:(BMStepCountDownProcessBlock)processBlock
{
    if (![identifier bm_isNotEmpty])
    {
        return;
    }
    
    // 倒计时时间判断
    if (count <= 0)
    {
        return;
    }
    
    BMStepCountDownItem *countDownItem = self.countDownDict[identifier];
    
    if (!countDownItem)
    {
        // 不存在标识的倒计时创建
        countDownItem = [BMStepCountDownItem countDownItemWithStepMultiplier:stepMultiplier count:count autoRestart:autoRestart processBlock:processBlock];
        self.countDownDict[identifier] = countDownItem;
        
        if (processBlock)
        {
            // 调用processBlock
            processBlock(identifier, countDownItem.remainderCount, NO, NO);
        }
    }
    else
    {
        BMStepCountDownProcessBlock oldProcessBlock = countDownItem.processBlock;
        if (oldProcessBlock && oldProcessBlock != processBlock)
        {
            // 调用旧的processBlock，并发送stop状态
            oldProcessBlock(identifier, countDownItem.remainderCount, NO, YES);
        }
        
        if (processBlock)
        {
            // 调用新的processBlock
            countDownItem.processBlock = processBlock;
            processBlock(identifier, countDownItem.remainderCount, NO, NO);
        }
    }
    
    if (!self.timer)
    {
        NSTimeInterval timeInterval = (CGFloat)(self.milliseconds) * 0.001;
        NSTimer *timer = [NSTimer timerWithTimeInterval:timeInterval target:self selector:@selector(countDownTime:) userInfo:nil repeats:YES];
        self.timer = timer;
        [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    }
}


/// 获取计数单位乘数
- (NSUInteger)stepMultiplierWithIdentifier:(id)identifier
{
    BMStepCountDownItem *stepCountDownItem = self.countDownDict[identifier];
    
    return stepCountDownItem.stepMultiplier;
}

/// 获取原始倒计时
- (NSUInteger)countWithIdentifier:(id)identifier
{
    BMStepCountDownItem *stepCountDownItem = self.countDownDict[identifier];
    
    return stepCountDownItem.count;
}

/// 获取剩余倒计时
- (NSUInteger)remainderCountWithIdentifier:(id)identifier
{
    BMStepCountDownItem *stepCountDownItem = self.countDownDict[identifier];
    
    return stepCountDownItem.remainderCount;
}

/// 是否正在倒计时
- (BOOL)isCountingWithIdentifier:(id)identifier
{
    BMStepCountDownItem *stepCountDownItem = self.countDownDict[identifier];
    
    return (stepCountDownItem.remainderCount > 0);
}

/// 是否暂停倒计时
- (BOOL)isPauseWithIdentifier:(id)identifier
{
    BMStepCountDownItem *stepCountDownItem = self.countDownDict[identifier];
    
    return stepCountDownItem.isPause;
}

/// 设置响应事件，如果有变更将调用旧的响应事件(强制停止)
- (void)setProcessBlock:(BMStepCountDownProcessBlock)processBlock withIdentifier:(id)identifier
{
    BMStepCountDownItem *countDownItem = self.countDownDict[identifier];
    if (countDownItem)
    {
        BMStepCountDownProcessBlock oldProcessBlock = countDownItem.processBlock;
        if (oldProcessBlock && oldProcessBlock != processBlock)
        {
            // 调用旧的processBlock，并发送stop状态
            oldProcessBlock(identifier, countDownItem.remainderCount, NO, YES);
        }

        countDownItem.processBlock = processBlock;
    }
}

/// 暂停倒计时
- (void)pauseCountDownIdentifier:(id)identifier
{
    BMStepCountDownItem *countDownItem = self.countDownDict[identifier];
    if (countDownItem)
    {
        countDownItem.isPause = YES;
    
        if (countDownItem.isPauseReCount)
        {
            // 清除真实计数，暂停后将重新计数
            countDownItem.realCount = 0;
        }
    }
}

/// 继续倒计时
- (void)continueCountDownIdentifier:(id)identifier
{
    BMStepCountDownItem *countDownItem = self.countDownDict[identifier];
    if (countDownItem)
    {
        countDownItem.isPause = NO;
    }
}

/// 停止倒计时
- (void)stopCountDownIdentifier:(id)identifier
{
    [self stopCountDownIdentifier:identifier forcedStop:YES];
}

/// 停止倒计时
- (void)stopCountDownIdentifier:(id)identifier forcedStop:(BOOL)forcedStop
{
    BMStepCountDownItem *countDownItem = self.countDownDict[identifier];
    if (countDownItem)
    {
        // 自动重启倒计时
        if (!forcedStop && countDownItem.autoRestart)
        {
            NSUInteger start = countDownItem.count-1;
            countDownItem.remainderCount = start;
            dispatch_async(dispatch_get_main_queue(), ^{
                if (countDownItem.processBlock)
                {
                    countDownItem.processBlock(identifier, countDownItem.remainderCount, YES, NO);
                }
            });
        }
        else
        {
            // 移除倒计时
            [self.countDownDict removeObjectForKey:identifier];
            
            if (forcedStop)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (countDownItem.processBlock)
                    {
                        countDownItem.processBlock(identifier, countDownItem.remainderCount, NO, NO);
                    }
                });
            }
        }
    }
    
    [self checkInvalidate];
}

/// 停止所有倒计时，并调用 processBlock 响应事件
- (void)stopAllCountDown
{
    for (id identifier in self.countDownDict.allKeys)
    {
        [self stopCountDownIdentifier:identifier];
    }
}

/// 停止所有倒计时，不调用 processBlock 响应事件
- (void)stopAllCountDownDoNothing
{
    [self.countDownDict removeAllObjects];

    [self invalidateTimer];
}

/// 时钟停止判断
- (void)checkInvalidate
{
    // 判断停止时钟
    if (![self.countDownDict.allKeys bm_isNotEmpty])
    {
        [self invalidateTimer];
    }
}

/// 停止时钟
- (void)invalidateTimer
{
    if (self.timer)
    {
        [self.timer invalidate];
        self.timer = nil;
    }
}

/// 时钟计数
- (void)countDownTime:(NSTimer *)theTimer
{
    if ([self.countDownDict.allKeys bm_isNotEmpty])
    {
        for (id identifier in self.countDownDict.allKeys)
        {
            BMStepCountDownItem *countDownItem = self.countDownDict[identifier];
            
            NSLog(@"%@ : %@", identifier, @(countDownItem.remainderCount));
            
            if (countDownItem.remainderCount <= 0)
            {
                [self stopCountDownIdentifier:identifier forcedStop:NO];
            }
            else
            {
                if (!countDownItem.isPause)
                {
                    countDownItem.realCount++;
                    if ((countDownItem.realCount % countDownItem.count) == 0)
                    {
                        countDownItem.remainderCount--;
                    
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (countDownItem.processBlock)
                            {
                                countDownItem.processBlock(identifier, countDownItem.remainderCount, NO, NO);
                            }
                        });
                    }
                }
            }
        }
    }
    else
    {
        [self invalidateTimer];
    }
}

@end


#pragma mark - BMStepCountDownItem

@implementation BMStepCountDownItem

+ (instancetype)countDownItemWithStepMultiplier:(NSUInteger)stepMultiplier count:(NSUInteger)count processBlock:(BMStepCountDownProcessBlock)processBlock
{
    return [BMStepCountDownItem countDownItemWithStepMultiplier:stepMultiplier count:count autoRestart:NO processBlock:processBlock];
}

+ (instancetype)countDownItemWithStepMultiplier:(NSUInteger)stepMultiplier count:(NSUInteger)count autoRestart:(BOOL)autoRestart processBlock:(BMStepCountDownProcessBlock)processBlock
{
    BMStepCountDownItem *stepCountDownItem = [[BMStepCountDownItem alloc] initWithStepMultiplier:stepMultiplier count:count autoRestart:autoRestart processBlock:processBlock];
    return stepCountDownItem;
}


- (instancetype)initWithStepMultiplier:(NSUInteger)stepMultiplier count:(NSUInteger)count processBlock:(BMStepCountDownProcessBlock)processBlock
{
    return [self initWithStepMultiplier:stepMultiplier count:count autoRestart:NO processBlock:processBlock];
}

- (instancetype)initWithStepMultiplier:(NSUInteger)stepMultiplier count:(NSUInteger)count autoRestart:(BOOL)autoRestart processBlock:(BMStepCountDownProcessBlock)processBlock
{
    self = [self init];
    if (self)
    {
        if (stepMultiplier <= 0)
        {
            stepMultiplier = BMStepCountDown_DefaultStepMultiplier;
        }
        self.stepMultiplier = stepMultiplier;
        self.realCount = 0;
        
        if (count <= 0)
        {
            count = BMStepCountDown_DefaultCount;
        }
        self.count = count;
        self.restartCount = count;

        self.autoRestart = autoRestart;
        self.restartCount = 0;
        
        self.processBlock = processBlock;

        /// 是否暂停
        self.isPause = NO;
        /// 暂停时是否清空 realCount
        self.isPauseReCount = NO;
    }
    
    return self;
}

@end
