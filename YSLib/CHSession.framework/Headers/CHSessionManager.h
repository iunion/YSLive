//
//  CHSessionManager.h
//  CHSession
//
//

#import <Foundation/Foundation.h>
#import "CHRoomModel.h"
#import "CHRoomConfiguration.h"
#import "CHRoomUser.h"
#import "CHSharedMediaFileModel.h"
#import "CHQuestionModel.h"

#import "CHSessionDelegate.h"
#import "CHSessionForWhiteBoardDelegate.h"


NS_ASSUME_NONNULL_BEGIN

@interface CHSessionManager : NSObject

/// 外部传入host地址
@property (nonatomic, strong) NSString *apiHost;
/// 外部传入port
@property (nonatomic, assign) NSUInteger apiPort;

/// 音视频SDK管理
@property (nonatomic, strong, readonly) CloudHubRtcEngineKit *cloudHubRtcEngineKit;

/// 房间相关消息回调
@property (nonatomic, weak, readonly) id <CHSessionDelegate> roomDelegate;

#pragma mark - 配置相关

/// 信令服务器尝试重连次数，0：表示无限次重连，大于0：表示重连的次数。
/// 默认是：0，无限次重连
@property (nonatomic, assign, readonly) NSUInteger reConnectAttempts;
/// 是否使用白板(是否发送白板相关消息)
@property (nonatomic, assign, readonly) BOOL hasWhiteBoard;

#pragma mark - 房间相关

/// 房间数据
@property (nonatomic, strong, readonly) NSDictionary *roomDic;
/// 房间数据
@property (nonatomic, strong, readonly) CHRoomModel *roomModel;
/// 房间配置项
@property (nonatomic, strong, readonly) CHRoomConfiguration *roomConfig;

/// 公司ID
@property (nonatomic, strong, readonly) NSString *room_Companyid;
/// 房间ID
@property (nonatomic, strong, readonly) NSString *room_Id;
/// 房间名称
@property (nonatomic, strong, readonly) NSString *room_Name;
/// 房间类型
@property (nonatomic, assign, readonly) CHRoomUseType room_UseType;

/// 视频比例 ratio 16:9
@property (nonatomic, assign, readonly) BOOL room_IsWideScreen;

/// 是否大房间
@property (nonatomic, assign) BOOL isBigRoom;

#pragma mark - 分组房间相关

/// 是否分组房间
@property (nonatomic, assign, readonly) CHRoomGroupType groupRoomType;
@property (nonatomic, assign, readonly) BOOL isGroupRoom;

/// 连接到主房间
@property (nonatomic, assign) BOOL isConnectedParentRoom;
/// 父房间授课
@property (nonatomic, assign) BOOL isParentRoomLecture;
/// 私聊中
@property (nonatomic, assign) BOOL isParentRoomChating;

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
@property (nonatomic, strong) NSMutableArray <CHRoomUser *> *userList;
@property (nonatomic, strong, readonly) NSMutableDictionary <NSString *,CHRoomUser *>*roomUsers;

/// 老师(名师)用户数据
@property (nonatomic, strong, readonly) CHRoomUser *teacher;
/// 班主任用户数据
@property (nonatomic, strong, readonly) CHRoomUser *classMaster;
/// 当前用户数据
@property (nonatomic, strong, readonly) CHRoomUser *localUser;

/// 当前本地视频镜像模式
@property (nonatomic, assign, readonly) CloudHubVideoMirrorMode localVideoMirrorMode;

/// 用户对应流Id
@property (nonatomic, strong,readonly) NSMutableDictionary *userStreamIds_userId;

/// BigRoom使用 只有超过100人后
/// 房间用户数(总人数)
@property (nonatomic, assign) NSUInteger bigRoomUserCount;
@property (nonatomic, strong) NSDictionary *userCountDetailDic;

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

/// 是否开始上课
@property (nonatomic, assign) BOOL isClassBegin;
/// 是否主教室开始上课
@property (nonatomic, assign) BOOL isGroupBegin;

