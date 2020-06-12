//
//  YSRoomDelegate.h
//  YSRoomSDK
//
#import "YSRoomDefines.h"

#pragma mark - JoinRoomNotification
//加入房间成功
FOUNDATION_EXTERN NSNotificationName const YSRoomInterfaceJoinRoomSuccessNotification;
//加入房间失败
FOUNDATION_EXTERN NSNotificationName const YSRoomInterfaceJoinRoomFailedNotification;

#pragma mark - YSRoomInterfaceDelegate
@protocol YSRoomInterfaceDelegate<NSObject>

@optional
/**
    成功进入房间
    @param ts 服务器当前时间戳，以秒为单位，如1572001230
 */
- (void)onRoomJoined:(long)ts;

/**
   成功进入房间
//   注意：当Delegate同时实现了onRoomRoomJoined:(long)ts和onRoomRoomJoined时，
//        只有onRoomRoomJoined:(long)ts会被调用
*/
- (void)onRoomJoined YS_Deprecated("已经弃用");

/**
    成功重连房间
    @param ts 服务器当前时间戳，以秒为单位，如1572001230
 */
- (void)onRoomReJoined:(long)ts;

/**
    已经离开房间
 */
- (void)onRoomLeft;

/**
 失去连接
 */
- (void)onRoomConnectionLost;

/**
    自己被踢出房间
    @param reason 被踢原因
 */
- (void)onRoomKickedOut:(NSDictionary *)reason;

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

/**
    有用户进入房间
    @param peerID 用户ID
    @param inList true：在自己之前进入；false：在自己之后进入
 */
- (void)onRoomUserJoined:(NSString *)peerID inList:(BOOL)inList;

/**
    有用户离开房间
    @param peerID 用户ID
 */
- (void)onRoomUserLeft:(NSString *)peerID;

/**
    有用户的属性发生了变化
    @param peerID 用户ID
    @param properties 发生变化的属性
    @param fromId 修改用户属性消息的发送方的id
 */
- (void)onRoomUserPropertyChanged:(NSString *)peerID
                            properties:(NSDictionary*)properties
                                fromId:(NSString *)fromId;

/**
 用户视频状态变化的通知

 @param peerID 用户ID
 @param state 视频状态
 */
- (void)onRoomUserVideoStatus:(NSString *)peerID
                               state:(YSMediaState)state;
/**
 用户某一视频设备的视频状态变化的通知（多流模式）
 
 @param peerID 用户ID
 @param deviceId 视频设备ID
 @param state 视频状态
 */
- (void)onRoomUserVideoStatus:(NSString *)peerID
                            deviceId:(NSString *)deviceId
                               state:(YSMediaState)state;
/**
 用户音频状态变化的通知，
 
 @param peerID 用户ID
 @param state 音频状态
 */
- (void)onRoomUserAudioStatus:(NSString *)peerID
                               state:(YSMediaState)state;



/**
    收到自定义信令 发布消息
    @param msgID 消息id
    @param msgName 消息名字
    @param ts 消息时间戳
    @param data 消息数据，可以是Number、String、NSDictionary或NSArray
    @param fromID  消息发布者的ID
    @param inlist 是否是inlist中的信息

 */
- (void)onRoomRemotePubMsgWithMsgID:(NSString *)msgID
                                   msgName:(NSString *)msgName
                                      data:(NSObject *)data
                                    fromID:(NSString *)fromID
                                    inList:(BOOL)inlist
                                        ts:(long)ts
                               body:(NSDictionary*)msgBody;

/**
    收到自定义信令 删去消息
    @param msgID 消息id
    @param msgName 消息名字
    @param ts 消息时间戳
    @param data 消息数据，可以是Number、String、NSDictionary或NSArray
    @param fromID  消息发布者的ID
    @param inlist 是否是inlist中的信息
 */
- (void)onRoomRemoteDelMsgWithMsgID:(NSString *)msgID
                                   msgName:(NSString *)msgName
                                      data:(NSObject *)data
                                    fromID:(NSString *)fromID 
                                    inList:(BOOL)inlist
                                        ts:(long)ts;
/**
    收到聊天消息
    @param message 聊天消息内容
    @param peerID 发送者用户ID
    @param extension 消息扩展信息（用户昵称、用户角色等等）
 */
- (void)onRoomMessageReceived:(NSString *)message
                            fromID:(NSString *)peerID
                         extension:(NSDictionary *)extension;
/**
 视频数据统计
 
 @param peerId 用户ID
 @param stats 数据信息
 */
- (void)onRoomVideoStatsReport:(NSString *)peerId stats:(YSVideoStats *)stats;
/**
 音频数据统计
 
 @param peerId 用户ID
 @param stats 数据信息
 */
- (void)onRoomAudioStatsReport:(NSString *)peerId stats:(YSAudioStats *)stats;


/**
 音视频统计数据

 @param stats 视频和音频的统计数据
 */
- (void)onRoomRtcStatsReport:(YSRtcStats *)stats;


/**
 用户的音频音量大小变化的回调

 @param peeID 用户ID
 @param volume 音量大小（0 - 32670）
 */
- (void)onRoomAudioVolumeWithPeerID:(NSString *)peeID volume:(int)volume;

/**
 纯音频 与音视频 教室切换
 
 @param fromId 用户ID  切换房间模式的用户ID
 @param onlyAudio 是否是纯音频
 */
