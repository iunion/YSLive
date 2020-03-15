//
//  YSLiveManager.h
//  YSLive
//
//  Created by jiang deng on 2019/10/14.
//  Copyright © 2019 FS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YSLiveMacros.h"
#import "YSLiveSignaling.h"

#import "YSLiveRoomConfiguration.h"
#import "YSRoomUser+YSLive.h"


NS_ASSUME_NONNULL_BEGIN

@class YSLiveMediaModel;

@class YSChatMessageModel;
@class YSQuestionModel;

@protocol YSLiveRoomManagerDelegate;

@interface YSLiveManager : NSObject

/// host地址
@property (nonatomic, strong) NSString *liveHost;

/// 网校api接口host地址
@property (nonatomic, strong) NSString *schoolHost;

#if YSSDK
@property (nullable, nonatomic, weak) id <YSLiveRoomManagerDelegate> sdkDelegate;
// 区分是否进入教室
@property (nonatomic, assign) BOOL sdkIsJoinRoom;
#endif

@property (nullable, nonatomic, weak) id <YSLiveRoomManagerDelegate> roomManagerDelegate;
//@property (nullable, nonatomic, weak) id <YSWhiteBoardManagerDelegate> whiteBoardManagerDelegate;

/// 房间音视频管理
@property (nonatomic, strong, readonly) YSRoomInterface *roomManager;
/// 白板管理
@property (nonatomic, strong, readonly) YSWhiteBoardManager *whiteBoardManager;
/// 白板视图whiteBord
@property (nonatomic, strong, readonly) UIView *whiteBordView;

/// 设备性能是否低
@property (nonatomic, assign, readonly) BOOL devicePerformance_Low;


/// 文件服务器地址
@property (nonatomic, strong, readonly) NSString *fileServer;

/// 房间数据
@property (nonatomic, strong, readonly) NSDictionary *roomDic;
/// 房间配置项
@property (nonatomic, strong, readonly) YSLiveRoomConfiguration *roomConfig;
/// 公司ID
@property (nonatomic, strong, readonly) NSString *room_Companyid;
/// 房间ID
@property (nonatomic, strong, readonly) NSString *room_Id;
/// 房间名称
@property (nonatomic, strong, readonly) NSString *room_Name;
@property (nonatomic, assign, readonly) YSAppUseTheType room_UseTheType;

/// 房间可用时间区间开始时间戳
@property (nonatomic, assign, readonly) NSTimeInterval room_StartTime;
/// 房间可用时间区间结束时间戳
@property (nonatomic, assign, readonly) NSTimeInterval room_EndTime;
/// ratio 16:9
@property (nonatomic, assign, readonly) BOOL room_IsWideScreen;

/// 当前设备音量  音量大小 0 ～ 32670
@property (nonatomic, assign) NSUInteger iVolume;


// 等待重连
@property (nonatomic, assign) BOOL waitingForReconnect;


/// 白板

/// 课件列表
@property (nonatomic, strong, readonly) NSArray <YSFileModel *> *fileList;
/// 当前课件数据
@property (nonatomic, strong, readonly) YSFileModel *currentFile;


/// 是否大房间
@property (nonatomic, assign, readonly) BOOL isBigRoom;

/// 房间用户列表，大房间时只保留上台用户
@property (nonatomic, strong, readonly) NSMutableArray <YSRoomUser *> *userList;

/// 老师数据
@property (nonatomic, strong, readonly) YSRoomUser *teacher;
/// 当前用户
@property (nonatomic, strong, readonly) YSRoomUser *localUser;

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



/// 全体禁言
@property (nonatomic, assign) BOOL isEveryoneBanChat;
/// 是否打开上麦功能
@property (nonatomic, assign) BOOL allowEveryoneUpPlatform;
/// 全体禁音
@property (nonatomic, assign) BOOL isEveryoneNoAudio;