/// 全体禁音
@property (nonatomic, assign) BOOL isEveryoneNoAudio;
/// 全体禁言
@property (nonatomic, assign) BOOL isEveryoneBanChat;

/// 举手上台信令的msgID的Key
@property (nonatomic, strong) NSString *raisehandMsgID;


#pragma mark - Funcs

/// SDK版本号
+ (NSString *)sessionVersion;
+ (NSString *)sessionShortVersion;
+ (NSString *)sessionBuildVersion;

/// 管理单例
+ (instancetype)sharedInstance;
/// 管理销毁
+ (void)destroy;

/// 注册相关信息
/// @param appId 应用Id
/// @param optional 相关参数
- (void)registWithAppId:(NSString *)appId settingOptional:(nullable NSDictionary *)optional;
/// 注册回调
- (void)registerRoomDelegate:(nullable id <CHSessionDelegate>)roomDelegate;
/// 支持白板回调
- (void)registerRoomForWhiteBoardDelegate:(id <CHSessionForWhiteBoardDelegate>)roomForWhiteBoardDelegate;

/// 浏览器打开app的URL解析
+ (nullable NSDictionary *)resolveJoinRoomParamsWithUrl:(NSURL *)url;

/// 进入房间
/// @param host host
/// @param port port
/// @param nickName 用户昵称
/// @param roomId 房间Id
/// @param roomPassword 房间密码
/// @param userRole 用户身份
/// @param userId 用户Id
/// @param userParams 用户属性 参见`CHRoomUser`
/// @see joinRoomWithHost:port:nickName:roomParams:userParams:
- (BOOL)joinRoomWithHost:(NSString *)host
                    port:(int)port
                nickName:(NSString *)nickName
                  roomId:(NSString *)roomId
            roomPassword:(nullable NSString *)roomPassword
                userRole:(CHUserRoleType)userRole
                  userId:(NSString *)userId
              userParams:(nullable NSDictionary *)userParams;

/// @brief 进入房间
/// @param host host
/// @param port port
/// @param nickName 用户昵称
/// @param roomParams 房间参数
/// @param userParams 用户属性 参见‘CHRoomUser’
/// @return BOOL 是否成功
/// @discussion 进入房间详细说明
- (BOOL)joinRoomWithHost:(NSString *)host
                    port:(int)port
                nickName:(NSString *)nickName
              roomParams:(NSDictionary *)roomParams
              userParams:(nullable NSDictionary *)userParams;

/// 离开房间
- (BOOL)leaveRoom:(void(^ _Nullable)(void))leaveChannelBlock;


- (void)serverLog:(NSString *)log;

#pragma mark - 用户相关Func

- (CHRoomUser *)addRoomUserWithId:(NSString *)peerId properties:(NSDictionary *)properties;

- (nullable CHRoomUser *)getRoomUserWithId:(NSString *)userId;

- (void)setBigRoomTeacher:(nullable CHRoomUser *)roomUser;

- (void)getRoomUserCountWithRole:(nullable NSArray *)role
                          search:(NSString *)search
                        callback:(void (^)(NSUInteger num, NSError * _Nonnull error))callback;

- (void)getRoomUsersWithRole:(nullable NSArray *)role
                  startIndex:(NSInteger)start
                   maxNumber:(NSInteger)max
                      search:(NSString *)search
                       order:(NSDictionary *)order
                    callback:(void (^)(NSArray<CHRoomUser *> *_Nonnull users, NSError * _Nonnull error))callback;

#pragma mark - 播放音视频管理

/// 用户流
- (nullable NSMutableArray *)getUserStreamIdsWithUserId:(NSString *)userId;
/// 共享流
- (nullable NSMutableArray *)getShareStreamIdsWithUserId:(NSString *)userId;

