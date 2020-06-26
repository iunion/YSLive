//
//  YSSessionManager.h
//  YSSession
//
//  Created by jiang deng on 2020/6/10.
//  Copyright © 2020 YS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YSRoomModel.h"
#import "YSRoomConfiguration.h"
#import "YSRoomUser.h"
#import "YSSharedMediaFileModel.h"

NS_ASSUME_NONNULL_BEGIN

@class CloudHubRtcEngineKit;

@interface YSSessionManager : NSObject

#pragma mark - 设置

/// host地址
@property (nonatomic, strong) NSString *apiHost;
/// port
@property (nonatomic, assign) NSUInteger apiPort;


@property (nonatomic, strong, readonly) CloudHubRtcEngineKit *cloudHubRtcEngineKit;

@property (nonatomic, weak, readonly) id <YSSessionDelegate> roomDelegate;

@property (nonatomic, strong, readonly) NSString *webServerIP;
@property (nonatomic, assign, readonly) int webServerPort;

#pragma mark - 房间相关

/// 房间数据
@property (nonatomic, strong, readonly) NSDictionary *roomDic;
/// 房间数据
@property (nonatomic, strong, readonly) YSRoomModel *roomModel;
/// 房间配置项
@property (nonatomic, strong, readonly) YSRoomConfiguration *roomConfig;

/// 公司ID
@property (nonatomic, strong, readonly) NSString *room_Companyid;
/// 房间ID
@property (nonatomic, strong, readonly) NSString *room_Id;
/// 房间名称
@property (nonatomic, strong, readonly) NSString *room_Name;
/// 房间类型
@property (nonatomic, assign, readonly) YSRoomUseType room_UseType;

/// 视频比例 ratio 16:9
@property (nonatomic, assign, readonly) BOOL room_IsWideScreen;

/// 是否大房间
@property (nonatomic, assign, readonly) BOOL isBigRoom;


#pragma mark - 时间相关

/// 服务器时间与本地时间差 tServiceTime-now
@property (nonatomic, assign) NSTimeInterval tHowMuchTimeServerFasterThenMe;

/// 当前服务器时间 now+tHowMuchTimeServerFasterThenMe
@property (nonatomic, assign, readonly) NSTimeInterval tCurrentTime;

/// 上课开始时间
@property (nonatomic, assign) NSTimeInterval tClassBeginTime;
/// 上课时长
@property (nonatomic, assign, readonly) NSTimeInterval tPassedTime;


#pragma mark - 用户相关

/// 房间用户列表，大房间时只保留上台用户
@property (nonatomic, strong, readonly) NSMutableArray <YSRoomUser *> *userList;
@property (nonatomic, strong, readonly) NSMutableDictionary <NSString *,YSRoomUser *>*roomUsers;

/// 老师用户数据
@property (nonatomic, strong, readonly) YSRoomUser *teacher;
/// 当前用户数据
@property (nonatomic, strong, readonly) YSRoomUser *localUser;

/// 当前本地视频镜像模式
@property (nonatomic, assign, readonly) CloudHubVideoMirrorMode localVideoMirrorMode;


/// BigRoom使用 只有超过100人后
/// 房间用户数(总人数)
@property (nonatomic, assign, readonly) NSUInteger userCount;
@property (nonatomic, strong, readonly) NSDictionary *userCountDetailDic;

/// 0老师 普通房间可用
@property (nonatomic, assign, readonly) NSUInteger teacherCount;
/// 1助教 普通房间可用
@property (nonatomic, assign, readonly) NSUInteger assistantCount;
/// 2学生 普通房间可用
@property (nonatomic, assign, readonly) NSUInteger studentCount;
/// 3直播
@property (nonatomic, assign, readonly) NSUInteger liveCount;
/// 4巡课
@property (nonatomic, assign, readonly) NSUInteger patrolCount;
/// 5班主任
@property (nonatomic, assign, readonly) NSUInteger masterCount;


#pragma mark - 设备状态

/// 是否低性能设备
@property (nonatomic, assign, readonly) BOOL devicePerformance_Low;