/// 进入房间时的服务器时间
@property (nonatomic, assign) NSTimeInterval tServiceTime;
/// 服务器时间与本地时间差
@property (nonatomic, assign) NSTimeInterval tHowMuchTimeServerFasterThenMe;

/// 上课开始时间
@property (nonatomic, assign) NSTimeInterval tClassStartTime;
// 矫正过的时间
/// 当前时间 now-tHowMuchTimeServerFasterThenMe
@property (nonatomic, assign, readonly) NSTimeInterval tCurrentTime;
/// 开播经过时长
@property (nonatomic, assign, readonly) NSTimeInterval tPassedTime;


/// 视窗准备完毕
@property (nonatomic, assign) BOOL viewDidAppear;
/// 消息缓存数据
@property (nonatomic, strong, readonly) NSMutableArray *cacheMsgPool;

/// 记录UI层是否开始上课
@property (nonatomic, assign) BOOL isBeginClass;

/// 记录UI层是否正在播放媒体
@property (nonatomic, assign) BOOL playingMedia;
/// 当前播放课件媒体
@property (nonatomic, strong, readonly) YSLiveMediaModel *playMediaModel;

/// 当前共享桌面用户Id
@property (nonatomic, strong, readonly) NSString *sharePeerId;


/// 是否是回放
@property (nonatomic, assign) BOOL isPlayback;


/// 浏览器打开app的URL解析
+ (nullable NSDictionary *)resolveJoinRoomParamsWithUrl:(NSURL *)url;

+ (instancetype)shareInstance;
- (void)destroy;

- (void)registerRoomManagerDelegate:(nullable id <YSLiveRoomManagerDelegate>)RoomManagerDelegate;

- (BOOL)joinRoomWithHost:(NSString *)host port:(int)port nickName:(NSString *)nickName roomId:(NSString *)roomId roomPassword:(nullable NSString *)roomPassword userRole:(YSUserRoleType)userRole userId:(nullable NSString *)userId userParams:(nullable NSDictionary *)userParams needCheckPermissions:(BOOL)needCheckPermissions;

- (BOOL)joinRoomWithHost:(NSString *)host port:(int)port nickName:(NSString *)nickname roomParams:(NSDictionary *)roomParams userParams:(nullable NSDictionary *)userParams needCheckPermissions:(BOOL)needCheckPermissions;


- (void)doMsgCachePool;

/// 判断设备是否是高端机型，能否支持多人上台
- (BOOL)devicePlatformLowEndEquipment;


#pragma mark - 房间 对外接口

/// 旋转窗口
- (BOOL)setDeviceOrientation:(UIDeviceOrientation)orientation;

/// 退出房间
- (void)leaveRoom:(completion_block _Nullable)block;
- (void)leaveRoom:(BOOL)force completion:(completion_block _Nullable)block;

#if YSSDK
/// SDK退出房间，需要在房间返回时调用dismissViewControllerAnimated:completion:
- (void)onSDKRoomLeft;
#endif

/// 设置视频分辨率
- (void)setVideoProfile:(YSVideoProfile *)videoProfile;

/// 打开视频
- (int)playVideoOnView:(UIView *)view withPeerId:(NSString *)peerID renderType:(YSRenderMode)renderType completion:(nullable completion_block)completion;
/// 关闭视频
- (void)stopPlayVideo:(NSString *)peerID completion:(void (^_Nullable)(NSError *error))block;

/// 打开音频
- (int)playAudio:(NSString *)peerID completion:(nullable completion_block)completion;
/// 关闭音频
- (void)stopPlayAudio:(NSString *)peerID completion:(void (^_Nullable)(NSError *error))block;
/// 关闭媒体流
- (void)unpublishMedia:(void (^_Nullable)(NSError *))block;

/// 房间内各身份人数
- (NSUInteger)userCountWithUserRole:(YSUserRoleType)role;
/// 大房间时，用户下台需要清理房间用户列表 userList
- (void)removeUserWhenBigRoomWithPeerId:(NSString *)peerId;
//- (void)freshUserList;