/// 媒体流
- (nullable CHSharedMediaFileModel *)getMediaFileModelWhithStreamId:(NSString *)streamId;
- (nullable CHSharedMediaFileModel *)getMediaFileModelWithUrl:(NSString *)url;
- (nullable NSString *)getMediaStreamIdWithUrl:(NSString *)url;
- (nullable NSArray <CHSharedMediaFileModel *> *)getAllSharedMediaFileModel;
/// 媒体流个数
- (NSUInteger)getMediaFileModelCount;

- (NSString *)getSourceIdFromStreamId:(NSString *)streamId;


#pragma mark - 本地播放音视频

- (BOOL)startPlayingMedia:(nullable NSString *)filepath;
- (BOOL)startPlayingMedia:(nullable NSString *)filepath cycle:(BOOL)cycle;
- (BOOL)stopPlayingMedia:(nullable NSString *)filepath;
- (BOOL)pausePlayingMedia:(nullable NSString *)filepath;
- (BOOL)resumePlayingMedia:(nullable NSString *)filepath;


#pragma mark - 接收流操作 上台流 媒体流 共享流

/// 切换前后摄像头
- (BOOL)useFrontCamera:(BOOL)front;

/// 播放新视频流changeVideoWithUserId
- (BOOL)playVideoWithUserId:(NSString *)userId
                   streamID:(nullable NSString * )streamId
                 renderMode:(CloudHubVideoRenderMode)renderMode
                 mirrorMode:(CloudHubVideoMirrorMode)mirrorMode
                     inView:(UIView *)view;

/// 设置音视频流
- (BOOL)changeVideoWithUserId:(NSString *)userId
                     streamID:(nullable NSString * )streamId
                   renderMode:(CloudHubVideoRenderMode)renderMode
                   mirrorMode:(CloudHubVideoMirrorMode)mirrorMode;

/// 停止音视频流
- (BOOL)stopVideoWithUserId:(NSString *)userId
                   streamID:(nullable NSString * )streamId;

#pragma mark - setUserProperty

- (BOOL)setPropertyOfUid:(NSString *)uid tell:(nullable NSString *)whom propertyKey:(NSString *)key value:(id)value;

- (BOOL)setPropertyOfUid:(NSString *)uid tell:(nullable NSString *)whom properties:(NSDictionary *)prop;

/// 设置本地视频镜像
- (BOOL)changeLocalVideoMirrorMode:(CloudHubVideoMirrorMode)mode;

/// 踢人
- (BOOL)evictUser:(NSString *)uid reason:(NSInteger)reasonCode;

/// 改变自己的音视频状态，并管理音视频流
//- (void)changeMyMediaPublishState:(CHUserMediaPublishState)mediaPublishState;

@end


#pragma mark -
#pragma mark GetSignaling

@interface CHSessionManager (GetSignaling)

/// 收到自定义发布信令
- (void)handleRoomPubMsgWithMsgID:(NSString *)msgID
                          msgName:(NSString *)msgName
                          dataDic:(nullable NSDictionary *)dataDic
                           fromID:(NSString *)fromID
                    extensionData:(nullable NSDictionary *)extensionData
                        isHistory:(BOOL)isHistory
                               ts:(long)ts;

/// 收到自定义删除信令
- (void)handleRoomDelMsgWithMsgID:(NSString *)msgID
                          msgName:(NSString *)msgName
                          dataDic:(nullable NSDictionary *)dataDic
                           fromID:(NSString *)fromID;


@end


#pragma mark -
#pragma mark SendSignaling

@interface CHSessionManager (SendSignaling)

- (BOOL)pubMsg:(NSString *)msgName
         msgId:(NSString *)msgId
            to:(nullable NSString *)whom
      withData:(nullable NSDictionary *)data
          save:(BOOL)save;

- (BOOL)pubMsg:(NSString *)msgName
        msgId:(NSString *)msgId
           to:(NSString *)whom
     withData:(NSDictionary *)data
extensionData:(NSDictionary *)extensionData
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


/// 客户端请求关闭信令服务器房间
- (BOOL)sendSignalingDestroyServerRoom;

