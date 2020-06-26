//
//  YSSessionDefines.h
//  YSSession
//
//  Created by jiang deng on 2020/6/10.
//  Copyright © 2020 YS. All rights reserved.
//

#ifndef YSSessionDefines_h
#define YSSessionDefines_h

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
static  NSString *const sYSUserRaisehand            = @"raisehand";

/// 是否禁言 YES NO
static  NSString *const sYSUserDisablechat          = @"disablechat";

/// 奖杯数
static  NSString *const sYSUserGiftNumber           = @"giftnumber";


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

/// 服务器时间同步
static NSString *const sYSSignalUpdateTime              = @"UpdateTime";

/// 上课
static NSString *const sYSSignalClassBegin              = @"ClassBegin";

/// 大房间用户数
static NSString *const sYSSignalNotice_BigRoom_Usernum  = @"Notice_BigRoom_Usernum";

/// 设置用户属性
static NSString *const sYSSignalSetProperty             = @"setProperty";

/// 发布网络文件流的方法
static NSString *const sYSSignalPublishNetworkMedia     = @"publishNetworkMedia";
/// 取消发布网络文件流
static NSString *const sYSSignalUnpublishNetworkMedia   = @"unpublishNetworkMedia";

/// 投票
static NSString *const sYSSignalVoteStart = @"VoteStart";
/// 发送投票
static NSString *const sYSSignalVoteCommit  = @"voteCommit";
/// 投票结果
static NSString *const sYSSignalPublicVoteResult = @"PublicVoteResult";


#endif /* YSSessionDefines_h */
