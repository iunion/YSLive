//
//  CHSessionDefines.h
//  CHSession
//
//

#ifndef CHSessionDefines_h
#define CHSessionDefines_h

#define CH_Deprecated(string) __attribute__((deprecated(string)))

/// 检查低端设备
#define CH_Check_DevicePerformance_Low      (1)
/// 媒体课件支持多路流 暂不支持
#define CH_SupportShareMoreMedia            (0)


/// 信令服务器尝试重连次数key，0：表示无限次重连，大于0：表示重连的次数
FOUNDATION_EXPORT NSString * const CHRoomSettingOptionalReconnectattempts;
/// 是否使用白板key
FOUNDATION_EXPORT NSString * const CHRoomSettingOptionalWhiteBoardNotify;

//******调用joinroom 接口进入房间，roomParams字典参数所需 Key值定义******//
/// 房间ID @required
FOUNDATION_EXTERN NSString * const CHJoinRoomParamsRoomSerialKey;
FOUNDATION_EXTERN NSString * const CHJoinRoomParamsRoomIdKey;
/// 密码key值 @required，如果该房间或者该用户角色没有密码，value：@""
FOUNDATION_EXTERN NSString * const CHJoinRoomParamsPasswordKey;

/// server
FOUNDATION_EXTERN NSString * const CHJoinRoomParamsServerKey;
/// 客户端类型
FOUNDATION_EXTERN NSString * const CHJoinRoomParamsClientTypeKey;

/// 用户角色key值 @optional
FOUNDATION_EXTERN NSString * const CHJoinRoomParamsUserRoleKey;
/// 用户ID的key值 @optional，如果不传用户ID，sdk会自动生成用户ID
FOUNDATION_EXTERN NSString * const CHJoinRoomParamsUserIDKey;


/// 音频SoundId
#define CHUISoundId_Start       100
#define CHWBSoundId_Start       500

#define CHUserSoundId_Start     1000


/// 缓存数据key
static NSString *const kCHMethodNameKey     = @"CHCacheMsg_MethodName";
static NSString *const kCHParameterKey      = @"CHCacheMsg_Parameter";

#pragma - mark 用户属性

/// 用户属性
static NSString *const sCHUserProperties            = @"properties";

/// 昵称
static NSString *const sCHUserNickname              = @"nickname";
/// 身份
static NSString *const sCHUserRole                  = @"role";

static NSString *const sCHUserHasAudio              = @"hasaudio";
static NSString *const sCHUserHasVideo              = @"hasvideo";

/// 是否视频镜像 YES NO
static  NSString *const sCHUserIsVideoMirror        = @"isVideoMirror";

/// 发布状态
static NSString *const sCHUserPublishstate          = @"publishstate";
/// 画笔权限 YES NO
static NSString *const sCHUserCandraw               = @"candraw";

/// 是否进入后台 YES NO
static NSString *const sCHUserIsInBackGround        = @"isInBackGround";

/// 用户设备状态
/// 用户音频设备
static NSString *const sCHUserMic                   = @"mic";
/// 用户视频设备

static NSString *const sCHUserDefaultSourceId       = @"default_source_id";
static NSString *const sCHUserCameras               = @"cameras";
static NSString *const sCHUserDiveceMute            = @"mute";
static NSString *const sCHUserVideoFail             = @"vfail";
static NSString *const sCHUserAudioFail             = @"afail";

/// 画笔颜色值
static NSString *const sCHUserPrimaryColor          = @"primaryColor";

/// 举手 YES NO 允许上台
static NSString *const sCHUserRaisehand             = @"raisehand";

/// 是否禁言 YES NO
static NSString *const sCHUserDisablechat           = @"disablechat";

/// 奖杯数
static NSString *const sCHUserGiftNumber            = @"giftnumber";

/// 网络状态 0:好 1：差
static NSString *const sCHUserNetWorkState          = @"medialinebad";




/// 用户设备类型
/// AndroidPad:Android pad；AndroidPhone:Andriod phone；
/// iPad:iPad；iPhone:iPhone；
/// MacPC:mac explorer；MacClient:mac client；
/// WindowPC:windows explorer；WindowClient:windows client
static NSString *const sCHUserDevicetype            = @"devicetype";
static NSString *const sCHUserSDKVersion            = @"version";
static NSString *const sCHUserSystemVersion         = @"systemversion";
static NSString *const sCHUserAppType               = @"appType";


#pragma - mark 信令Key

/// 发送消息
static NSString *const sCHSignalPubMsg              = @"pubMsg";
/// 删除消息
static NSString *const sCHSignalDelMsg              = @"delMsg";

