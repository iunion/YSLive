//
//  CHSessionDelegate.h
//  CHSession
//
//

#ifndef CHSessionDelegate_h
#define CHSessionDelegate_h

#import "CHRoomUser.h"
#import "CHSharedMediaFileModel.h"
#import "CHChatMessageModel.h"

#import "CHSessionForSignalingDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@protocol CHSessionForUserDelegate;
@protocol CHSessionForBigRoomDelegate;
@protocol CHSessionForMessageDelegate;

@protocol CHSessionDelegate <CHSessionForUserDelegate, CHSessionForBigRoomDelegate, CHSessionForSignalingDelegate, CHSessionForMessageDelegate>

@optional

/// 进入前台
- (void)handleEnterForeground;

/// 进入后台
- (void)handleEnterBackground;

/// 发生错误 回调
- (void)onRoomDidOccuredError:(CloudHubErrorCode)errorCode withMessage:(nullable NSString *)message;

/// 进入房间失败
- (void)onRoomJoinFailed:(NSDictionary *)errorDic;

/// 获取房间数据完毕
- (void)onRoomDidCheckRoom;

/// 成功进入房间
- (void)onRoomJoined;

/// 成功重连房间
- (void)onRoomReJoined;

/// 已经离开房间
- (void)onRoomLeft;

/// 失去连接
- (void)onRoomConnectionLost;

/// 被踢出
- (void)onRoomKickedOut:(NSInteger)reasonCode;

/// 用户属性改变
- (void)onRoomUserPropertyChanged:(NSString *)userId fromeUserId:(NSString *)fromeUserId properties:(NSDictionary *)properties;

/// 本地媒体流发布状态
- (void)onRoomStartLocalMediaFile:(NSString *)mediaFileUrl;
- (void)onRoomStopLocalMediaFile:(NSString *)mediaFileUrl;
/// 更新本地媒体流的信息
- (void)onRoomUpdateLocalFileStream:(NSString *)mediaFileUrl total:(NSUInteger)total pos:(NSUInteger)pos isPause:(BOOL)isPause;

/// 媒体流发布状态
- (void)onRoomShareMediaFile:(CHSharedMediaFileModel *)mediaFileModel;
/// 更新媒体流的信息
- (void)onRoomUpdateMediaFileStream:(CHSharedMediaFileModel *)mediaFileModel isSetPos:(BOOL)isSetPos;

/// 收到开始共享桌面
- (void)onRoomStartShareDesktopWithUserId:(NSString *)userId sourceID:(nullable NSString *)sourceId streamId:(NSString *)streamId;
/// 收到结束共享桌面
- (void)onRoomStopShareDesktopWithUserId:(NSString *)userId sourceID:(nullable NSString *)sourceId streamId:(NSString *)streamId;


/// 用户流音量变化
- (void)onRoomAudioVolumeWithUserId:(NSString *)userId volume:(NSInteger)volume;

/// 是否关闭摄像头
- (void)onRoomCloseVideo:(BOOL)close withUid:(NSString *)uid sourceID:(nullable NSString *)sourceId streamId:(NSString *)streamId;
/// 是否关闭麦克风
- (void)onRoomCloseAudio:(BOOL)close withUid:(NSString *)uid;

/// 收到音视频流
- (void)onRoomStartVideoOfUid:(NSString *)uid sourceID:(nullable NSString *)sourceId streamId:(nullable NSString *)streamId;
/// 停止音视频流
- (void)onRoomStopVideoOfUid:(NSString *)uid sourceID:(nullable NSString *)sourceId streamId:(nullable NSString *)streamId;

@end

#pragma mark 用户
@protocol CHSessionForUserDelegate <NSObject>

@optional

// 只用于普通房间
/// 用户进入
- (void)onRoomUserJoined:(CHRoomUser *)user isHistory:(BOOL)isHistory;
/// 用户退出
- (void)onRoomUserLeft:(CHRoomUser *)user;

/// 老师进入
- (void)onRoomTeacherJoined:(BOOL)isHistory;
/// 老师退出
- (void)onRoomTeacherLeft;

/// 班主任进入
- (void)onRoomClassMasterJoined:(BOOL)isHistory;
/// 班主任退出
- (void)onRoomClassMasterLeft;

@end

#pragma mark 房间状态变为大房间
@protocol CHSessionForBigRoomDelegate <NSObject>

@optional

/// 由小房间变为大房间(只调用一次)
- (void)onRoomChangeToBigRoomIsHistory:(BOOL)isHistory;
/// 大房间刷新用户数量
- (void)onRoomBigRoomFreshUserCountIsHistory:(BOOL)isHistory;
/// 大房间刷新数据
- (void)onRoomBigRoomFreshIsHistory:(BOOL)isHistory;

@end

#pragma mark 消息
@protocol CHSessionForMessageDelegate <NSObject>

@optional

/// 收到信息
- (void)handleMessageWith:(CHChatMessageModel *)message;

@end

NS_ASSUME_NONNULL_END

#endif /* CHSessionDelegate_h */
