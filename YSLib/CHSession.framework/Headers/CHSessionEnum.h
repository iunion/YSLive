//
//  CHSessionEnum.h
//  CHSession
//
//

#ifndef CHSessionEnum_h
#define CHSessionEnum_h

#pragma mark - 房间相关

/// CHRoomErrorCode 错误码
typedef NS_ENUM(NSInteger, CHRoomErrorCode)
{
    CHErrorCode_UnKnow              = -2,
    CHErrorCode_Internal_Exception  = -1,
    CHErrorCode_OK                  = 0,
    
    CHErrorCode_Not_Initialized     = 101,
    CHErrorCode_Bad_Parameters      = 102,
    CHErrorCode_Room_StateError     = 103,
    CHErrorCode_Publish_StateError  = 104,
    CHErrorCode_Stream_StateError   = 105,
    CHErrorCode_Stream_NotFound     = 106,
    CHErrorCode_FilePath_NotExist   = 107,
    CHErrorCode_CreateFile_Failed   = 108,
    CHErrorCode_TestSpeed_Failed     = 109,
    /// view已被使用
    CHErrorCode_RenderView_ReUsed               = 110,
    
    CHErrorCode_Publish_NoAck                    = 401,
    CHErrorCode_Publish_RoomNotExist             = 402,
    CHErrorCode_Publish_RoomMaxVideoLimited      = 403,
    CHErrorCode_Publish_ErizoJs_Timeout          = 404,
    CHErrorCode_Publish_Agent_Timeout            = 405,
    CHErrorCode_Publish_UndefinedRPC_Timeout     = 406,
    CHErrorCode_Publish_AddingInput_Error        = 407,
    CHErrorCode_Publish_DuplicatedExtensionId    = 408,
    CHErrorCode_Publish_Unauthorized             = 409,
    /// 发布失败，自动重新发布
    CHErrorCode_Publish_Failed                   = 410,
    /// 发布超时，自动重新发布
    CHErrorCode_Publish_Timeout                  = 411,
    
    CHErrorCode_Subscribe_RoomNotExist           = 501,
    CHErrorCode_Subscribe_StreamNotDefine        = 502,
    CHErrorCode_Subscribe_MediaRPC_Timeout       = 503,
    /// 订阅失败，自动重新订阅
    CHErrorCode_Subscribe_Fail                   = 504,
    /// 订阅超时，自动重新订阅
    CHErrorCode_Subscribe_Timeout                = 505,
    
    CHErrorCode_ConnectSocketError               = 601,

    /// 参数错误
    CHErrorCode_JoinRoom_WrongParam              = 701,
    
    /// 获取房间信息失败
    CHErrorCode_CheckRoom_RequestFailed          = 801,
    /// 获取房间配置失败
    CHErrorCode_RoomConfig_RequestFailed         = 802,
    
    
    /// 客户端只能以学生身份进入分组房间
    CHErrorCode_JoinGroupRoom_RequestFailed      = 900,

    /// 服务器过期
    CHErrorCode_CheckRoom_ServerOverdue          = 3001,
    /// 公司被冻结
    CHErrorCode_CheckRoom_RoomFreeze             = 3002,
    /// 房间已删除或过期
    CHErrorCode_CheckRoom_RoomDeleteOrOrverdue   = 3003,
    /// 该公司不存在
    CHErrorCode_CheckRoom_CompanyNotExist        = 4001,
    /// 房间不存在
    CHErrorCode_CheckRoom_RoomNonExistent        = 4007,
    /// 房间密码错误
    CHErrorCode_CheckRoom_PasswordError          = 4008,
    /// 密码与身份不符
    CHErrorCode_CheckRoom_WrongPasswordForRole   = 4012,
    /// 房间人数超限
    CHErrorCode_CheckRoom_RoomNumberOverRun      = 4103,
    /// 认证错误
    CHErrorCode_CheckRoom_RoomAuthenError        = 4109,
    /// 该房间需要密码，请输入密码
    CHErrorCode_CheckRoom_NeedPassword           = 4110,
    /// 企业点数超限
    CHErrorCode_CheckRoom_RoomPointOverrun       = 4112
};

/// 房间类型 0:表示一对一教室  非0:表示一多教室
typedef NS_ENUM(NSUInteger, CHRoomUserType)
{
    /// 0
    CHRoomUserType_None,
    /// 1 V 1
    CHRoomUserType_One,
    /// 1 V N
    CHRoomUserType_More
};

/// 房间使用场景  3：小班课  4：直播   6：会议
typedef NS_ENUM(NSUInteger, CHRoomUseType)
{
    /// 小班课
    CHRoomUseTypeSmallClass = 3,
    /// 直播
    CHRoomUseTypeLiveRoom = 4,
    /// 会议
    CHRoomUseTypeMeeting = 6
};

