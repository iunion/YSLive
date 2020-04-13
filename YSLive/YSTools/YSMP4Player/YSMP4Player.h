//
//  YSMP4Player.h
//  YSMP4Player
//
//  Created by wang on 2018/3/30.
//  Copyright © 2018年 qigge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, YSMP4PlayerState) {
    YSMP4PlayerStateReadyToPlay, // 播放器准备完毕
    YSMP4PlayerStatePlaying, // 正在播放
    YSMP4PlayerStatePause, // 暂停
    YSMP4PlayerStateStop, // 播放完毕
    YSMP4PlayerStateBufferEmpty, // 缓冲中
    YSMP4PlayerStateKeepUp, // 缓冲完成
    YSMP4PlayerStateFailed, // 播放器准备失败、网络原因，格式原因
};

@class YSMP4Player;

@protocol YSMP4PlayerDelegate <NSObject>
@optional
/**
 播放器状态变化
 @param player 播放器
 @param state 状态
 */
- (void)playerStateChange:(YSMP4Player *)player state:(YSMP4PlayerState)state;

/**
 视频源开始加载后调用 ，返回视频的长度
 @param player 播放器
 @param time 长度（秒）
 */
- (void)playerTotalTime:(YSMP4Player *)player totalTime:(CGFloat)time;

/**
 视频源加载时调用 ，返回视频的缓冲长度
 @param player 播放器
 @param time 长度（秒）
 */
- (void)playerLoadTime:(YSMP4Player *)player loadTime:(CGFloat)time;

/**
 播放时调用，返回当前时间
 @param player 播放器
 @param time 播放到当前的时间（秒）
 */
- (void)playerCurrentTime:(YSMP4Player *)player currentTime:(CGFloat)time;


@end

@interface YSMP4Player : NSObject

/** 使用播放源进行初始化 */
- (instancetype)initWithUrl:(NSString *)url;
/** 下一首 */
- (void)nextWithUrl:(NSString *)url;
/** 播放 */
- (void)play;
/** 暂停 */
- (void)pause;
/** 停止 */
- (void)stop;

@property (nonatomic, copy) NSString *playUrl;

// 是否正在播放
@property (nonatomic, assign, readonly) BOOL isPlaying;

// 是否在缓冲
@property (nonatomic, assign, readonly) BOOL isBuffering;

/** 视频音频长度 */
@property (nonatomic, assign) CGFloat timeInterval;
/** 代理 */
@property (nonatomic, weak) id<YSMP4PlayerDelegate> delegate;

// 播放器
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerItem *playerItme;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;

@end