/// 设备前后台状态
@property (nonatomic, assign, readonly) BOOL isInBackGround;


#pragma mark - 信令管理

/// 上层是否准备完毕，可以相应信令消息， YES：通过roomDelegate向下转发 NO：在cacheMsgPool中暂存信令消息直到YES
@property (nonatomic, assign) BOOL readyToHandleMsg;
/// 消息缓存数据
@property (nonatomic, strong, readonly) NSMutableArray *cacheMsgPool;


/// 是否开始上课
@property (nonatomic, assign) BOOL isClassBegin;

/// 全体禁音
@property (nonatomic, assign) BOOL isEveryoneNoAudio;


#pragma mark - ShareMediaFile

/// 支持一路媒体课件时的媒体数据
@property (nullable, nonatomic, strong) YSSharedMediaFileModel *mediaFileModel;


+ (instancetype)sharedInstance;
+ (void)destory;

- (void)registWithAppId:(NSString *)appId settingOptional:(nullable NSDictionary *)optional;
- (void)registerRoomDelegate:(nullable id <YSSessionDelegate>)roomDelegate;
- (void)registerRoomForWhiteBoardDelegate:(nullable id <YSSessionForWhiteBoardDelegate>)roomForWhiteBoardDelegate;

/// 浏览器打开app的URL解析
+ (nullable NSDictionary *)resolveJoinRoomParamsWithUrl:(NSURL *)url;

- (BOOL)joinRoomWithHost:(NSString *)host
                    port:(int)port
                nickName:(NSString *)nickName
                  roomId:(NSString *)roomId
            roomPassword:(nullable NSString *)roomPassword
                userRole:(YSUserRoleType)userRole
                  userId:(NSString *)userId
              userParams:(nullable NSDictionary *)userParams;

- (BOOL)joinRoomWithHost:(NSString *)host
                    port:(int)port
                nickName:(NSString *)nickname
              roomParams:(NSDictionary *)roomParams
              userParams:(nullable NSDictionary *)userParams;

- (BOOL)leaveRoom:(void(^ _Nullable)(void))leaveChannelBlock;

- (void)serverLog:(NSString *)log;


- (void)addMsgCachePoolWithMethodName:(SEL)selector parameters:(NSArray *)parameters;

- (NSString *)getProtocol;


- (YSRoomUser *)getRoomUserWithId:(NSString *)userId;
- (BOOL)getRoomUserWithId:(NSString *)userId callback:(void (^)(YSRoomUser *user, NSError *error))callback;



#pragma mark - 接收流操作 上台流 媒体流 共享流

- (BOOL)playVideoWithUserId:(NSString *)userId
                   sourceId:(nullable NSString *)sourceId
                 renderMode:(CloudHubVideoRenderMode)renderMode
                 mirrorMode:(CloudHubVideoMirrorMode)mirrorMode
                     inView:(UIView *)view;

- (BOOL)changeVideoWithUserId:(NSString *)userId
                     sourceID:(NSString* _Nullable)sourceID
                   renderMode:(CloudHubVideoRenderMode)renderMode
                   mirrorMode:(CloudHubVideoMirrorMode)mirrorMode;

- (BOOL)stopVideoWithUserId:(NSString *)userId
                   sourceId:(nullable NSString *)sourceId;


#pragma mark - setUserProperty

- (BOOL)setPropertyOfUid:(NSString *)uid tell:(nullable NSString *)whom propertyKey:(NSString *)key value:(id)value;

- (BOOL)setPropertyOfUid:(NSString *)uid tell:(nullable NSString *)whom properties:(NSDictionary *)prop;

/// 设置本地视频镜像
- (BOOL)changeLocalVideoMirrorMode:(CloudHubVideoMirrorMode)mode;


@end


#pragma mark -
#pragma mark GetSignaling

@interface YSSessionManager (GetSignaling)

/// 收到自定义发布信令
- (void)handleRoomPubMsgWithMsgID:(NSString *)msgID
                          msgName:(NSString *)msgName
                          dataDic:(nullable NSDictionary *)dataDic
                           fromID:(NSString *)fromID
                           inList:(BOOL)inlist
                               ts:(long)ts;

