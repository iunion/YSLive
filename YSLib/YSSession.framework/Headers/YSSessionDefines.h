//
//  YSSessionDefines.h
//  YSSession
//
//  Created by jiang deng on 2020/6/10.
//  Copyright © 2020 YS. All rights reserved.
//

#ifndef YSSessionDefines_h
#define YSSessionDefines_h

#define YS_CloudHubRtcRender_AutoReSize     (0)

#define YS_Check_DevicePerformance_Low      (0)

#define YS_UseInjectStream_PlayLocalMedia   (1)

#define YS_Deprecated(string) __attribute__((deprecated(string)))

/// 信令服务器尝试重连次数key，0：表示无限次重连，大于0：表示重连的次数
FOUNDATION_EXPORT NSString * const YSRoomSettingOptionalReconnectattempts;
/// 是否使用白板key
FOUNDATION_EXPORT NSString * const YSRoomSettingOptionalWhiteBoardNotify;
/// 私有地址key
FOUNDATION_EXPORT NSString * const YSRoomSettingOptionalPrivateHostAddress;
/// 私有端口key
FOUNDATION_EXPORT NSString * const YSRoomSettingOptionalPrivatePort;

//******调用joinroom 接口进入房间，roomParams字典参数所需 Key值定义******//
/// 房间ID @required
FOUNDATION_EXTERN NSString * const YSJoinRoomParamsRoomIDKey;
/// 密码key值 @required，如果该房间或者该用户角色没有密码，value：@""
FOUNDATION_EXTERN NSString * const YSJoinRoomParamsPasswordKey;

/// server
FOUNDATION_EXTERN NSString * const YSJoinRoomParamsServerKey;
/// 客户端类型
FOUNDATION_EXTERN NSString * const YSJoinRoomParamsClientTypeKey;

/// 用户角色key值 @optional
FOUNDATION_EXTERN NSString * const YSJoinRoomParamsUserRoleKey;
/// 用户ID的key值 @optional，如果不传用户ID，sdk会自动生成用户ID
FOUNDATION_EXTERN NSString * const YSJoinRoomParamsUserIDKey;

/// 白板服务器地址
FOUNDATION_EXTERN NSString * const YSWhiteBoardGetServerAddrKey;
/// 白板备份地址
FOUNDATION_EXTERN NSString * const YSWhiteBoardGetServerAddrBackupKey;
/// 白板web地址
FOUNDATION_EXTERN NSString * const YSWhiteBoardGetWebAddrKey;

/// 缓存数据key
static NSString *const kYSMethodNameKey     = @"YSCacheMsg_MethodName";
static NSString *const kYSParameterKey      = @"YSCacheMsg_Parameter";

#pragma - mark 用户属性

/// 用户属性
static NSString *const sYSUserProperties            = @"properties";

/// 昵称
static NSString *const sYSUserNickname              = @"nickname";
/// 身份
static NSString *const sYSUserRole                  = @"role";

static NSString *const sYSUserHasAudio              = @"hasaudio";
static NSString *const sYSUserHasVideo              = @"hasvideo";

/// 是否视频镜像 YES NO
static  NSString *const sYSUserIsVideoMirror        = @"isVideoMirror";

/// 发布状态
static NSString *const sYSUserPublishstate          = @"publishstate";
/// 画笔权限 YES NO
static NSString *const sYSUserCandraw               = @"candraw";

/// 是否进入后台 YES NO
static NSString *const sYSUserIsInBackGround        = @"isInBackGround";

/// 用户设备状态
static NSString *const sYSUserVideoFail             = @"vfail";
static NSString *const sYSUserAudioFail             = @"afail";

/// 画笔颜色值
static NSString *const sYSUserPrimaryColor          = @"primaryColor";

/// 举手 YES NO 允许上台
static NSString *const sYSUserRaisehand             = @"raisehand";

/// 是否禁言 YES NO
static NSString *const sYSUserDisablechat           = @"disablechat";

/// 奖杯数
static NSString *const sYSUserGiftNumber            = @"giftnumber";

/// 网络状态 0:好 1：差
static NSString *const sYSUserNetWorkState          = @"medialinebad";

/// 用户设备类型
/// AndroidPad:Android pad；AndroidPhone:Andriod phone；
/// iPad:iPad；iPhone:iPhone；
/// MacPC:mac explorer；MacClient:mac client；
/// WindowPC:windows explorer；WindowClient:windows client
static NSString *const sYSUserDevicetype            = @"devicetype";
static NSString *const sYSUserSDKVersion            = @"version";
static NSString *const sYSUserSystemVersion         = @"systemversion";
static NSString *const sYSUserAppType               = @"appType";


#pragma - mark 信令Key

/// 发送消息
static NSString *const sYSSignalPubMsg              = @"pubMsg";
/// 删除消息
static NSString *const sYSSignalDelMsg              = @"delMsg";

//****** 调用pubMsg以及delMsg 接口发送信令，toID参数相关传值；表示：此信令需要通知的对象 ******//
#pragma - mark 信令发送对象

/// 全体
static NSString *const YSRoomPubMsgTellAll                 = @"__all";

/// 除自己以外的所有人
static NSString *const YSRoomPubMsgTellAllExceptSender     = @"__allExceptSender";
/// 除旁听用户以外的所有人
static NSString *const YSRoomPubMsgTellAllExceptAuditor    = @"__allExceptAuditor";
/// 通知老师和助教
static NSString *const YSRoomPubMsgTellAllSuperUsers       = @"__allSuperUsers";

/// 不通知任何人
static NSString *const YSRoomPubMsgTellNone                = @"__None";

#pragma - mark 信令

