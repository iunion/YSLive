//
//  BMCountDownManager.m
//  BMTableViewManagerSample
//
//  Created by jiang deng on 2018/11/12.
//  Copyright © 2018年 DJ. All rights reserved.
//

#import "BMCountDownManager.h"
#import "NSObject+BMCategory.h"

@interface BMCountDownItem ()

// 倒计时标识
//@property (nonatomic, strong) NSString *identifier;
// 倒计时剩余时间(单位:秒)
@property (nonatomic, assign) NSInteger timeInterval;

@property (nonatomic, assign) NSInteger backTimeInterval;

@property (nonatomic, assign) BOOL autoRestart;

// 是否暂停
@property (nonatomic, assign) BOOL isPause;

// 每秒触发响应事件
@property (nullable, nonatomic, copy) BMCountDownProcessBlock processBlock;

@end


@interface BMCountDownManager ()

@property (nonatomic, strong) NSTimer *timer;

/// 倒计时项目存储
@property (nonatomic, strong) NSMutableDictionary<id, BMCountDownItem *> *countDownDict;

@end


#pragma mark -
#pragma mark BMCountDownManager

@implementation BMCountDownManager

+ (instancetype)manager
{
    static BMCountDownManager *countDownManager = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        countDownManager = [[self alloc] init];
    });
    
    return countDownManager;
}

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        _countDownDict = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

// 获取倒计时
- (NSInteger)timeIntervalWithIdentifier:(id)identifier
{
    return self.countDownDict[identifier].timeInterval;
}

- (BOOL)isCountDownWithIdentifier:(id)identifier
{
    BMCountDownItem *countDownItem = self.countDownDict[identifier];
    return (countDownItem.timeInterval > 0);
}

- (BOOL)isPauseCountDownWithIdentifier:(id)identifier
{
    BMCountDownItem *countDownItem = self.countDownDict[identifier];
    return countDownItem.isPause;
}

- (void)startCountDownWithIdentifier:(id)identifier processBlock:(BMCountDownProcessBlock)processBlock
{
    [self startCountDownWithIdentifier:identifier timeInterval:BMCountDown_DefaultTimeInterval processBlock:processBlock];
}

- (void)startCountDownWithIdentifier:(id)identifier timeInterval:(NSInteger)timeInterval processBlock:(BMCountDownProcessBlock)processBlock
{
    [self startCountDownWithIdentifier:identifier timeInterval:timeInterval autoRestart:NO processBlock:processBlock];
}

- (void)startCountDownWithIdentifier:(id)identifier timeInterval:(NSInteger)timeInterval autoRestart:(BOOL)autoRestart processBlock:(nullable BMCountDownProcessBlock)processBlock

{
    // 倒计时时间判断
    if (timeInterval <= 0)
    {
        return;
    }
    
    BMCountDownItem *countDownItem = self.countDownDict[identifier];
    
    if (!countDownItem)
    {
        // 不存在标识的倒计时创建
        countDownItem = [BMCountDownItem countDownItemWithTimeInterval:timeInterval autoRestart:autoRestart processBlock:processBlock];
        self.countDownDict[identifier] = countDownItem;
        
        if (processBlock)
        {
            // 调用processBlock
            processBlock(identifier, countDownItem.timeInterval, NO, NO);
        }
    }
    else if (countDownItem.timeInterval <= 0)
    {
        // 调试，检查线程错误使用
        // 待完善
        NSAssert(NO, @"Check DJCountDownManager timeInterval");
    }
    else
    {
        BMCountDownProcessBlock oldProcessBlock = countDownItem.processBlock;
        if (oldProcessBlock)
        {
            // 调用旧的processBlock，并发送stop状态
            oldProcessBlock(identifier, countDownItem.timeInterval, NO, YES);
        }
        
        if (processBlock)
        {
            // 调用新的processBlock
            countDownItem.processBlock = processBlock;
            processBlock(identifier, countDownItem.timeInterval, NO, NO);
        }
    }
    
    if (!self.timer)
    {
//        dispatch_async(dispatch_get_global_queue(0, 0), ^{
//            // 启动时钟
//            self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countDownTime:) userInfo:nil repeats:YES];
//            [[NSRunLoop currentRunLoop] run];
//        });
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            // 启动时钟
            NSTimer *timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(countDownTime:) userInfo:nil repeats:YES];
            self.timer = timer;
            [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        });

//        NSTimer *timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
//        [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    }
}

- (void)setProcessBlock:(BMCountDownProcessBlock)processBlock withIdentifier:(id)identifier
{
    BMCountDownItem *countDownItem = self.countDownDict[identifier];
    if (countDownItem)
    {
        countDownItem.processBlock = processBlock;
    }
}

- (void)removeProcessBlockWithIdentifier:(id)identifier
{
    // 移除响应事件
    [self setProcessBlock:nil withIdentifier:identifier];
}