/// 收到自定义删除信令
- (void)handleRoomDelMsgWithMsgID:(NSString *)msgID
                          msgName:(NSString *)msgName
                          dataDic:(nullable NSDictionary *)dataDic
                           fromID:(NSString *)fromID
                           inList:(BOOL)inlist
                               ts:(long)ts;


@end


#pragma mark -
#pragma mark SendSignaling

@interface YSSessionManager (SendSignaling)

- (BOOL)pubMsg:(NSString *)msgName
         msgId:(NSString *)msgId
            to:(nullable NSString *)whom
      withData:(nullable NSDictionary *)data
          save:(BOOL)save;

- (BOOL)pubMsg:(NSString *)msgName
         msgId:(NSString *)msgId
            to:(nullable NSString *)whom
      withData:(nullable NSDictionary *)data
associatedWithUser:(nullable NSString *)uid
associatedWithMsg:(nullable NSString *)assMsgID
          save:(BOOL)save;

- (BOOL)pubMsg:(NSString *)msgName
         msgId:(NSString *)msgId
            to:(nullable NSString *)whom
      withData:(nullable NSDictionary *)data
 extensionData:(nullable NSDictionary *)extensionData
associatedWithUser:(nullable NSString *)uid
associatedWithMsg:(nullable NSString *)assMsgID
          save:(BOOL)save;


- (BOOL)delMsg:(NSString *)msgName
         msgId:(NSString *)msgId
            to:(nullable NSString *)whom;

- (BOOL)delMsg:(NSString *)msgName
         msgId:(NSString *)msgId
            to:(nullable NSString *)whom
      withData:(nullable NSDictionary *)data;


#pragma mark - 投票

// 发送投票
- (BOOL)sendSignalingVoteCommitWithVoteId:(NSString *)voteId voteResault:(NSArray *)voteResault;


@end


#pragma mark -
#pragma mark 即时消息相关操作

@interface YSSessionManager (Message)

/// 发送消息数据
- (BOOL)sendMessage:(NSString *)message to:(NSString *)whom withExtraData:(NSDictionary *)extraData;

/// 发送文本消息
- (BOOL)sendMessageWithText:(NSString *)message withMessageType:(YSChatMessageType)messageType withMemberModel:(nullable YSRoomUser *)memberModel;

/// 收到聊天消息
// @param message 聊天消息内容
// @param peerID 发送者用户ID
// @param extension 消息扩展信息（用户昵称、用户角色等等）
- (void)handleMessageReceived:(NSString *)message fromID:(NSString *)peerID extension:(NSDictionary *)extension;

/// 系统配置提示消息
// @param message 消息内容
// @param peerID 发送者用户ID
// @param tipType 提示类型
- (void)sendTipMessage:(NSString *)message tipType:(YSChatMessageType)tipType;

/// 发送提问
// @return  QuestionID问题唯一标识 非nil表示调用成功，nil表示调用失败
- (nullable NSString *)sendQuestionWithText:(NSString *)textMessage;

@end


#pragma mark -
#pragma mark 媒体文件发送流操作

@interface YSSessionManager (ShareMediaFile)

/*
 { type: 'media',
 source: 'mediaFileList',
 filename: '产品-嘉实多磁护PUMA视频-2分12秒.mp4',
 fileid: 235497,
 pauseWhenOver: false }
 */
- (BOOL)startShareMediaFile:(NSString *)mediaPath
                    isVideo:(BOOL)isVideo
                       toID:(nullable NSString *)toID
                 attributes:(NSDictionary *)attributes;

- (BOOL)stopShareMediaFile:(NSString *)mediaPath;

- (void)pauseShareMediaFile:(NSString *)mediaPath isPause:(BOOL)isPause;
- (void)seekShareMediaFile:(NSString *)mediaPath positionByMS:(NSUInteger)position;

- (BOOL)stopShareOneMediaFile;

- (void)pauseShareOneMediaFile:(BOOL)isPause;
- (void)seekShareOneMediaFile:(NSUInteger)position;

@end


NS_ASSUME_NONNULL_END