#pragma mark - 同步服务器时间

- (BOOL)sendSignalingUpdateTime;

#pragma mark - 同步自己的属性

/// 上台时同步自己的属性，自己的 Publishstate 发送 CHUser_PublishState_BOTH
- (BOOL)sendSignalingSyncProperty;


#pragma -
#pragma mark 老师相关

#pragma mark - 上下课

/// 老师发起上课
- (BOOL)sendSignalingTeacherToClassBegin;

/// 老师发起下课
- (BOOL)sendSignalingTeacherToDismissClass;

#pragma mark - 轮播

/// 老师发起轮播
- (BOOL)sendSignalingTeacherToStartVideoPollingWithUserID:(NSString *)peerId;
/// 老师停止轮播
- (BOOL)sendSignalingTeacherToStopVideoPolling;

/// 全体静音 isNoAudio:YES 静音  NO：不静音
- (BOOL)sendSignalingTeacherToLiveAllNoAudio:(BOOL)isNoAudio;

/// 全体禁言 + 解除全体禁言
- (BOOL)sendSignalingTeacherToLiveAllNoChatSpeakingWithNotAllow:(BOOL)isNotAllow;

#pragma mark - 送花

/// 送花
- (BOOL)sendSignalingLiveNoticesSendFlower;

#pragma mark - 举手

/// 通知各端开始举手
- (BOOL)sendSignalingToLiveAllAllowRaiseHand;

/// 老师订阅/取消订阅举手列表   type  subSort订阅/  unsubSort取消订阅
- (BOOL)sendSignalingToSubscribeAllRaiseHandMemberWithType:(NSString*)type;

/// 学生开始/取消举手  modify：0举手  1取消举手
- (BOOL)sendSignalingsStudentToRaiseHandWithModify:(NSInteger)modify;

#pragma mark - 布局

/// 改变布局
- (BOOL)sendSignalingToChangeLayoutWithLayoutType:(CHRoomLayoutType)layoutType;

- (BOOL)sendSignalingToChangeLayoutWithLayoutType:(CHRoomLayoutType)layoutType appUserType:(CHRoomUseType)appUserType withFouceUserId:(nullable NSString *)peerId withStreamId:(nullable NSString *)streamId;

/// 拖出视频 + 缩放视频
- (BOOL)sendSignalingTopinchVideoViewWithPeerId:(NSString *)peerId withStreamId:(NSString *)streamId withData:(NSDictionary *)dictData;

/// 发送双击视频放大
- (BOOL)sendSignalingToDoubleClickVideoViewWithPeerId:(NSString *)peerId withStreamId:(NSString *)streamId;

/// 取消双击视频放大
- (BOOL)deleteSignalingToDoubleClickVideoView;


#pragma mark - 投票

// 发送投票
- (BOOL)sendSignalingVoteCommitWithVoteId:(NSString *)voteId voteResault:(NSArray *)voteResault;


#pragma mark - 答题器

/// 答题器占用
- (BOOL)sendSignalingTeacherToAnswerOccupyed;

/// 发布答题器
- (BOOL)sendSignalingTeacherToAnswerWithOptions:(NSArray *)answers answerID:(NSString *)answerID;

/// 发送答题卡答案（学生）
- (BOOL)sendSignalingAnwserCommitWithAnswerId:(NSString *)answerId anwserResault:(NSArray *)answerResault;

/// 修改答题卡答案（学生）
- (BOOL)sendSignalingAnwserModifyWithAnswerId:(NSString *)answerId addAnwserResault:(nullable NSArray *)addAnwserResault  delAnwserResault:(nullable NSArray *)delAnwserResault notChangeAnwserResault:(nullable NSArray *)notChangeAnwserResault;

/// 获取答题器进行时的结果
- (BOOL)sendSignalingTeacherToAnswerGetResultWithAnswerID:(NSString *)answerID;

/// 结束答题
- (BOOL)sendSignalingTeacherToDeleteAnswerWithAnswerID:(NSString *)answerID;

