//
//  YSSessionEnum.h
//  YSSession
//
//  Created by jiang deng on 2020/6/10.
//  Copyright © 2020 YS. All rights reserved.
//

#ifndef YSSessionEnum_h
#define YSSessionEnum_h


#pragma mark - 房间相关

/// 房间即将关闭消息原因类型
typedef NS_OPTIONS(NSInteger, YSPrepareRoomEndType)
{
    /// 已经上课了但是老师退出房间达到10分钟
    YSPrepareRoomEndType_TeacherLeaveTimeout = 1 << 0,
    /// 房间预约结束时间超出30分钟
    YSPrepareRoomEndType_RoomTimeOut = 1 << 1
};

/// YSRoomWarningCode 警告码
typedef NS_ENUM(NSInteger, YSRoomWarningCode)
{
    YSRoomWarning_UnKnow,
    
    /// 麦克风不可用
    YSRoomWarning_Microphone_NotWorking                 = 111,
    /// the system has interrupted your audio session, the interruption has began
    YSRoomWarning_Micphone_InterruptionBegan,
    /// the interruption has ended
    YSRoomWarning_Micphone_InterruptionEnded,
    
    /// 使用耳机
    YSRoomWarning_AudioRouteChange_Headphones           = 121,
    /// 听筒模式（手机靠近耳边）
    YSRoomWarning_AudioRouteChange_BuiltInReceiver,
    /// 内置扬声器（外放）
    YSRoomWarning_AudioRouteChange_BuiltInSpeaker,
    /// 蓝牙
    YSRoomWarning_AudioRouteChange_Bluetooth,
    
    /// 请求获取摄像头失败
    YSRoomWarning_RequestAccessForVideo_Failed          = 131,
    /// 请求获取麦克风失败
    YSRoomWarning_RequestAccessForAudio_Failed          = 132,
    
    /// CheckRoom 成功
    YSRoomWarning_CheckRoom_Completed                   = 1001,
    /// GetConfig 成功
    YSRoomWarning_GetConfig_Completed                   = 1002,
    
    YSRoomWarning_UnpublishVideo_By_SwitchAudioRoom     = 1011,
    YSRoomWarning_PublishVideo_By_SwitchAudioVideoRoom  = 1012,
    YSRoomWarning_UnpublishVideo_By_Max_Reconnect_Count = 1013,
    YSRoomWarning_UnpublishAudio_By_Max_Reconnect_Count = 1014,
    
    YSRoomWarning_Stream_Connected                      = 1101,
    YSRoomWarning_Stream_Failed                         = 1102,
    YSRoomWarning_Stream_Closed                         = 1103,

    /// 切换了服务器
    YSRoomWarning_ReConnectSocket_ServerChanged         = 5002,
    /// 设备性能过低
    YSRoomWarning_DevicePerformance_Low                 = 5003
};

