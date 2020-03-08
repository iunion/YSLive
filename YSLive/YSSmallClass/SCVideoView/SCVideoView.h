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