// 暂停倒计时，并调用processBlock
- (void)pauseCountDownIdentifier:(id)identifier
{
    BMCountDownItem *countDownItem = self.countDownDict[identifier];
    if (countDownItem)
    {
        countDownItem.isPause = YES;
    }
}

// 继续倒计时
- (void)continueCountDownIdentifier:(id)identifier
{
    BMCountDownItem *countDownItem = self.countDownDict[identifier];
    if (countDownItem)
    {
        countDownItem.isPause = NO;
    }
}

- (void)stopCountDownIdentifier:(id)identifier
{
    [self stopCountDownIdentifier:identifier forcedStop:YES];
}

- (void)stopCountDownIdentifier:(id)identifier forcedStop:(BOOL)stop
{
    BMCountDownItem *countDownItem = self.countDownDict[identifier];
    if (countDownItem)
    {
        if (!stop && countDownItem.autoRestart)
        {
            NSInteger start = countDownItem.backTimeInterval-1;
            if (start < 0)
            {
                start = 0;
            }

            countDownItem.timeInterval = start;
            dispatch_async(dispatch_get_main_queue(), ^{
                if (countDownItem.processBlock)
                {
                    countDownItem.processBlock(identifier, countDownItem.timeInterval, YES, NO);
                }
            });
        }
        else
        {
            [self.countDownDict removeObjectForKey:identifier];
            
            if (stop)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (countDownItem.processBlock)
                    {
                        countDownItem.processBlock(identifier, countDownItem.timeInterval, NO, stop);
                    }
                });
            }
        }
    }
    
    [self checkInvalidate];
}

- (void)stopAllCountDown
{
    for (id identifier in self.countDownDict.allKeys)
    {
        [self stopCountDownIdentifier:identifier];
    }
}

- (void)stopAllCountDownDoNothing
{
    [self.countDownDict removeAllObjects];

    [self checkInvalidate];
}

- (void)checkInvalidate
{
    // 判断停止时钟
    if (![self.countDownDict.allKeys bm_isNotEmpty])
    {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)countDownTime:(NSTimer *)theTimer
{
    for (id identifier in self.countDownDict.allKeys)
    {
        BMCountDownItem *countDownItem = self.countDownDict[identifier];

        NSLog(@"%@ : %@", identifier, @(countDownItem.timeInterval));
        
        if (countDownItem.timeInterval <= 0)
        {
            [self stopCountDownIdentifier:identifier forcedStop:NO];
        }
        else
        {
            if (!countDownItem.isPause)
            {
                countDownItem.timeInterval--;

                dispatch_async(dispatch_get_main_queue(), ^{
                    if (countDownItem.processBlock)
                    {
                        countDownItem.processBlock(identifier, countDownItem.timeInterval, NO, NO);
                    }
                });
            }
        }
    }
    
    //[self checkInvalidate];
}

@end


#pragma mark -
#pragma mark BMCountDownItem

@implementation BMCountDownItem

+ (instancetype)countDownItemWithTimeInterval:(NSInteger)timeInterval
{
    BMCountDownItem *countDownItem = [[BMCountDownItem alloc] initWithTimeInterval:timeInterval];
    return countDownItem;
}

+ (instancetype)countDownItemWithTimeInterval:(NSInteger)timeInterval processBlock:(BMCountDownProcessBlock)processBlock
{
    BMCountDownItem *countDownItem = [[BMCountDownItem alloc] initWithTimeInterval:timeInterval processBlock:processBlock];
    return countDownItem;
}

+ (instancetype)countDownItemWithTimeInterval:(NSInteger)timeInterval autoRestart:(BOOL)autoRestart processBlock:(nullable BMCountDownProcessBlock)processBlock
{
    BMCountDownItem *countDownItem = [[BMCountDownItem alloc] initWithTimeInterval:timeInterval autoRestart:autoRestart processBlock:processBlock];
    return countDownItem;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.timeInterval = BMCountDown_DefaultTimeInterval;
    }
    return self;
}

- (instancetype)initWithTimeInterval:(NSInteger)timeInterval
{
    return [self initWithTimeInterval:timeInterval processBlock:nil];
}

- (instancetype)initWithTimeInterval:(NSInteger)timeInterval processBlock:(BMCountDownProcessBlock)processBlock
{
    return [self initWithTimeInterval:timeInterval autoRestart:NO processBlock:nil];
}

- (instancetype)initWithTimeInterval:(NSInteger)timeInterval autoRestart:(BOOL)autoRestart processBlock:(BMCountDownProcessBlock)processBlock
{
    self = [self init];
    if (self)
    {
        if (timeInterval <= 0)
        {
            timeInterval = BMCountDown_DefaultTimeInterval;
        }
        self.timeInterval = timeInterval;
        
        self.backTimeInterval = timeInterval;
        self.autoRestart = autoRestart;
        
        self.processBlock = processBlock;
    }
    return self;
}

@end
