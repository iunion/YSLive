//
//  CHVideoView.h
//  YSLive
//
//  Created by jiang deng on 2021/4/8.
//  Copyright © 2021 CH. All rights reserved.
//

#import <UIKit/UIKit.h>

/// 视频状态
typedef NS_OPTIONS(NSUInteger, CHVideoViewVideoState)
{
    // 正常
    CHVideoViewVideoState_Normal = 0,

    // 低端设备
    CHVideoViewVideoState_Low_end = 1 << 0,
    
    // 设备不可用
    CHVideoViewVideoState_DeviceError = 1 << 1,
    
    // 视频订阅失败
    CHVideoViewVideoState_SubscriptionFailed = 1 << 10,
    // 视频播放失败
    CHVideoViewVideoState_PlayFailed = 1 << 11,
    
    // 用户关闭视频
    CHVideoViewVideoState_Close = 1 << 20,
    
    // 弱网环境
    CHVideoViewVideoState_PoorInternet = 1 << 21,
    // 用户进入后台
    CHVideoViewVideoState_InBackground = 1 << 22
};

/// 音频状态
typedef NS_OPTIONS(NSUInteger, CHVideoViewAudioState)
{
    // 正常
    CHVideoViewAudioState_Normal = 0,
    
    // 设备不可用
    CHVideoViewAudioState_DeviceError = 1 << 0,
    
    // 音频订阅失败
    CHVideoViewAudioState_SubscriptionFailed = 1 << 10,
    // 音频播放失败
    CHVideoViewAudioState_PlayFailed = 1 << 11,
    
    // 用户关闭麦克风
    CHVideoViewAudioState_Close = 1 << 20
};

typedef NS_ENUM(NSUInteger, CHGroupRoomState)
{
    // 正常
    CHGroupRoomState_Normal = 0,
    // 讨论中
    CHGroupRoomState_Discussing,
    // 私聊中
    CHGroupRoomState_PrivateChat
};

NS_ASSUME_NONNULL_BEGIN

@class CHVideoView;

@protocol CHVideoViewDelegate <NSObject>

@optional

/// 点击手势事件
- (void)clickViewToControlWithVideoView:(CHVideoView*)videoView;

/// 拖拽手势事件
- (void)panToMoveVideoView:(CHVideoView*)videoView withGestureRecognizer:(UIPanGestureRecognizer *)pan;

@end


@interface CHVideoView : UIView

@property (nonatomic, weak) id <CHVideoViewDelegate> delegate;

/// app使用场景  3：小班课  4：直播   6：会议
@property (nonatomic, assign) CHRoomUseType appUseTheType;

@property (nonatomic, strong, readonly) CHRoomUser *roomUser;

/// 视频设备ID sourceId
@property (nonatomic, copy) NSString *sourceId;
/// 视频流ID streamId
@property (nonatomic, copy) NSString *streamId;

/// 是否占位用
@property (nonatomic, assign) BOOL isForPerch;

/// 双击视频最大化标识
@property (nonatomic, assign) BOOL isFullScreen;
/// 是否被拖出
@property (nonatomic, assign) BOOL isDragOut;

/// 分组房间视频状态
@property (nonatomic, assign) CHGroupRoomState groupRoomState;

/// 是否举手
@property (nonatomic, assign) BOOL isRaiseHand;

/// 小黑板是否正在私聊
@property (nonatomic, assign) BOOL isPrivateChating;

/// 视频状态
@property (nonatomic, assign, readonly) CHVideoViewVideoState videoState;
/// 摄像头设备状态
@property (nonatomic, assign, readonly) CHDeviceFaultType videoDeviceState;
/// 音频状态
@property (nonatomic, assign, readonly) CHVideoViewAudioState audioState;
/// 麦克风设备状态
@property (nonatomic, assign, readonly) CHDeviceFaultType audioDeviceState;

/// 学生用
- (instancetype)initWithRoomUser:(CHRoomUser *)roomUser withSourceId:(nullable NSString *)sourceId isForPerch:(BOOL)isForPerch;
- (instancetype)initWithRoomUser:(CHRoomUser *)roomUser withSourceId:(nullable NSString *)sourceId;

/// 老师用
- (instancetype)initWithRoomUser:(CHRoomUser *)roomUser withSourceId:(nullable NSString *)sourceId isForPerch:(BOOL)isForPerch withDelegate:(nullable id <CHVideoViewDelegate>)delegate;
- (instancetype)initWithRoomUser:(CHRoomUser *)roomUser withSourceId:(nullable NSString *)sourceId withDelegate:(nullable id <CHVideoViewDelegate>)delegate;

- (void)freshWithRoomUserProperty:(CHRoomUser *)roomUser;

@end

NS_ASSUME_NONNULL_END
