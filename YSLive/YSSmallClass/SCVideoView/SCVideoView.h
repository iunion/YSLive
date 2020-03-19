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
/// 是否隐藏奖杯
@property (nonatomic, assign) BOOL isHideCup;
/// 奖杯数
@property (nonatomic, assign) NSUInteger giftNumber;
/// 画笔颜色值
@property (nonatomic, strong) NSString *brushColor;
/// 画笔权限
@property (nonatomic, assign) BOOL canDraw;

/// 是否点击了home键
@property (nonatomic, assign) BOOL isInBackGround;

/// 背景view
@property (nonatomic, strong) UIView *backVideoView;

/// 视频状态
@property (nonatomic, assign, readonly) SCVideoViewVideoState videoState;
/// 摄像头设备状态
@property (nonatomic, assign, readonly) YSDeviceFaultType videoDeviceState;
/// 音频状态
@property (nonatomic, assign, readonly) SCVideoViewAudioState audioState;
/// 麦克风设备状态
@property (nonatomic, assign, readonly) YSDeviceFaultType audioDeviceState;


@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;

/// 是否举手
@property (nonatomic, assign) BOOL isRaiseHand;

// 保存发布状态，用于比较是否有变更
@property (nonatomic, assign) YSPublishState publishState;

// 老师用
- (instancetype)initWithRoomUser:(YSRoomUser *)roomUser isForPerch:(BOOL)isForPerch withDelegate:(id<SCVideoViewDelegate>)delegate;
- (instancetype)initWithRoomUser:(YSRoomUser *)roomUser withDelegate:(id<SCVideoViewDelegate>)delegate;

// 学生用
- (instancetype)initWithRoomUser:(YSRoomUser *)roomUser isForPerch:(BOOL)isForPerch;
- (instancetype)initWithRoomUser:(YSRoomUser *)roomUser;

- (void)freshWithRoomUserProperty:(YSRoomUser *)roomUser;

@end

NS_ASSUME_NONNULL_END