- (YSFileModel *)getFileWithFileID:(NSString *)fileId;

@end

@protocol YSLiveRoomManagerDelegate <YSRoomInterfaceDelegate>

@optional

/// 进入前台
- (void)handleEnterForeground;

/// 进入后台
- (void)handleEnterBackground;

/// 用户进入
- (void)roomManagerJoinedUser:(YSRoomUser *)user inList:(BOOL)inList;
/// 用户退出
- (void)roomManagerLeftUser:(YSRoomUser *)user;

- (void)roomManagerRoomTeacherEnter;
- (void)roomManagerRoomTeacherLeft;

- (void)roomManagerReportFail:(YSRoomErrorCode)errorCode descript:(NSString *)descript;
- (void)roomManagerNeedEnterPassWord:(YSRoomErrorCode)errorCode;

#pragma mark 房间状态变为大房间
- (void)roomManagerChangeToBigRoom;

#pragma mark 网络状态
/// 自己的网络状态变化
- (void)roomManagerUserChangeNetStats:(id)stats;
/// 老师主播的网络状态变化
- (void)roomManagerTeacherChangeNetStats:(id)stats;

#pragma mark 用户网络差，被服务器切换媒体线路
- (void)roomManagerChangeMediaLine;


#pragma mark get Message
/// 收到信息
- (void)handleMessageWith:(YSChatMessageModel *)message;



#pragma mark 房间视频/音频

- (void)handleSelfAudioVolumeChanged;
- (void)handleOtherAudioVolumeChangedWithPeerID:(NSString *)peeID volume:(NSUInteger)volume;


/// 继续播放房间视频
- (void)handleRoomPlayMediaWithPeerID:(NSString *)peerID;
/// 暂停房间视频
- (void)handleRoomPauseMediaWithPeerID:(NSString *)peerID;

/// 继续播放房间音频
- (void)handleRoomPlayAudioWithPeerID:(NSString *)peerID;
/// 暂停房间音频
- (void)handleRoomPauseAudioWithPeerID:(NSString *)peerID;

#pragma mark 白板视频/音频

/// 播放白板视频/音频
- (void)handleWhiteBordPlayMediaFileWithMedia:(YSLiveMediaModel *)mediaModel;
/// 停止白板视频/音频
- (void)handleWhiteBordStopMediaFileWithMedia:(YSLiveMediaModel *)mediaModel;
/// 继续播放白板视频/音频
- (void)handleWhiteBordPlayMediaStream;
/// 暂停白板视频/音频
- (void)handleWhiteBordPauseMediaStream;

#pragma mark 共享桌面

/// 开始桌面共享
- (void)handleRoomStartShareDesktopWithPeerID:(NSString *)peerID;
/// 停止桌面共享
- (void)handleRoomStopShareDesktopWithPeerID:(NSString *)peerID;


#pragma mark get Signaling
// 收到信令

/// 同步服务器时间
- (BOOL)handleSignalingUpdateTimeWithTimeInterval:(NSTimeInterval)TimeInterval;

/// 房间即将关闭消息
- (BOOL)handleSignalingPrepareRoomEndWithDataDic:(NSDictionary *)dataDic addReason:(YSPrepareRoomEndType)reason;
/// 取消房间即将关闭消息,只取消YSPrepareRoomEndType_TeacherLeaveTimeout
- (void)stopSignalingLivePrepareRoomEnd_TeacherLeaveTimeout;

///房间踢除所有用户消息
- (void)handleSignalingEvictAllRoomUseWithDataDic:(NSDictionary *)dataDic;



/// 上课
- (void)handleSignalingClassBeginWihInList:(BOOL)inlist;
/// 下课
- (void)handleSignalingClassEndWithText:(NSString *)text;

