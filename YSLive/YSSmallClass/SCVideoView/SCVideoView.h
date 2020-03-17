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
    SCVideoViewVideoState_DeviceErroe = 1 << 1,
    // 无设备
    //SCVideoViewVideoState_NoDevice = 1 << 1,
    // 设备被禁用
    //SCVideoViewVideoState_DeviceDisable = 1 << 2,
    // 设备被占用
    //SCVideoViewVideoState_DeviceBusy = 1 << 3,
    // 设备打开失败
    //SCVideoViewVideoState_DeviceOpenError = 1 << 4,
    
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

typedef NS_ENUM(NSUInteger, SCVideoViewVideoDeviceState)
{
    // 无设备
    SCVideoViewVideoDeviceState_NoDevice = 0,
    // 设备被禁用
    SCVideoViewVideoDeviceState_Disable,
    // 设备被占用
    SCVideoViewVideoDeviceState_Busy,
    // 设备打开失败
    SCVideoViewVideoDeviceState_OpenError
};

typedef NS_OPTIONS(NSUInteger, SCVideoViewAudioState)
{
    // 正常
    SCVideoViewAudioState_Normal = 0,
    
    // 设备不可用
    SCVideoViewAudioState_DeviceErroe = 1 << 0,
    // 无设备
    //SCVideoViewAudioState_NoDevice = 1 << 0,
    // 设备被禁用
    //SCVideoViewAudioState_DeviceDisable = 1 << 1,
    // 设备被占用
    //SCVideoViewAudioState_DeviceBusy = 1 << 2,
    // 设备打开失败
    //SCVideoViewAudioState_DeviceOpenError = 1 << 3,
    
    // 音频订阅失败
    SCVideoViewAudioState_SubscriptionFailed = 1 << 10,
    // 音频播放失败
    SCVideoViewAudioState_PlayFailed = 1 << 11,
    
    // 用户关闭麦克风
    SCVideoViewAudioState_Close = 1 << 20
};

typedef NS_ENUM(NSUInteger, SCVideoViewAudioDeviceState)
{
    // 无设备
    SCVideoViewAudioDeviceState_NoDevice = 0,
    // 设备被禁用
    SCVideoViewAudioDeviceState_Disable,
    // 设备被占用
    SCVideoViewAudioDeviceState_Busy,
    // 设备打开失败
    //SCVideoViewAudioDeviceState_OpenError
};



@protocol SCVideoViewDelegate <NSObject>

///点击手势事件
- (void)clickViewToControlWithVideoView:(SCVideoView*)videoView;

///拖拽手势事件
- (void)panToMoveVideoView:(SCVideoView*)videoView withGestureRecognizer:(UIPanGestureRecognizer *)pan;

@end


@interface SCVideoView : UIView

///app使用场景  3：小班课  4：直播   6：会议
@property (nonatomic, assign) YSAppUseTheType appUseTheType;

@property (nonatomic, weak) id<SCVideoViewDelegate> delegate;

@property (nonatomic, strong, readonly) YSRoomUser *roomUser;
/// 是否占位用
@property (nonatomic, assign) BOOL isForPerch;
/// 标识布局变化的值 宫格布局标识
@property (nonatomic, assign) BOOL isFullMedia;
/// 双击视频最大化标识
@property (nonatomic, assign) BOOL isFullScreen;
/// 是否被拖出
@property (nonatomic, assign) BOOL isDragOut;
/// 当前设备音量  音量大小 0 ～ 32670
@property (nonatomic, assign) NSUInteger iVolume;
/// 奖杯数
@property (nonatomic, assign) NSUInteger giftNumber;
/// 画笔颜色值
@property (nonatomic, strong) NSString *brushColor;
/// 画笔权限
@property (nonatomic, assign) BOOL canDraw;
/// 是否被禁音
@property (nonatomic, assign) BOOL disableSound;
/// 是否被禁视频
@property (nonatomic, assign) BOOL disableVideo;
/// 是否点击了home键
@property (nonatomic, assign) BOOL isInBackGround;
/// 是否隐藏奖杯
@property (nonatomic, assign) BOOL isHideCup;
/// 背景view
@property (nonatomic, strong) UIView *backVideoView;
/// 该用户有开摄像
@property (nonatomic, assign) BOOL iHasVadeo;
/// 该用户有开麦克风
@property (nonatomic, assign) BOOL iHasAudio;
/// 该用户网络是否有问题
@property (nonatomic, assign) BOOL isPoorNetWork;

/// 视频状态
@property (nonatomic, assign) SCVideoViewVideoState videoState;
@property (nonatomic, assign) SCVideoViewVideoDeviceState videoDeviceState;
/// 音频状态
@property (nonatomic, assign) SCVideoViewAudioState audioState;
@property (nonatomic, assign) SCVideoViewAudioDeviceState audioDeviceState;


@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;

/// 是否举手
@property (nonatomic, assign) BOOL isRaiseHand;

// 保存发布状态，用于比较是否有变更
@property (nonatomic, assign) YSPublishState publishState;

- (instancetype)initWithRoomUser:(YSRoomUser *)roomUser isForPerch:(BOOL)isForPerch withDelegate:(id<SCVideoViewDelegate>)delegate;

- (instancetype)initWithRoomUser:(YSRoomUser *)roomUser withDelegate:(id<SCVideoViewDelegate>)delegate;

- (instancetype)initWithRoomUser:(YSRoomUser *)roomUser isForPerch:(BOOL)isForPerch;

- (instancetype)initWithRoomUser:(YSRoomUser *)roomUser;

- (void)changeRoomUserProperty:(YSRoomUser *)roomUser;

@end

NS_ASSUME_NONNULL_END