/// YSRoomErrorCode 错误码
typedef NS_ENUM(NSInteger, YSRoomErrorCode)
{
    YSErrorCode_UnKnow              = -2,
    YSErrorCode_Internal_Exception  = -1,
    YSErrorCode_OK                  = 0,
    
    YSErrorCode_Not_Initialized     = 101,
    YSErrorCode_Bad_Parameters      = 102,
    YSErrorCode_Room_StateError     = 103,
    YSErrorCode_Publish_StateError  = 104,
    YSErrorCode_Stream_StateError   = 105,
    YSErrorCode_Stream_NotFound     = 106,
    YSErrorCode_FilePath_NotExist   = 107,
    YSErrorCode_CreateFile_Failed   = 108,
    YSErrorCode_TestSpeed_Failed     = 109,
    /// view已被使用
    YSErrorCode_RenderView_ReUsed               = 110,
    
    YSErrorCode_Publish_NoAck                    = 401,
    YSErrorCode_Publish_RoomNotExist             = 402,
    YSErrorCode_Publish_RoomMaxVideoLimited      = 403,
    YSErrorCode_Publish_ErizoJs_Timeout          = 404,
    YSErrorCode_Publish_Agent_Timeout            = 405,
    YSErrorCode_Publish_UndefinedRPC_Timeout     = 406,
    YSErrorCode_Publish_AddingInput_Error        = 407,
    YSErrorCode_Publish_DuplicatedExtensionId    = 408,
    YSErrorCode_Publish_Unauthorized             = 409,
    /// 发布失败，自动重新发布
    YSErrorCode_Publish_Failed                   = 410,
    /// 发布超时，自动重新发布
    YSErrorCode_Publish_Timeout                  = 411,
    
    YSErrorCode_Subscribe_RoomNotExist           = 501,
    YSErrorCode_Subscribe_StreamNotDefine        = 502,
    YSErrorCode_Subscribe_MediaRPC_Timeout       = 503,
    /// 订阅失败，自动重新订阅
    YSErrorCode_Subscribe_Fail                   = 504,
    /// 订阅超时，自动重新订阅
    YSErrorCode_Subscribe_Timeout                = 505,
    
    YSErrorCode_ConnectSocketError               = 601,

    /// 参数错误
    YSErrorCode_JoinRoom_WrongParam              = 701,
    
    /// 获取房间信息失败
    YSErrorCode_CheckRoom_RequestFailed          = 801,
    /// 获取房间配置失败
    YSErrorCode_RoomConfig_RequestFailed         = 802,
    
    /// 服务器过期
    YSErrorCode_CheckRoom_ServerOverdue          = 3001,
    /// 公司被冻结
    YSErrorCode_CheckRoom_RoomFreeze             = 3002,
    /// 房间已删除或过期
    YSErrorCode_CheckRoom_RoomDeleteOrOrverdue   = 3003,
    /// 该公司不存在
    YSErrorCode_CheckRoom_CompanyNotExist        = 4001,
    /// 房间不存在
    YSErrorCode_CheckRoom_RoomNonExistent        = 4007,
    /// 房间密码错误
    YSErrorCode_CheckRoom_PasswordError          = 4008,
    /// 密码与身份不符
    YSErrorCode_CheckRoom_WrongPasswordForRole   = 4012,
    /// 房间人数超限
    YSErrorCode_CheckRoom_RoomNumberOverRun      = 4103,
    /// 认证错误
    YSErrorCode_CheckRoom_RoomAuthenError        = 4109,
    /// 该房间需要密码，请输入密码
    YSErrorCode_CheckRoom_NeedPassword           = 4110,
    /// 企业点数超限
    YSErrorCode_CheckRoom_RoomPointOverrun       = 4112
};

/// 房间类型 0:表示一对一教室  非0:表示一多教室
typedef NS_ENUM(NSUInteger, YSRoomUserType)
{
    /// 0
    YSRoomUserType_None,
    /// 1 V 1
    YSRoomUserType_One,
    /// 1 V N
    YSRoomUserType_More
};

/// 房间使用场景  3：小班课  4：直播   6：会议
typedef NS_ENUM(NSUInteger, YSRoomUseType)
{
    /// 小班课
    YSRoomUseTypeSmallClass = 3,
    /// 直播
    YSRoomUseTypeLiveRoom = 4,
    /// 会议
    YSRoomUseTypeMeeting = 6
};

/// YSRoomStatus 房间状态
typedef NS_ENUM(NSUInteger, YSRoomStatus)
{
    YSSTATUS_IDLE          = 0,
    YSSTATUS_CHECKING      = 1,
    YSSTATUS_TESTING       = 2,
    YSSTATUS_CONNECTING    = 3,
    YSSTATUS_CONNECTED     = 4,
    YSSTATUS_JOINING       = 5,
    YSSTATUS_ALLREADY      = 6,
    YSSTATUS_DISCONNECTING = 7,
    YSSTATUS_DISCONNECTED  = 8,
    YSSTATUS_RECONNECTING  = 9
};


#pragma mark - 用户相关

/// YSUserRoleType 用户角色
typedef NS_ENUM(NSInteger, YSUserRoleType)
{
    /// 回放
    YSUserType_Playback = -1,
    /// 老师
    YSUserType_Teacher = 0,
    /// 助教
    YSUserType_Assistant,
    /// 学生
    YSUserType_Student,
    /// 直播
    YSUserType_Live,
    /// 巡课
    YSUserType_Patrol
};

