//
//  YSSessionDelegate.h
//  YSSession
//
//  Created by jiang deng on 2020/6/10.
//  Copyright © 2020 YS. All rights reserved.
//

#ifndef YSSessionDelegate_h
#define YSSessionDelegate_h

#import "YSRoomUser.h"
#import "YSSessionForSignalingDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@protocol YSSessionForUserDelegate;
@protocol YSSessionForBigRoomDelegate;
@protocol YSSessionForMessageDelegate;

@protocol YSSessionDelegate <YSSessionForUserDelegate, YSSessionForBigRoomDelegate, YSSessionForSignalingDelegate, YSSessionForMessageDelegate>

/// 进入前台
- (void)handleEnterForeground;

/// 进入后台
- (void)handleEnterBackground;

/**
 发生错误 回调

 @param error error
 */
- (void)onRoomDidOccuredError:(NSError *)error;

/**
 发生警告 回调

 @param code 警告码
 */
- (void)onRoomDidOccuredWaring:(YSRoomWarningCode)code;

/// 进入房间失败
- (void)onRoomJoinFailed:(NSDictionary *)errorDic;

/**
    成功进入房间
    @param ts 服务器当前时间戳，以秒为单位，如1572001230
 */
- (void)onRoomJoined:(long)ts;

/**
    成功重连房间
    @param ts 服务器当前时间戳，以秒为单位，如1572001230
 */
- (void)onRoomReJoined:(long)ts;

/**
    已经离开房间
 */
- (void)onRoomLeft;


/// 失去连接
- (void)onRoomConnectionLost;


/// 用户属性改变
- (void)onRoomUserPropertyChanged:(NSString *)userId fromeUserId:(NSString *)fromeUserId properties:(NSDictionary *)properties;

/// 媒体流发布状态
- (void)onRoomShareMediaFile:(YSSharedMediaFileModel *)mediaFileModel;
/// 更新媒体流的信息
- (void)onRoomUpdateMediaFileStream:(YSSharedMediaFileModel *)mediaFileModel;

/// 收到开始共享桌面
- (void)onRoomStartShareDesktopWithUserId:(NSString *)userId streamID:(NSString *)streamID;
/// 收到结束共享桌面
- (void)onRoomStopShareDesktopWithUserId:(NSString *)userId streamID:(NSString *)streamID;


/// 用户流音量变化
- (void)onRoomAudioVolumeWithUserId:(NSString *)userId volume:(NSInteger)volume;

/// 是否关闭摄像头
- (void)onRoomCloseVideo:(BOOL)close withUid:(NSString *)uid streamID:(NSString *)streamID;
/// 是否关闭麦克风
- (void)onRoomCloseAudio:(BOOL)close withUid:(NSString *)uid;

/// 收到音视频流
- (void)onRoomStartVideoOfUid:(NSString *)uid streamID:(nullable NSString *)streamID;
/// 停止音视频流
- (void)onRoomStopVideoOfUid:(NSString *)uid streamID:(nullable NSString *)streamID;

@end

#pragma mark 用户
@protocol YSSessionForUserDelegate <NSObject>

// 只用于普通房间
/// 用户进入
- (void)onRoomUserJoined:(YSRoomUser *)user inList:(BOOL)inList;
/// 用户退出
- (void)onRoomUserLeft:(YSRoomUser *)user;

/// 老师进入
- (void)onRoomTeacherJoined;
/// 老师退出
- (void)onRoomTeacherLeft;

@end

#pragma mark 房间状态变为大房间
@protocol YSSessionForBigRoomDelegate <NSObject>

/// 由小房间变为大房间(只调用一次)
- (void)onRoomChangeToBigRoomInList:(BOOL)inlist;
/// 大房间刷新用户数量
- (void)onRoomBigRoomFreshUserCountInList:(BOOL)inlist;
/// 大房间刷新数据
- (void)onRoomBigRoomFreshInList:(BOOL)inlist;

@end

#pragma mark 消息
@protocol YSSessionForMessageDelegate <NSObject>

/// 收到信息
- (void)handleMessageWith:(YSChatMessageModel *)message;

@end

NS_ASSUME_NONNULL_END


#endif /* YSSessionDelegate_h */