- (void)onRoomAudioRoomSwitch:(NSString *)fromId onlyAudio:(BOOL)onlyAudio;

/**
 播放某用户视频，渲染视频第一帧时，会收到回调；如果没有unplay某用户的视频，而再次play该用户视频时，不会再次收到此回调。

 @param peerID 用户ID
 @param width 视频宽
 @param height 视频高
 @param type 视频类型
 */
- (void)onRoomFirstVideoFrameWithPeerID:(NSString *)peerID
                                         width:(NSInteger)width
                                        height:(NSInteger)height
                                     mediaType:(YSMediaType)type;

/**
 播放用户某一视频设备视频，渲染视频第一帧时，会收到回调；如果没有unplay，而再次play视频时，不会再次收到此回调。

 @param peerID 用户ID
 @param deviceId 视频设备ID
 @param width 视频宽
 @param height 视频高
 @param type 视频类型
 */
- (void)onRoomFirstVideoFrameWithPeerID:(NSString *)peerID
                                      deviceId:(NSString *)deviceId
                                         width:(NSInteger)width
                                        height:(NSInteger)height
                                     mediaType:(YSMediaType)type;



/**
 视频播放过程中画面状态回调

 @param peerId 用户ID
 @param deviceId 视频设备ID
 @param state 画面状态
 @param type 视频类型
 */
- (void)onRoomVideoStateChange:(NSString *)peerId
                             deviceId:(NSString *)deviceId
                           videoState:(YSRenderState)state
                            mediaType:(YSMediaType)type;

/**
 音频播放过程中状态回调
 
 @param peerId 用户ID
 @param state 音频状态
 @param type 类型
 */
- (void)onRoomAudioStateChange:(NSString *)peerId
                           audioState:(YSRenderState)state
                            mediaType:(YSMediaType)type;

/**
 播放某用户音频，会收到此回调；如果没有unplay某用户的音频，而再次play该用户音频时，不会再次收到此回调。

 @param peerID 用户ID
 @param type 音频类型
 */
- (void)onRoomFirstAudioFrameWithPeerID:(NSString *)peerID mediaType:(YSMediaType)type;

/**
 网络测速回调
 @param networkQuality 网速质量 (YSNetQuality_Down 测速失败)
 @param delay 延迟(毫秒)
 */
- (void)onRoomNetworkQuality:(YSNetQuality)networkQuality
                   delay:(NSInteger)delay;

#pragma mark meidia
/**
    用户媒体流发布状态 变化回调
    @param peerId 用户id
    @param state 0:取消  非0：发布
    @param message 扩展消息
 */
- (void)onRoomShareMediaState:(NSString *)peerId
                               state:(YSMediaState)state
                    extensionMessage:(NSDictionary *)message;

/**
    更新媒体流的信息回调
    @param duration 媒体流当前播放的时间点
    @param pos 媒体流当前的进度
    @param isPlay 播放（YES）暂停（NO）
 */
- (void)onRoomUpdateMediaStream:(NSTimeInterval)duration
                                 pos:(NSTimeInterval)pos
                              isPlay:(BOOL)isPlay;

/**
    媒体流加载出第一帧画面回调
 */
- (void)onRoomMediaLoaded;

#pragma mark screen
/**
    用户桌面共享状态 变化回调
    @param peerId 用户id
    @param state 状态0:取消  非0：发布
 */
- (void)onRoomShareScreenState:(NSString *)peerId
                                state:(YSMediaState)state;

#pragma mark file
/**
    用户电影共享状态 变化回调
    @param peerId 用户id
    @param state 状态0:取消  非0：发布
    @param message 扩展消息
 */
- (void)onRoomShareFileState:(NSString *)peerId
                              state:(YSMediaState)state
                   extensionMessage:(NSDictionary *)message;



@end

#pragma mark - YSMediaFrameDelegate
@protocol YSMediaFrameDelegate<NSObject>

///************************该部分回调函数 均不是线程安全的************************///

@optional
/**
 本地采集的音频数据

 @param frame 音频数据
 @param type 采集源
 */
- (void)onCaptureAudioFrame:(YSAudioFrame *)frame sourceType:(YSMediaType)type;
/**
 本地采集的视频数据
 
 @param frame 视频数据
 @param type 采集源
 */
- (void)onCaptureVideoFrame:(YSVideoFrame *)frame sourceType:(YSMediaType)type;

/**
 收到远端音频数据

 @param frame 音频数据
 @param peerId 用户ID
 @param type 采集源
 */
- (void)onRenderAudioFrame:(YSAudioFrame *)frame uid:(NSString *)peerId sourceType:(YSMediaType)type;
/**
 收到远端视频数据
 
 @param frame 视频数据
 @param peerId 用户ID
 @param type 采集源
 */
- (void)onRenderVideoFrame:(YSVideoFrame *)frame uid:(NSString *)peerId sourceType:(YSMediaType)type;

/**
 收到远端某一视频设备视频数据

 @param frame 视频数据
 @param peerId 用户ID
 @param deviceId 设备ID
 @param type 采集源
 */
- (void)onRenderVideoFrame:(YSVideoFrame *)frame uid:(NSString *)peerId deviceId:(NSString *)deviceId sourceType:(YSMediaType)type;
@end