/// grouproom 房间分组类型 0 普通房间，1 分组主（父）房间，2 分组子房间
typedef NS_ENUM(NSUInteger, CHRoomGroupType)
{
    /// 普通房间
    CHRoomGroupType_Normal = 0,
    /// 分组主（父）房间
    CHRoomGroupType_GroupMaster = 1,
    /// 分组子房间
    CHRoomGroupType_GroupSub
};


/// CHRoomStatus 房间状态
typedef NS_ENUM(NSUInteger, CHRoomStatus)
{
    CHROOMSTATUS_IDLE          = 0,
    CHROOMSTATUS_PREPARE       = 1,
    CHROOMSTATUS_CHECKING      = 2,
    CHROOMSTATUS_JOINING       = 3
};


#pragma mark - 用户相关

/// CHUserRoleType 用户角色
typedef NS_ENUM(NSInteger, CHUserRoleType)
{
    /// 回放
    CHUserType_Playback = -1,
    /// 老师
    CHUserType_Teacher = 0,
    /// 助教
    CHUserType_Assistant,
    /// 学生
    CHUserType_Student,
    /// 直播
    CHUserType_Live,
    /// 巡课
    CHUserType_Patrol,
    /// 班主任
    CHUserType_ClassMaster
};

/// CHPublishState 发布状态
typedef NS_ENUM(NSUInteger, CHPublishState)
{
    /// 未上台
    CHUser_PublishState_DOWN          = 0,
    /// 已上台
    CHUser_PublishState_UP            = 1,
};


#pragma mark - 网络相关

typedef NS_ENUM(NSUInteger, CHNetQuality)
{
    /// 优
    CHNetQuality_Excellent  = 1,
    /// 良
    CHNetQuality_Good,
    /// 中
    CHNetQuality_Accepted,
    /// 差
    CHNetQuality_Bad,
    /// 极差
    CHNetQuality_VeryBad,
    CHNetQuality_Down
};


#pragma mark - 媒体相关


typedef NS_ENUM(NSUInteger, CHSessionMuteState)
{
    CHSessionMuteState_UnMute    = 0,
    CHSessionMuteState_Mute
};


/// CHDeviceFaultType 设备故障类型
typedef NS_ENUM(NSUInteger, CHDeviceFaultType)
{
    /// 设备流正常
    CHDeviceFaultNone           = 0,
    /// 未知错误
    CHDeviceFaultUnknown        = 1,
    /// 没找到设备(无设备)
    CHDeviceFaultNotFind        = 2,
    /// 没有授权
    CHDeviceFaultNotAuth        = 3,
    /// 设备占用
    CHDeviceFaultOccupied       = 4,
    /// 约束无法获取设备流
    CHDeviceFaultConError       = 5,
    /// 约束都为false
    CHDeviceFaultConFalse       = 6,
    /// 获取设备流超时
    CHDeviceFaultStreamOverTime = 7,
    /// 设备流没有数据
    CHDeviceFaultStreamEmpty    = 8,
    /// 协商不成功
    CHDeviceFaultSDPFail        = 9
};

/// CHMediaState 媒体流发布状态
typedef NS_ENUM(NSUInteger, CHMediaState)
{
    /// 停止
    CHMediaState_Stop = 0,
    /// 播放
    CHMediaState_Play = 1,
    /// 暂停
    CHMediaState_Pause
};

#pragma mark - 信令相关

/// 房间即将关闭消息原因类型
typedef NS_OPTIONS(NSInteger, CHPrepareRoomEndType)
{
    /// 已经上课了但是老师退出房间达到10分钟
    CHPrepareRoomEndType_TeacherLeaveTimeout = 1 << 0,
    /// 房间预约结束时间超出30分钟
    CHPrepareRoomEndType_RoomTimeOut = 1 << 1
};

#pragma mark - 消息相关

/// 消息类型
typedef NS_ENUM(NSInteger, CHChatMessageType)
{
    /// 聊天文字消息
    CHChatMessageType_Text,
    /// 图片消息
    CHChatMessageType_OnlyImage,
    
    /// 提示信息
    CHChatMessageType_Tips,
    /// 撒花提示信息
    CHChatMessageType_ImageTips
};

/// 通知类型
typedef NS_ENUM(NSUInteger, CHQuestionState)
{
    /// 提问
    CHQuestionState_Question = 0,
    /// 审核的问题
    CHQuestionState_Responed,
    /// 回复
    CHQuestionState_Answer
};

#pragma mark - UI布局相关

/// 视频布局
typedef NS_ENUM(NSUInteger, CHRoomLayoutType)
{
    /// 视频常规
    CHRoomLayoutType_AroundLayout = 1,
    /// 视频布局
    CHRoomLayoutType_VideoLayout = 2,
    /// 焦点布局
    CHRoomLayoutType_FocusLayout = 3
};

#endif /* CHSessionEnum_h */