/// 窗口布局变化
- (void)handleSignalingSetRoomLayout:(YSLiveRoomLayout)roomLayout;
- (void)handleSignalingDefaultRoomLayout;

/// 拖出/放回视频窗口
- (void)handleSignalingDragOutVideoWithPeerId:(NSString *)peerId atPercentLeft:(CGFloat)percentLeft percentTop:(CGFloat)percentTop isDragOut:(BOOL)isDragOut;
/// 拖出视频窗口拉伸 根据本地默认尺寸scale
- (void)handleSignalingDragOutVideoChangeSizeWithPeerId:(NSString *)peerId scale:(CGFloat)scale;
/// 双击视频最大化
- (void)handleSignalingDragOutVideoChangeFullSizeWithPeerId:(nullable NSString *)peerId isFull:(BOOL)isFull;

/// 显示白板视频标注
- (void)handleSignalingShowVideoWhiteboardWithData:(NSDictionary *)data videoRatio:(CGFloat)videoRatio;
/// 绘制白板视频标注
- (void)handleSignalingDrawVideoWhiteboardWithData:(NSDictionary *)data inList:(BOOL)inlist;
/// 隐藏白板视频标注
- (void)handleSignalingHideVideoWhiteboard;

// stateType    0--1分钟  1--3分钟  2--5分钟  3--10分钟  4--30分钟
/// 收到点名
- (void)handleSignalingLiveCallRollWithStateType:(NSUInteger)stateType callRollId:(NSString *)callRollId apartTimeInterval:(NSTimeInterval)apartTimeInterval;
/// 结束点名
- (void)closeSignalingLiveCallRoll;

/// 抽奖
- (void)handleSignalingLiveLuckDraw;
/// 中奖结果
- (void)handleSignalingLiveLuckDrawResultWithNameList:(NSArray *)nameList withEndTime:(NSString *)endTime;
/// 抽奖结束
- (void)closeSignalingLiveLuckDraw;

/// 投票
/// @param voteId 投票ID
/// @param userName 发起人
/// @param subject 主题
/// @param time 发起时间
/// @param desc 详情
/// @param multi 多选单选
/// @param voteList 投票内容
- (void)handleSignalingVoteStartWithVoteId:(NSString *)voteId userName:(NSString *)userName subject:(NSString *)subject time:(NSString *)time desc:(NSString *)desc isMulti:(BOOL)multi voteList:(NSArray <NSString *> *)voteList;

/// 投票结果
/// @param voteId 投票ID
/// @param userName 发起人
/// @param subject 主题
/// @param time 发起时间
/// @param desc 详情
/// @param multi 多选单选
/// @param voteResult 投票内容
- (void)handleSignalingVoteResultWithVoteId:(NSString *)voteId userName:(NSString *)userName subject:(NSString *)subject time:(NSString *)time desc:(NSString *)desc isMulti:(BOOL)multi voteResult:(NSArray <NSDictionary *> *)voteResult;
/// 投票结束
- (void)handleSignalingVoteEndWithVoteId:(NSString *)voteId;


/// 通知
- (void)handleSignalingLiveNoticeInfoWithNotice:(NSString *)text timeInterval:(NSUInteger)timeInterval;
/// 公告
- (void)handleSignalingLiveNoticeBoardWithNotice:(NSString *)text timeInterval:(NSUInteger)timeInterval;

/// 提问 确认 回答
- (void)handleSignalingQuestionResponedWithQuestion:(YSQuestionModel *)question;
/// 删除提问
- (void)handleSignalingDeleteQuestionWithQuestionId:(NSString *)questionId;

/// 送花
- (void)handleSignalingSendFlowerWithSenderId:(NSString *)senderId senderName:(NSString *)senderName;