//****** 调用pubMsg以及delMsg 接口发送信令，toID参数相关传值；表示：此信令需要通知的对象 ******//
#pragma - mark 信令发送对象

/// 发送信息给频道中的所有人
static NSString *const CHRoomPubMsgTellAll                  = @"__all";

/// 发送信息给除自己以外的频道中所有人
static NSString *const CHRoomPubMsgTellAllExceptSender      = @"__allExceptSender";
/// 除旁听用户以外的所有人
static NSString *const CHRoomPubMsgTellAllExceptAuditor     = @"__allExceptAuditor";
/// 只发给特殊身份(助教和老师)
static NSString *const CHRoomPubMsgTellAllSuperUsers        = @"__allSuperUsers";

/// 只发送信息到服务器，不发给任何人
static NSString *const CHRoomPubMsgTellNone                 = @"__none";


/// 发送给指定房间【房间关系必须是父子关系/兄弟关系】，如: __room:roomidA
static NSString *const CHRoomPubMsgTellRoom                 = @"__room";
/// 发送给指定房间但是不发送给自己，房间id不能包含冒号【房间关系必须是父子关系】，如: __roomExceptSender:roomidA
static NSString *const CHRoomPubMsgTellRoomExceptSender     = @"__roomExceptSender";
/// 发送给指定房间的助教和老师，房间id不能包含冒号【房间关系必须是父子关系】，如: __roomSuperUsers:roomidA
static NSString *const CHRoomPubMsgTellRoomSuperUsers       = @"__roomSuperUsers";
/// 发送给指定房间的用户，房间id不能包含冒号【房间关系必须是父子关系】，如: __room2uid:roomidA:touserid
static NSString *const CHRoomPubMsgTellRoomUid              = @"__room2uid";

#pragma - mark 信令

/// 客户端请求关闭信令服务器房间
static NSString *const sCHSignal_Notice_Server_RoomEnd      = @"Server_RoomEnd";

/// 服务器时间同步
static NSString *const sCHSignal_UpdateTime                 = @"UpdateTime";

/// 用户网络差，被服务器切换媒体线路
static NSString *const sCHSignal_Notice_ChangeMediaLine     = @"Notice_ChangeMediaLine";

/// 房间即将关闭消息
static NSString *const sCHSignal_Name_Notice_PrepareRoomEnd = @"Notice_PrepareRoomEnd";

static NSString *const sCHSignal_Id_Notice_PrepareRoomEnd   = @"Notice_PrepareRoomEnd";

///房间踢除所有用户消息
static NSString *const sCHSignal_Notice_EvictAllRoomUse     = @"Notice_EvictAllRoomUser";

/// 上课
static NSString *const sCHSignal_ClassBegin                 = @"ClassBegin";
/// 课程结束 只发给服务器
static NSString *const sCHSignal_Server_RoomEnd             = @"Server_RoomEnd";

/// 大房间用户数
static NSString *const sCHSignal_Notice_BigRoom_Usernum     = @"Notice_BigRoom_Usernum";
/// 大房间自己被上台后，同步自己的属性给别人
static NSString *const sCHSignal_SyncProperty               = @"SyncProperty";
/// 分组房间上课
static NSString *const sCHSignal_GroupRoomBegin             = @"GroupRoomBegin";
/// 分组使用
/// 当前子房间以及子房间的人数【只通知给父房间】
/// {roomid1:{usernum: 100, rolenums:{}}, roomid2:{usernum: 100, rolenums:{'0':0, '1':0, '2':0, '3':0, '4':0, '5':0}}}
static NSString *const sCHSignal_ServerNotice_ChildRooms    = @"ServerNotice_ChildRooms";
/// 与父房间断开/连接，需要通知给客户端【只有子房间会通知给本房间的人】  --- 消息保存
static NSString *const sCHSignal_ServerNotice_ParentRoomConn = @"ServerNotice_ParentRoomConn";
/// 启用父房间授课模式
static NSString *const sCHSignal_ClientNotice_ParentRoomLecture = @"ClientNotice_ParentRoomLecture";
/// 分组房间私聊
static NSString *const sCHSignal_ParentRoomChating = @"ParentRoomChating";
/// 清除所有消息
static NSString *const sCHSignal_DeleteAll                  = @"__AllAll";

/// 设置用户属性
static NSString *const sCHSignal_SetProperty                = @"setProperty";

/// 发布网络文件流的方法
static NSString *const sCHSignal_PublishNetworkMedia        = @"publishNetworkMedia";
/// 取消发布网络文件流
static NSString *const sCHSignal_UnpublishNetworkMedia      = @"unpublishNetworkMedia";