/// 客户端请求关闭信令服务器房间
static NSString *const sYSSignalNotice_Server_RoomEnd      = @"Server_RoomEnd";

/// 服务器时间同步
static NSString *const sYSSignalUpdateTime              = @"UpdateTime";

/// 用户网络差，被服务器切换媒体线路
static NSString *const sYSSignalNotice_ChangeMediaLine  =   @"Notice_ChangeMediaLine";

/// 房间即将关闭消息
static NSString *const sYSSignalName_Notice_PrepareRoomEnd   = @"Notice_PrepareRoomEnd";

static NSString *const sYSSignalId_Notice_PrepareRoomEnd   = @"Notice_PrepareRoomEnd";

///房间踢除所有用户消息
static NSString *const sYSSignalNotice_EvictAllRoomUse  = @"Notice_EvictAllRoomUser";

/// 上课
static NSString *const sYSSignalClassBegin              = @"ClassBegin";

/// 大房间用户数
static NSString *const sYSSignalNotice_BigRoom_Usernum  = @"Notice_BigRoom_Usernum";
/// 大房间自己被上台后，同步自己的属性给别人
static NSString *const sYSSignalSyncProperty            = @"SyncProperty";

/// 设置用户属性
static NSString *const sYSSignalSetProperty             = @"setProperty";

/// 发布网络文件流的方法
static NSString *const sYSSignalPublishNetworkMedia     = @"publishNetworkMedia";
/// 取消发布网络文件流
static NSString *const sYSSignalUnpublishNetworkMedia   = @"unpublishNetworkMedia";

/// 全体静音
static NSString *const sYSSignalLiveAllNoAudio          = @"LiveAllNoAudio";

/// 全体禁言
static NSString *const sYSSignalEveryoneBanChat         = @"LiveAllNoChatSpeaking";

/// 轮播
static NSString *const sYSSignalVideoPolling            = @"VideoPolling";

/// 切换窗口布局
static NSString *const sYSSignalSetRoomLayout           = @"SetRoomLayout";

/// 视频 拖出 + 缩放
static NSString *const sYSSignalVideoAttribute               = @"VideoAttribute";

/// 双击视频最大化
static NSString *const sYSSignalDoubleClickVideo        = @"doubleClickVideo";

///双师：老师拖拽视频布局相关信令
static NSString *const sYSSignalDoubleTeacher           = @"one2oneVideoSwitchLayout";

/// 助教刷新课件
static NSString *const sYSSignalRefeshCourseware =      @"RemoteControlCourseware";

/// 助教强制刷新
static NSString *const sYSSignalRemoteControl    = @"RemoteControl";


/// 投票
static NSString *const sYSSignalVoteStart               = @"VoteStart";
/// 发送投票
static NSString *const sYSSignalVoteCommit              = @"voteCommit";
/// 投票结果
static NSString *const sYSSignalPublicVoteResult        = @"PublicVoteResult";


///同意各端开始举手
static NSString *const sYSSignalRaiseHandStart          = @"RaiseHandStart";
/// 申请举手上台
static NSString *const sYSSignalRaiseHand               = @"RaiseHand";
///老师/助教  订阅/取消订阅举手列表
static NSString *const sYSSignalRaiseHandResult         = @"RaiseHandResult";
///老师/助教获取到的举手列表订阅结果
static NSString *const sYSSignalServer_Sort_Result      = @"Server_Sort_Result";


/// 提问 确认 回答 删除
static NSString *const sYSSignalLiveQuestions            = @"LiveQuestions";
///聊天中的送花
static NSString *const sYSSignaSendFlower               = @"LiveGivigGifts";

/// 答题卡
static NSString *const sYSSignaling_Answer              = @"Answer";
/// 答题卡提交选项
static NSString *const sYSSignaling_AnswerCommit        = @"AnswerCommit";
/// 老师获取学生的答题情况
static NSString *const sYSSignaling_AnswerGetResult     = @"AnswerGetResult";
/// 公布答题结果
static NSString *const sYSSignaling_AnswerPublicResult  = @"AnswerPublicResult";


/// 老师抢答器
static NSString *const sYSSignaling_ShowContest         = @"ShowContest_v1";
//发起抢答排序
static NSString *const sYSSignaling_Contest             = @"Contest_v1";
/// 收到学生抢答
static NSString *const sYSSignaling_ContestCommit       = @"ContestCommit_v1";
/// 抢答结果
static NSString *const sYSSignaling_ContestResult       = @"ContestResult_v1";
/// 订阅排序
static NSString *const sYSSignaling_ContestSubsort      = @"ContestSubsort_v1";


/// 计时器
static NSString *const sYSSignaling_Timer               = @"timer";


/// 点名 签到
static NSString *const sYSSignaling_LiveCallRoll        = @"LiveCallRoll";


/// 抽奖
static NSString *const sYSSignaling_LiveLuckDraw        = @"LiveLuckDraw";
/// 抽奖结果
static NSString *const sYSSignaling_LiveLuckDrawResult  = @"LiveLuckDrawResult";

/// 通知
static NSString *const sYSSignaling_LiveNoticeInform    = @"LiveNoticeInform";
/// 公告
static NSString *const sYSSignaling_LiveNoticeBoard     = @"LiveNoticeBoard";


#pragma mark -白板
/// 白板视频标注
static NSString *const sYSSignaling_VideoWhiteboard     = @"VideoWhiteboard";
static NSString *const sYSSignaling_VideoWhiteboard_Id  = @"videoDrawBoard";
static NSString *const sYSSignaling_Whiteboard_SharpsChange = @"SharpsChange";
#endif /* YSSessionDefines_h */