/// 收到答题卡占位
- (void)handleSignalingAnswerOccupyedWithAnswerId:(NSString *)answerId startTime:(NSInteger)startTime;
/// 收到答题卡
- (void)handleSignalingSendAnswerWithAnswerId:(NSString *)answerId options:(NSArray *)options startTime:(NSInteger)startTime fromID:(NSString *)fromID;
/// 收到学生的答题情况
- (void)handleSignalingTeacherAnswerGetResultWithAnswerId:(NSString *)answerId totalUsers:(NSInteger)totalUsers values:(NSDictionary *)values ;
/// 答题结果
- (void)handleSignalingAnswerPublicResultWithAnswerId:(NSString *)answerId resault:(NSDictionary *)resault durationStr:(NSString *)durationStr answers:(NSArray *)answers totalUsers:(NSUInteger)totalUsers;
/// 答题结束
/// @param answerId 答题ID
- (void)handleSignalingAnswerEndWithAnswerId:(NSString *)answerId fromID:(NSString *)fromID;

/// 答题结果关闭
/// @param answerId 答题ID
- (void)handleSignalingDelAnswerResultWithAnswerId:(NSString *)answerId;

/// 收到开始抢答 学生
- (void)handleSignalingContest;

/// 收到抢答学生
- (void)handleSignalingContestCommitWithData:(NSDictionary *)data;
/// 关闭抢答器
- (void)handleSignalingStudentToCloseResponder;
/// 收到抢答结果
- (void)handleSignalingContestResultWithName:(NSString *)name;

/// 老师收到计时器显示
- (void)handleSignalingTeacherTimerShow;

/// 收到计时器开始计时 或暂停计时
- (void)handleSignalingTimerWithTime:(NSInteger)time pause:(BOOL)pause defaultTime:(NSInteger)defaultTime;
/// 暂停计时器
- (void)handleSignalingPauseTimerWithTime:(NSInteger)time defaultTime:(NSInteger)defaultTime;
/// 继续计时器
- (void)handleSignalingContinueTimerWithTime:(NSInteger)time defaultTime:(NSInteger)defaultTime;
/// 重置定时器
//- (void)handleSignalingRestartTimerWithTime:(NSInteger)time;
/// 关闭计时器
- (void)handleSignalingDeleteTimerWithTime;

/// 收到白板
/// @param message 课件信息 （翻页，类型，ID等）
/// @param isDynamic 是否是动态PPT  H5  gifs三种类型的课件 保证放大缩小按钮的显示隐藏
- (void)handleSignalingWhiteBroadShowPageMessage:(NSDictionary *)message isDynamic:(BOOL)isDynamic;

/// 收到添加删除文件
- (void)handleSignalingWhiteBroadDocumentChange;

///开启上麦功能
- (void)handleSignalingAllowEveryoneUpPlatformWithIsAllow:(BOOL)isAllow;

///允许上麦的申请
- (void)handleSignalingAllowUpPlatformApplyWithData:(NSDictionary *)data;

///全体禁言
- (void)handleSignalingToDisAbleEveryoneBanChatWithIsDisable:(BOOL)isDisable;
///全体静音 发言
- (void)handleSignalingToliveAllNoAudio:(BOOL)noAudio;

- (void)handleSignalingToDoubleTeacherWithData:(NSDictionary *)data;


#pragma mark 白板 YSWhiteBoardManagerDelegate

/// 界面更新
- (void)onWhiteBoardViewStateUpdate:(NSDictionary *)message;
/// 教室加载状态
- (void)onWhiteBoardLoadedState:(NSDictionary *)message;
/// 本地操作，缩放课件比例变化
- (void)onWhiteBoardFileViewZoomScaleChanged:(CGFloat)zoomScale;


@end


#pragma mark -
#pragma mark SendSignaling

@interface YSLiveManager (SendSignaling)

/// 发布自定义信令
- (BOOL)sendPubMsg:(NSString *)msgName
              toID:(NSString *)toID
              data:(nullable id)data
              save:(BOOL)save
        completion:(nullable completion_block)completion;