/// 全体静音
static NSString *const sCHSignal_LiveAllNoAudio             = @"LiveAllNoAudio";

/// 全体禁言
static NSString *const sCHSignal_EveryoneBanChat            = @"LiveAllNoChatSpeaking";

/// 轮播
static NSString *const sCHSignal_VideoPolling               = @"VideoPolling";

/// 切换窗口布局
static NSString *const sCHSignal_SetRoomLayout              = @"SetRoomLayout";

/// 视频 拖出 + 缩放
static NSString *const sCHSignal_VideoAttribute             = @"VideoAttribute";

/// 双击视频最大化
static NSString *const sCHSignal_DoubleClickVideo           = @"doubleClickVideo";

///双师：老师拖拽视频布局相关信令
static NSString *const sCHSignal_DoubleTeacher              = @"one2oneVideoSwitchLayout";

/// 助教刷新课件
static NSString *const sCHSignal_RefeshCourseware           = @"RemoteControlCourseware";

/// 助教强制刷新
static NSString *const sCHSignal_RemoteControl              = @"RemoteControl";


/// 投票
static NSString *const sCHSignal_VoteStart                  = @"VoteStart";
/// 发送投票
static NSString *const sCHSignal_VoteCommit                 = @"voteCommit";
/// 投票结果
static NSString *const sCHSignal_PublicVoteResult           = @"PublicVoteResult";


///同意各端开始举手
static NSString *const sCHSignal_RaiseHandStart             = @"RaiseHandStart";
/// 申请举手上台
static NSString *const sCHSignal_RaiseHand                  = @"RaiseHand";
///老师/助教  订阅/取消订阅举手列表
static NSString *const sCHSignal_RaiseHandResult            = @"RaiseHandResult";
///老师/助教获取到的举手列表订阅结果
static NSString *const sCHSignal_Server_Sort_Result         = @"Server_Sort_Result";


/// 提问 确认 回答 删除
static NSString *const sCHSignal_LiveQuestions              = @"LiveQuestions";
///聊天中的送花
static NSString *const sCHSigna_SendFlower                  = @"LiveGivigGifts";

/// 答题卡
static NSString *const sCHSignal_Answer                     = @"Answer";
/// 答题卡提交选项
static NSString *const sCHSignal_AnswerCommit               = @"AnswerCommit";
/// 老师获取学生的答题情况
static NSString *const sCHSignal_AnswerGetResult            = @"AnswerGetResult";
/// 公布答题结果
static NSString *const sCHSignal_AnswerPublicResult         = @"AnswerPublicResult";


/// 老师抢答器
static NSString *const sCHSignal_ShowContest                = @"ShowContest_v1";
//发起抢答排序
static NSString *const sCHSignal_Contest                    = @"Contest_v1";
/// 收到学生抢答
static NSString *const sCHSignal_ContestCommit              = @"ContestCommit_v1";
/// 抢答结果
static NSString *const sCHSignal_ContestResult              = @"ContestResult_v1";
/// 订阅排序
static NSString *const sCHSignal_ContestSubsort             = @"ContestSubsort_v1";


/// 计时器
static NSString *const sCHSignal_Timer                      = @"timer";


/// 点名 签到
static NSString *const sCHSignal_LiveCallRoll               = @"LiveCallRoll";


/// 抽奖
static NSString *const sCHSignal_LiveLuckDraw               = @"LiveLuckDraw";
/// 抽奖结果
static NSString *const sCHSignal_LiveLuckDrawResult         = @"LiveLuckDrawResult";

/// 通知
static NSString *const sCHSignal_LiveNoticeInform           = @"LiveNoticeInform";
/// 公告
static NSString *const sCHSignal_LiveNoticeBoard            = @"LiveNoticeBoard";

/// 掷骰子
static NSString *const sCHSignal_Dice                       = @"Dice";
/// 弹幕
static NSString *const sCHSignal_Barrage                    = @"Barrage";

/// 本地电影播放
static NSString *const sCHSignal_LocalMovieStateChanged     = @"LocalMovieStateChanged";

#pragma mark -白板
/// 白板视频标注
#define CHVideoWhiteboard_Id                                @"videoDrawBoard"
static NSString *const sCHSignal_VideoWhiteboard            = @"VideoWhiteboard";
static NSString *const sCHSignal_VideoWhiteboard_Id         = @"videoDrawBoard";
static NSString *const sCHSignal_Whiteboard_SharpsChange    = @"SharpsChange";


/// 小黑板答题阶段私聊
static NSString *const sCHSignal_SmallRoomPrivate           = @"RoomPrivate";


#endif /* CHSessionDefines_h */
