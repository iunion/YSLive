//
//  CHSessionForSignalingDelegate.h
//  CHSession
//
//

#ifndef CHSessionForSignalingDelegate_h
#define CHSessionForSignalingDelegate_h

#import "CHQuestionModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol CHSessionForSignalingDelegate <NSObject>

@optional

/// 同步服务器时间
- (BOOL)handleSignalingUpdateTimeWithTimeInterval:(NSTimeInterval)TimeInterval;

/// 房间即将关闭消息
- (BOOL)handleSignalingPrepareRoomEndWithDataDic:(NSDictionary *)dataDic addReason:(CHPrepareRoomEndType)reason;

/// 取消房间即将关闭消息,只取消CHPrepareRoomEndType_TeacherLeaveTimeout
- (void)stopSignalingLivePrepareRoomEnd_TeacherLeaveTimeout;

#pragma mark 用户网络差，被服务器切换媒体线路

- (void)roomManagerChangeMediaLine;

/// 房间踢除所有用户消息
- (void)handleSignalingEvictAllRoomUseWithDataDic:(NSDictionary *)dataDic;

/// 大房间同步上台用户属性
- (void)handleSignalingSyncProperty:(CHRoomUser *)roomUser;

/// 启动父房间授课
- (void)handleSignalingParentRoomLectureBegin;
/// 关闭父房间授课
- (void)handleSignalingParentRoomLectureEnd;
/// 分组房间私聊
- (void)handleSignalingParentRoomChating:(BOOL)isChating childUserId:(NSString *)childUserId;

/// 分组上课
- (void)handleSignalingGroupRoomBegin:(BOOL)isGroupBegin;
/// 上课
- (void)handleSignalingClassBeginWihIsHistory:(BOOL)isHistory;

/// 下课
- (void)handleSignalingClassEndWithText;

/// 全体静音
- (void)handleSignalingliveAllNoAudio:(BOOL)noAudio;

///全体禁言
- (void)handleSignalingToDisAbleEveryoneBanChatWithIsDisable:(BOOL)isDisable;

/// 开启举手功能
- (void)handleSignalingAllowEveryoneRaiseHand;

///所有举手用户的列表
- (void)handleSignalingRaiseHandUserArray:(NSMutableArray *)raiseHandUserArray;

/// 窗口布局变化
- (void)handleSignalingSetRoomLayout:(CHRoomLayoutType)roomLayout withPeerId:(nullable NSString *)peerId withSourceId:(nullable NSString *)sourceId;

///切换窗口布局恢复
- (void)handleSignalingDefaultRoomLayout;

///拖出/放回/拉伸视频窗口 根据本地默认尺寸scale
- (void)handleSignalingDragOutAndChangeSizeVideoWithPeerId:(NSString *)peerId withSourceId:(NSString *)sourceId withStreamId:(NSString *)streamId WithData:(NSDictionary *)data fromId:(NSString *)fromId;

///双师时老师拖拽视频时
- (void)handleSignalingToDoubleTeacherWithData:(NSDictionary *)data;

/// 双击视频最大化
- (void)handleSignalingDragOutVideoChangeFullSizeWithPeerId:(nullable NSString *)peerId withSourceId:(nullable NSString *)sourceId isFull:(BOOL)isFull;

///助教刷新课件
- (void)handleSignalingTorefeshCourseware;

/// 助教强制刷新
- (void)handleSignalingToForceRefresh;

/// 收到答题卡占位
- (void)handleSignalingAnswerOccupyedWithAnswerId:(NSString *)answerId startTime:(NSInteger)startTime;

/// 收到答题卡
- (void)handleSignalingSendAnswerWithAnswerId:(NSString *)answerId options:(NSArray *)options startTime:(NSInteger)startTime fromID:(NSString *)fromID;

/// 收到学生的答题情况
- (void)handleSignalingTeacherAnswerGetResultWithAnswerId:(NSString *)answerId totalUsers:(NSInteger)totalUsers values:(NSDictionary *)values;

/// 答题结束
- (void)handleSignalingAnswerEndWithAnswerId:(NSString *)answerId fromID:(NSString *)fromID;