/// 发布自定义信令
- (BOOL)sendPubMsg:(NSString *)msgName
              toID:(NSString *)toID
              data:(nullable id)data
              save:(BOOL)save
   associatedMsgID:(nullable NSString *)associatedMsgID
  associatedUserID:(nullable NSString *)associatedUserID
           expires:(NSTimeInterval)expires
        completion:(nullable completion_block)completion;

/// 发布自定义信令
- (BOOL)sendPubMsg:(NSString *)msgName
              toID:(NSString *)toID
              data:(nullable id)data
              save:(BOOL)save
     extensionData:(nullable NSDictionary *)extensionData
        completion:(nullable completion_block)completion;

/// 关闭自定义信令
- (BOOL)deleteMsg:(NSString *)msgName
            toID:(NSString *)toID
            data:(nullable id)data
      completion:(nullable completion_block)completion;

#pragma mark send Signaling

// 发送信令

/// 客户端请求关闭信令服务器房间
- (BOOL)sendSignalingDestroyServerRoomWithCompletion:(nullable completion_block)completion;

/// 同步服务器时间
- (BOOL)sendSignalingUpdateTimeWithCompletion:(nullable completion_block)completion;

// stateType    0--1分钟  1--3分钟  2--5分钟  3--10分钟  4--30分钟
/// 发起点名
- (BOOL)sendSignalingLiveCallRollWithStateType:(NSUInteger)stateType completion:(nullable completion_block)completion;

/// 结束点名
- (BOOL)closeSignalingLiveCallRollWithcompletion:(nullable completion_block)completion;

/// 发起抽奖
- (BOOL)sendSignalingLiveLuckDrawWithCompletion:(nullable completion_block)completion;

/// 上麦申请
- (BOOL)sendSignalingUpPlatformWithCompletion:(nullable completion_block)completion;
/// 上麦申请结果
- (BOOL)answerSignalingUpPlatformWithCompletion:(nullable completion_block)completion;




/// 发送投票
- (BOOL)sendSignalingVoteCommitWithVoteId:(NSString *)voteId voteResault:(NSArray *)voteResault completion:(nullable completion_block)completion;

/// 通知
- (BOOL)sendSignalingLiveNoticeInfoWithNotice:(NSString *)text completion:(nullable completion_block)completion;
- (BOOL)sendSignalingLiveNoticeInfoWithNotice:(NSString *)text toID:(nullable NSString *)peerId completion:(completion_block)completion;

/// 公告
- (BOOL)sendSignalingLiveNoticeBoardWithNotice:(NSString *)text completion:(nullable completion_block)completion;

/// 送花
- (BOOL)sendSignalingLiveNoticesSendFlowerWithSenderName:(NSString *)nickName completion:(nullable completion_block)completion;

/// 发送答题卡答案
- (BOOL)sendSignalingAnwserCommitWithAnswerId:(NSString *)answerId anwserResault:(NSArray *)answerResault completion:(nullable completion_block)completion;

/// 修改答题卡答案
- (BOOL)sendSignalingAnwserModifyWithAnswerId:(NSString *)answerId addAnwserResault:(nullable NSArray *)addAnwserResault  delAnwserResault:(nullable NSArray *)delAnwserResault notChangeAnwserResault:(nullable NSArray *)notChangeAnwserResault completion:(nullable completion_block)completion;

/// 发送抢答
- (BOOL)sendSignalingStudentContestCommitCompletion:(nullable completion_block)completion;

@end


#pragma mark -
#pragma mark GetSignaling

@interface YSLiveManager (GetSignaling)
/// 收到自定义Pub信令
- (void)handleRoomPubMsgWithMsgID:(NSString *)msgID
                          msgName:(NSString *)msgName
                             data:(nullable id)data
                           fromID:(NSString *)fromID
                           inList:(BOOL)inlist
                               ts:(long)ts
                             body:(NSDictionary *)msgBody;

