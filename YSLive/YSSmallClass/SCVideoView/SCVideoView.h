//
//  SCVideoView.h
//  YSLive
//
//  Created by jiang deng on 2019/11/8.
//  Copyright © 2019 YS. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "YSPanGesture.h"
@class SCVideoView;
//@class YSRoomUser;

NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSUInteger, SCVideoViewVideoState)
{
    // 正常
    SCVideoViewVideoState_Normal = 0,

    // 低端设备
    SCVideoViewVideoState_Low_end = 1 << 0,
    
    // 设备不可用
    SCVideoViewVideoState_DeviceError = 1 << 1,
    
    // 视频订阅失败
    SCVideoViewVideoState_SubscriptionFailed = 1 << 10,
    // 视频播放失败
    SCVideoViewVideoState_PlayFailed = 1 << 11,
    
    // 用户关闭视频
    SCVideoViewVideoState_Close = 1 << 20,
    
    // 弱网环境
    SCVideoViewVideoState_PoorInternet = 1 << 21,
    // 用户进入后台
    SCVideoViewVideoState_InBackground = 1 << 22
};

typedef NS_OPTIONS(NSUInteger, SCVideoViewAudioState)
{
    // 正常
    SCVideoViewAudioState_Normal = 0,
    
    // 设备不可用
    SCVideoViewAudioState_DeviceError = 1 << 0,
    
    // 音频订阅失败
    SCVideoViewAudioState_SubscriptionFailed = 1 << 10,
    // 音频播放失败
    SCVideoViewAudioState_PlayFailed = 1 << 11,
    
    // 用户关闭麦克风
    SCVideoViewAudioState_Close = 1 << 20
};

typedef NS_OPTIONS(NSUInteger, SCGroopRoomState)
{
    // 正常
    SCGroopRoomState_Normal = 0,
    // 讨论中
    SCGroopRoomState_Discussing = 1 << 0,
    // 私聊中
    SCGroopRoomState_PrivateChat = 1 << 1,
};

@protocol SCVideoViewDelegate <NSObject>

@optional

///点击手势事件
- (void)clickViewToControlWithVideoView:(SCVideoView*)videoView;

///拖拽手势事件
- (void)panToMoveVideoView:(SCVideoView*)videoView withGestureRecognizer:(UIPanGestureRecognizer *)pan;

@end


@interface SCVideoView : UIView

///app使用场景  3：小班课  4：直播   6：会议
@property (nonatomic, assign) CHRoomUseType appUseTheType;

@property (nonatomic, weak) id <SCVideoViewDelegate> delegate;

///视频设备ID sourceId
@property (nonatomic, copy) NSString *sourceId;

///视频流ID streamId
@property (nonatomic, copy) NSString *streamId;

@property (nonatomic, strong, readonly) CHRoomUser *roomUser;
/// 是否占位用
@property (nonatomic, assign) BOOL isForPerch;
/// 标识布局变化的值 宫格布局标识
@property (nonatomic, assign) BOOL isFullMedia;
/// 双击视频最大化标识
@property (nonatomic, assign) BOOL isFullScreen;
/// 是否被拖出
@property (nonatomic, assign) BOOL isDragOut;

/// 是否隐藏奖杯
@property (nonatomic, assign) BOOL isHideCup;

/// 分组房间视频状态
@property (nonatomic, assign) SCGroopRoomState groopRoomState;

/// 背景view
@property (nonatomic, strong, readonly) UIView *backVideoView;
/// popView的基准View
@property (nonatomic, strong, readonly) UIView *sourceView;

/// 视频状态
@property (nonatomic, assign, readonly) SCVideoViewVideoState videoState;
/// 摄像头设备状态
@property (nonatomic, assign, readonly) CHDeviceFaultType videoDeviceState;
/// 音频状态
@property (nonatomic, assign, readonly) SCVideoViewAudioState audioState;
/// 麦克风设备状态
@property (nonatomic, assign, readonly) CHDeviceFaultType audioDeviceState;

@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;

/// 是否举手
@property (nonatomic, assign) BOOL isRaiseHand;

///小黑板是否正在私聊
@property (nonatomic, assign) BOOL isPrivateChating;


/// 老师用
- (instancetype)initWithRoomUser:(CHRoomUser *)roomUser withSourceId:(nullable NSString *)sourceId isForPerch:(BOOL)isForPerch withDelegate:(id<SCVideoViewDelegate>)delegate;
- (instancetype)initWithRoomUser:(CHRoomUser *)roomUser withSourceId:(nullable NSString *)sourceId withDelegate:(id<SCVideoViewDelegate>)delegate;

/// 学生用
- (instancetype)initWithRoomUser:(CHRoomUser *)roomUser withSourceId:(nullable NSString *)sourceId isForPerch:(BOOL)isForPerch;
- (instancetype)initWithRoomUser:(CHRoomUser *)roomUser withSourceId:(nullable NSString *)sourceId;

- (void)freshWithRoomUserProperty:(CHRoomUser *)roomUser;

@end

NS_ASSUME_NONNULL_END