/// 答题结果
- (void)handleSignalingAnswerPublicResultWithAnswerId:(NSString *)answerId resault:(NSDictionary *)resault durationStr:(NSString *)durationStr answers:(NSArray *)answers totalUsers:(NSUInteger)totalUsers fromID:(NSString *)fromID;

/// 答题结果关闭
- (void)handleSignalingDelAnswerResultWithAnswerId:(NSString *)answerId;

/// 老师/助教收到 showContest
- (void)handleSignalingShowContestFromID:(NSString *)fromID isHistory:(BOOL)isHistory;

/// 收到抢答排序
- (void)handleSignalingContestFromID:(NSString *)fromID isHistory:(BOOL)isHistory;

/// 收到抢答学生
- (void)handleSignalingContestCommitWithData:(NSArray *)data isHistory:(BOOL)isHistory;

/// 关闭抢答器
- (void)handleSignalingToCloseResponder;

/// 收到抢答结果
- (void)handleSignalingContestResultWithName:(NSString *)name;

/// 收到取消订阅排序
- (void)handleSignalingCancelContestSubsort;

/// 结束抢答排序
- (void)handleSignalingDelContest;

///收到轮播
- (void)handleSignalingToStartVideoPollingFromID:(NSString *)fromID;

///结束轮播
- (void)handleSignalingToStopVideoPolling;

/// 老师收到计时器显示
- (void)handleSignalingTeacherTimerShow;

/// 收到计时器开始计时 或暂停计时
- (void)handleSignalingTimerWithTime:(NSInteger)time pause:(BOOL)pause defaultTime:(NSInteger)defaultTime;

/// 暂停计时器
- (void)handleSignalingPauseTimerWithTime:(NSInteger)time defaultTime:(NSInteger)defaultTime;

/// 继续计时器
- (void)handleSignalingContinueTimerWithTime:(NSInteger)time defaultTime:(NSInteger)defaultTime;

/// 关闭计时器
- (void)handleSignalingDeleteTimerWithTime;


/// 收到点名
// stateType    0--1分钟  1--3分钟  2--5分钟  3--10分钟  4--30分钟
- (void)handleSignalingLiveCallRollWithStateType:(NSUInteger)stateType callRollId:(NSString *)callRollId apartTimeInterval:(NSTimeInterval)apartTimeInterval;

/// 结束点名
- (void)closeSignalingLiveCallRoll;

/// 抽奖
- (void)handleSignalingLiveLuckDraw;

/// 中奖结果
- (void)handleSignalingLiveLuckDrawResultWithNameList:(NSArray *)nameList withEndTime:(NSString *)endTime;

/// 抽奖结束
- (void)closeSignalingLiveLuckDraw;

/// 通知
- (void)handleSignalingLiveNoticeInfoWithNotice:(NSString *)text timeInterval:(NSUInteger)timeInterval;

/// 公告
- (void)handleSignalingLiveNoticeBoardWithNotice:(NSString *)text timeInterval:(NSUInteger)timeInterval;

/// 提问 确认 回答
- (void)handleSignalingQuestionResponedWithQuestion:(CHQuestionModel *)question;

/// 删除提问
- (void)handleSignalingDeleteQuestionWithQuestionId:(NSString *)questionId;

/// 送花
- (void)handleSignalingSendFlowerWithSenderId:(NSString *)senderId senderName:(NSString *)senderName;

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


/// 小黑板答题阶段私聊
- (void)handleSignalingReceivePrivateChatWithData:(nullable NSDictionary *)data;

/// 显示白板视频标注
- (void)handleSignalingShowVideoWhiteboardWithData:(NSDictionary *)data videoRatio:(CGFloat)videoRatio;

/// 绘制白板视频标注
- (void)handleSignalingDrawVideoWhiteboardWithData:(NSDictionary *)data isHistory:(BOOL)isHistory;

/// 隐藏白板视频标注
- (void)handleSignalingHideVideoWhiteboard;

@end

NS_ASSUME_NONNULL_END

#endif /* CHSessionForSignalingDelegate_h */