/// 收到自定义Del信令
- (void)handleRoomDelMsgWithMsgID:(NSString *)msgID
                          msgName:(NSString *)msgName
                             data:(nullable id)data
                           fromID:(NSString *)fromID
                           inList:(BOOL)inlist
                               ts:(long)ts;

/// 收到白板自定义Pub信令
- (void)handleWhiteBroadPubMsgWithMsgID:(NSString *)msgID
                                msgName:(NSString *)msgName
                                   data:(NSObject *)data
                                 fromID:(NSString *)fromID
                                 inList:(BOOL)inlist
                                     ts:(long)ts;

@end


#pragma mark -
#pragma mark GetTeacherSignaling

@interface YSLiveManager (GetTeacherSignaling)

// 收到自定义信令 发布消息
// @param msgID 消息id
// @param msgName 消息名字
// @param ts 消息时间戳
// @param data 消息数据，可以是Number、String、NSDictionary或NSArray
// @param fromID  消息发布者的ID
// @param inlist 是否是inlist中的信息
- (BOOL)handleRoomTeacherPubMsgWithMsgID:(NSString *)msgID
                                 msgName:(NSString *)msgName
                                    data:(NSObject *)data
                                  fromID:(NSString *)fromID
                                  inList:(BOOL)inlist
                                      ts:(long)ts;

// 收到自定义信令 删去消息
// @param msgID 消息id
// @param msgName 消息名字
// @param ts 消息时间戳
// @param data 消息数据，可以是Number、String、NSDictionary或NSArray
// @param fromID  消息发布者的ID
// @param inlist 是否是inlist中的信息
- (BOOL)handleRoomTeacherDelMsgWithMsgID:(NSString *)msgID
                                 msgName:(NSString *)msgName
                                    data:(NSObject *)data
                                  fromID:(NSString *)fromID
                                  inList:(BOOL)inlist
                                      ts:(long)ts;

@end

#pragma mark -
#pragma mark SendTeacherSignaling

@interface YSLiveManager (SendTeacherSignaling)
/// 老师发起上课
- (BOOL)sendSignalingTeacherToClassBeginWithCompletion:(nullable completion_block)completion;

/// 老师发起下课
- (BOOL)sendSignalingTeacherToDismissClassWithCompletion:(nullable completion_block)completion;

/// 修改指定用户的属性
- (BOOL)sendSignalingToChangePropertyWithRoomUser:(YSRoomUser *)user withKey:(NSString *)key WithValue:(NSObject *)value;

/// 全体静音
- (BOOL)sendSignalingTeacherToLiveAllNoAudioCompletion:(nullable completion_block)completion;

/// 全体发言
- (BOOL)deleteSignalingTeacherToLiveAllNoAudioCompletion:(nullable completion_block)completion;

/// 全体禁言
- (BOOL)sendSignalingTeacherToLiveAllNoChatSpeakingCompletion:(nullable completion_block)completion;

/// 解除禁言
- (BOOL)deleteSignalingTeacherToLiveAllNoChatSpeakingCompletion:(nullable completion_block)completion;

/// 一V一  时改变布局(1:视频布局  0：默认布局)
- (BOOL)sendSignalingToChangeLayoutWithLayoutType:(YSLiveRoomLayout)layoutType;

/// 一V一时改变布局 (会议专用)
- (BOOL)sendSignalingToChangeLayoutWithLayoutType:(YSLiveRoomLayout)layoutType appUserType:(YSAppUseTheType)appUserType;

/// 发送双击视频放大
- (BOOL)sendSignalingToDoubleClickVideoViewWithPeerId:(NSString *)peerId;
/// 取消双击视频放大
- (BOOL)deleteSignalingToDoubleClickVideoView;

/// 拖出视频/复位视频
- (BOOL)sendSignalingToDragOutVideoViewWithData:(NSDictionary*)data;