/// YSUserMediaPublishState 发布状态 需要转换YSPublishState
typedef NS_OPTIONS(NSUInteger, YSUserMediaPublishState)
{
    /// 没有发布
    YSUserMediaPublishState_NONE         = 0,
    /// 在台上，关掉了音频视频
    YSUserMediaPublishState_NONEONSTAGE  = 1 << 0,
    /// 在台上，只有音频
    YSUserMediaPublishState_AUDIOONLY    = 1 << 1,
    /// 在台上，只有视频
    YSUserMediaPublishState_VIDEOONLY    = 1 << 2,
    /// 在台上，音视频都有
    YSUserMediaPublishState_BOTH         = YSUserMediaPublishState_AUDIOONLY | YSUserMediaPublishState_VIDEOONLY
};

/// YSPublishState 发布状态
typedef NS_ENUM(NSInteger, YSPublishState)
{
    /// 未知状态
    YSUser_PublishState_UNKown          = -2,
    /// 没有
    YSUser_PublishState_NONE            = 0,
    /// 只有音频
    YSUser_PublishState_AUDIOONLY,
    /// 只有视频
    YSUser_PublishState_VIDEOONLY,
    /// 都有
    YSUser_PublishState_BOTH,
    /// 台上
    YSUser_PublishState_ONSTAGE         = 4
};


#pragma mark - 网络相关

typedef NS_ENUM(NSUInteger, YSNetQuality)
{
    /// 优
    YSNetQuality_Excellent  = 1,
    /// 良
    YSNetQuality_Good,
    /// 中
    YSNetQuality_Accepted,
    /// 差
    YSNetQuality_Bad,
    /// 极差
    YSNetQuality_VeryBad,
    YSNetQuality_Down
};


#pragma mark - 媒体相关

/// YSDeviceFaultType 设备故障类型
typedef NS_ENUM(NSUInteger, YSDeviceFaultType)
{
    /// 设备流正常
    YSDeviceFaultNone           = 0,
    /// 未知错误
    YSDeviceFaultUnknown        = 1,
    /// 没找到设备(无设备)
    YSDeviceFaultNotFind        = 2,
    /// 没有授权
    YSDeviceFaultNotAuth        = 3,
    /// 设备占用
    YSDeviceFaultOccupied       = 4,
    /// 约束无法获取设备流
    YSDeviceFaultConError       = 5,
    /// 约束都为false
    YSDeviceFaultConFalse       = 6,
    /// 获取设备流超时
    YSDeviceFaultStreamOverTime = 7,
    /// 设备流没有数据
    YSDeviceFaultStreamEmpty    = 8,
    /// 协商不成功
    YSDeviceFaultSDPFail        = 9
};

///// YSVideoMirrorMode 视频渲染镜像模式
//typedef NS_ENUM(NSUInteger, YSVideoMirrorMode)
//{
//    /// 前置摄像头时开启镜像模式，后置摄像头时不开启镜像
//    YSVideoMirrorModeAuto       = 0,
//    /// 默认设置，前置和后置均开启镜像模式
//    YSVideoMirrorModeEnabled    = 1,
//    /// 前置和后置均不开启镜像模式
//    YSVideoMirrorModeDisabled   = 2,
//};

/// YSMediaState 媒体流发布状态
typedef NS_ENUM(NSUInteger, YSMediaState)
{
    /// 停止
    YSMediaState_Stop = 0,
    /// 播放
    YSMediaState_Play = 1,
    /// 暂停
    YSMediaState_Pause
};


#pragma mark - 消息相关

/// 消息类型
typedef NS_ENUM(NSInteger, YSChatMessageType)
{
    /// 聊天文字消息
    YSChatMessageType_Text,
    /// 图片消息
    YSChatMessageType_OnlyImage,
    
    /// 提示信息
    YSChatMessageType_Tips,
    /// 撒花提示信息
    YSChatMessageType_ImageTips
};

/// 通知类型
typedef NS_ENUM(NSUInteger, YSQuestionState)
{
    /// 提问
    YSQuestionState_Question = 0,
    /// 审核的问题
    YSQuestionState_Responed,
    /// 回复
    YSQuestionState_Answer
};

#pragma mark - UI布局相关

/// 视频布局
typedef NS_ENUM(NSUInteger, YSRoomLayoutType)
{
    /// 视频常规
    YSRoomLayoutType_AroundLayout = 1,
    /// 视频布局
    YSRoomLayoutType_VideoLayout = 2,
    /// 焦点布局
    YSRoomLayoutType_FocusLayout = 3
};




#endif /* YSSessionEnum_h */