/// 发布答题结果
/// @param answerID 答题ID
/// @param selecteds 统计数据
/// @param duration 答题时间
/// @param detailData 详情数据
- (BOOL)sendSignalingTeacherToAnswerPublicResultWithAnswerID:(NSString *)answerID selecteds:(NSDictionary *)selecteds duration:(NSString *)duration detailData:(NSArray *)detailData totalUsers:(NSInteger)totalUsers;

/// 结束答题结果
- (BOOL)sendSignalingTeacherToDeleteAnswerPublicResult;


#pragma mark - 抢答器

/// 抢答器  开始
- (BOOL)sendSignalingTeacherToStartResponder;

/// 关闭抢答器
- (BOOL)sendSignalingTeacherToCloseResponder;

/// 助教、老师发起抢答排序
- (BOOL)sendSignalingTeacherToContestResponderWithMaxSort:(NSInteger)maxSort;

/// 结束抢答排序
- (BOOL)sendSignalingTeacherToDeleteContest;

/// 学生抢答
- (BOOL)sendSignalingStudentContestCommit;

/// 发布抢答器结果
- (BOOL)sendSignalingTeacherToContestResultWithName:(NSString *)name;

/// 订阅抢答排序
- (BOOL)sendSignalingTeacherToContestSubsortWithMin:(NSInteger)min max:(NSInteger)max;

/// 取消订阅抢答排序
- (BOOL)sendSignalingTeacherToCancelContestSubsort;


#pragma mark - 计时器
/// 计时器
/// @param time 计时器时间
/// @param isStatus 当前状态 暂停 继续
/// @param isRestart 重置是否
/// @param isShow 是否显示弹窗  老师第一次点击计时器传false  老师显示，老师点击开始计时，传true ，学生显示
/// @param defaultTime 开始计时时间
- (BOOL)sendSignalingTeacherToStartTimerWithTime:(NSInteger)time isStatus:(BOOL)isStatus isRestart:(BOOL)isRestart isShow:(BOOL)isShow defaultTime:(NSInteger)defaultTime;

/// 结束计时
- (BOOL)sendSignalingTeacherToDeleteTimer;
@end


#pragma mark -
#pragma mark 即时消息相关操作

@interface CHSessionManager (Message)

/// 发送消息数据
- (BOOL)sendMessage:(NSString *)message to:(NSString *)whom withExtraData:(NSDictionary *)extraData;

/// 发送文本消息
- (BOOL)sendMessageWithText:(NSString *)message withMessageType:(CHChatMessageType)messageType withMemberModel:(nullable CHRoomUser *)memberModel;

/// 系统配置提示消息
// @param message 消息内容
// @param peerID 发送者用户ID
// @param tipType 提示类型
- (void)sendTipMessage:(NSString *)message tipType:(CHChatMessageType)tipType;

/// 发送提问
// @return  QuestionID问题唯一标识 非nil表示调用成功，nil表示调用失败
- (nullable NSString *)sendQuestionWithText:(NSString *)textMessage;

@end


#pragma mark -
#pragma mark 媒体文件发送流操作

@interface CHSessionManager (ShareMediaFile)

/*
 { type: 'media',
 source: 'mediaFileList',
 filename: '产品-嘉实多磁护PUMA视频-2分12秒.mp4',
 fileid: 235497,
 pauseWhenOver: false }
 */
- (BOOL)startSharedMediaFile:(NSString *)mediaPath
                     isVideo:(BOOL)isVideo
                        toID:(nullable NSString *)toID
                  attributes:(NSDictionary *)attributes;

- (BOOL)stopSharedMediaFile:(NSString *)mediaPath;

- (void)pauseSharedMediaFile:(NSString *)mediaPath isPause:(BOOL)isPause;
- (void)seekSharedMediaFile:(NSString *)mediaPath positionByMS:(NSUInteger)position;

- (BOOL)stopAllSharedMediaFile;

@end

NS_ASSUME_NONNULL_END
