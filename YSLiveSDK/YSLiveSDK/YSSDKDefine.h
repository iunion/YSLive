//
//  YSSDKDefine.h
//  YSSDK
//
//  Created by jiang deng on 2019/11/28.
//  Copyright © 2019 YS. All rights reserved.
//

#ifndef YSSDKDefine_h
#define YSSDKDefine_h

/// 用户属性
typedef NS_ENUM(NSUInteger, YSSDKUserRoleType)
{
    YSSDKUserType_Teacher = 0,     //老师
    //YSSDKUserType_Assistant,       //助教
    YSSDKSUserType_Student = 2,    //学生
    //YSSDKSUserType_Live,           //直播
    //YSSDKSUserType_Patrol = 4      //巡课
};

/// app使用场景  3：小班课  4：直播   6：会议
typedef NS_ENUM(NSInteger, YSSDKUseTheType)
{
    /** 小班课 */
    YSSDKUseTheType_SmallClass = 3,
    /** 直播 */
    YSSDKUseTheType_LiveRoom = 4,
    /** 会议*/
    YSSDKUseTheType_Meeting = 6
};

/// 错误码
typedef NS_ENUM(NSInteger, YSSDKErrorCode)
{
    YSSDKErrorCode_UnKnow              = -2,
    YSSDKErrorCode_Internal_Exception  = -1,
    YSSDKErrorCode_OK                  = 0,
    
    YSSDKErrorCode_Not_Initialized     = 101,
    YSSDKErrorCode_Bad_Parameters      = 102,
    YSSDKErrorCode_Room_StateError     = 103,
    YSSDKErrorCode_Publish_StateError  = 104,
    YSSDKErrorCode_Stream_StateError   = 105,
    YSSDKErrorCode_Stream_NotFound     = 106,
    YSSDKErrorCode_FilePath_NotExist   = 107,
    YSSDKErrorCode_CreateFile_Failed   = 108,
    YSSDKErrorCode_TestSpeed_Failed     = 109,
    YSSDKErrorCode_RenderView_ReUsed               = 110,//view已被使用
    
    YSSDKErrorCode_Publish_NoAck                    = 401,
    YSSDKErrorCode_Publish_RoomNotExist             = 402,
    YSSDKErrorCode_Publish_RoomMaxVideoLimited      = 403,
    YSSDKErrorCode_Publish_ErizoJs_Timeout          = 404,
    YSSDKErrorCode_Publish_Agent_Timeout            = 405,
    YSSDKErrorCode_Publish_UndefinedRPC_Timeout     = 406,
    YSSDKErrorCode_Publish_AddingInput_Error        = 407,
    YSSDKErrorCode_Publish_DuplicatedExtensionId    = 408,
    YSSDKErrorCode_Publish_Unauthorized             = 409,
    YSSDKErrorCode_Publish_Failed                   = 410,//发布失败，自动重新发布
    YSSDKErrorCode_Publish_Timeout                  = 411,//发布失败，自动重新发布
    
    YSSDKErrorCode_Subscribe_RoomNotExist           = 501,
    YSSDKErrorCode_Subscribe_StreamNotDefine        = 502,
    YSSDKErrorCode_Subscribe_MediaRPC_Timeout       = 503,
    YSSDKErrorCode_Subscribe_Fail                   = 504,//订阅失败，自动重新订阅
    YSSDKErrorCode_Subscribe_Timeout                = 505,//订阅超时，自动重新订阅
    
    YSSDKErrorCode_ConnectSocketError               = 601,

    YSSDKErrorCode_JoinRoom_WrongParam              = 701,// 参数错误
    
    YSSDKErrorCode_CheckRoom_RequestFailed          = 801,    //获取房间信息失败
    YSSDKErrorCode_RoomConfig_RequestFailed         = 802,    //获取房间配置失败
    
    YSSDKErrorCode_CheckRoom_ServerOverdue          = 3001,    //服务器过期
    YSSDKErrorCode_CheckRoom_RoomFreeze             = 3002,    //公司被冻结
    YSSDKErrorCode_CheckRoom_RoomDeleteOrOrverdue   = 3003,    //房间已删除或过期
    YSSDKErrorCode_CheckRoom_CompanyNotExist        = 4001,    //该公司不存在
    YSSDKErrorCode_CheckRoom_RoomNonExistent        = 4007,    //房间不存在
    YSSDKErrorCode_CheckRoom_PasswordError          = 4008,    //房间密码错误
    YSSDKErrorCode_CheckRoom_WrongPasswordForRole   = 4012,    //密码与身份不符
    YSSDKErrorCode_CheckRoom_RoomNumberOverRun      = 4103,    //房间人数超限
    YSSDKErrorCode_CheckRoom_RoomAuthenError        = 4109,    //认证错误
    YSSDKErrorCode_CheckRoom_NeedPassword           = 4110,    //该房间需要密码，请输入密码
    YSSDKErrorCode_CheckRoom_RoomPointOverrun       = 4112,    //企业点数超限
};

#endif /* YSSDKDefine_h */