/// 拖出视频后捏合动作
- (BOOL)sendSignalingTopinchVideoViewWithPeerId:(NSString *)peerId scale:(CGFloat)scale;


/// 删除课件
- (BOOL)sendSignalingTeacherToDeleteDocumentWithFile:(YSFileModel *)fileModel completion:(nullable completion_block)completion;

/// 切换课件
- (BOOL)sendSignalingTeacherToSwitchDocumentWithFile:(YSFileModel *)fileModel completion:(nullable completion_block)completion;

/// 答题器占用操作
- (BOOL)sendSignalingTeacherToAnswerOccupyedCompletion:(nullable completion_block)completion;
/// 发布答题器
- (BOOL)sendSignalingTeacherToAnswerWithOptions:(NSArray *)answers answerID:(NSString *)answerID completion:(nullable completion_block)completion;

/// 获取答题器进行时的结果
- (BOOL)sendSignalingTeacherToAnswerGetResultWithAnswerID:(NSString *)answerID completion:(nullable completion_block)completion;
/// 结束答题
- (BOOL)sendSignalingTeacherToDeleteAnswerWithAnswerID:(NSString *)answerID completion:(nullable completion_block)completion;
/// 发布答题结果
/// @param answerID 答题ID
/// @param selecteds 统计数据
/// @param duration 答题时间
/// @param detailData 详情数据
/// @param totalUsers 总人数
/// @param completion 回调
- (BOOL)sendSignalingTeacherToAnswerPublicResultWithAnswerID:(NSString *)answerID selecteds:(NSDictionary *)selecteds duration:(NSString *)duration detailData:(NSArray *)detailData totalUsers:(NSInteger)totalUsers completion:(nullable completion_block)completion;
/// 结束答题结果
- (BOOL)sendSignalingTeacherToDeleteAnswerPublicResultCompletion:(nullable completion_block)completion;

/// 抢答器  开始
- (BOOL)sendSignalingTeacherToStartResponderCompletion:(nullable completion_block)completion;
/// 发布抢答器结果
- (BOOL)sendSignalingTeacherToContestResultWithName:(NSString *)name completion:(nullable completion_block)completion;
/// 关闭抢答器
- (BOOL)sendSignalingTeacherToCloseResponderCompletion:(nullable completion_block)completion;

/// fas计时器
/// @param time 计时器时间
/// @param isStatus 当前状态 暂停 继续
/// @param isRestart 重置是否
/// @param isShow 是否显示弹窗  老师第一次点击计时器传false  老师显示，老师点击开始计时，传true ，学生显示

/// @param defaultTime 开始计时时间
/// @param completion 回调

/// 老师计时器显示
- (BOOL)sendSignalingTeacherToShowTimerCompletion:(nullable completion_block)completion;
/// 学生计时器显示
- (BOOL)sendSignalingStudentToShowTimerWithTime:(NSInteger)time completion:(nullable completion_block)completion;

/// 老师计时器暂停
- (BOOL)sendSignalingTeacherToPauseTimerWithTime:(NSInteger)time completion:(nullable completion_block)completion;
/// 老师计时器继续
- (BOOL)sendSignalingTeacherToContinueTimerWithTime:(NSInteger)time completion:(nullable completion_block)completion;
/// 计时器中重置
- (BOOL)sendSignalingTeacherToRestartTimerWithDefaultTime:(NSInteger)defaultTime completion:(nullable completion_block)completion;


- (BOOL)sendSignalingTeacherToStartTimerWithTime:(NSInteger)time isStatus:(BOOL)isStatus isRestart:(BOOL)isRestart isShow:(BOOL)isShow defaultTime:(NSInteger)defaultTime completion:(nullable completion_block)completion;
/// 结束计时
- (BOOL)sendSignalingTeacherToDeleteTimerCompletion:(nullable completion_block)completion;
@end



#pragma mark -
#pragma mark Message

@interface YSLiveManager (message)

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

NS_ASSUME_NONNULL_END
