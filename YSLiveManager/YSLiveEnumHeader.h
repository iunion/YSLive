//
//  YSLiveEnumHeader.h
//  YSLive
//
//  Created by jiang deng on 2019/10/16.
//  Copyright © 2019 FS. All rights reserved.
//

#ifndef YSLiveEnumHeader_h
#define YSLiveEnumHeader_h

/// 消息类型
typedef NS_ENUM(NSInteger, YSChatMessageType)
{
    YSChatMessageTypeText,          /** 聊天文字消息 */
    YSChatMessageTypeOnlyImage,     /** 聊天图片消息 */
    
    YSChatMessageTypeTips,          /** 提示信息： */
    YSChatMessageTypeImageTips,     /** 撒花提示信息： */
};

/// 房间即将关闭消息原因类型
typedef NS_OPTIONS(NSInteger, YSPrepareRoomEndType)
{
    /// 已经上课了但是老师退出房间达到10分钟
    YSPrepareRoomEndType_TeacherLeaveTimeout = 1 << 0,
    /// 房间预约结束时间超出30分钟
    YSPrepareRoomEndType_RoomTimeOut = 1 << 1
};


/// 签到时间
typedef NS_ENUM(NSUInteger, YSSignCountDownType)
{
    /// 1分钟
    YSSignCountDownType_ONE ,
    /// 3分钟
    YSSignCountDownType_THREE,
    /// 5分钟
    YSSignCountDownType_FIVE,
    /// 10分钟
    YSSignCountDownType_TEN,
    /// 30分钟
    YSSignCountDownType_THIRTY
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


typedef NS_ENUM(NSUInteger, YSLiveRoomLayout)
{
    YSLiveRoomLayout_AroundLayout = 1,  //视频常规
    YSLiveRoomLayout_VideoLayout = 2,    //视频布局
    YSLiveRoomLayout_FocusLayout = 3    //焦点布局
};

/// 小班课底部工具按钮
typedef NS_ENUM(NSInteger, SCBottomToolBarType)
{
    /** 轮询 */
    SCBottomToolBarTypePolling,
    /** 花名册 */
    SCBottomToolBarTypePersonList,
    /** 课件库 */
    SCBottomToolBarTypeCourseware,
    /** 工具箱 */
    SCBottomToolBarTypeToolBox,
    /** 切换布局 */
    SCBottomToolBarTypeSwitchLayout,
    /** 切换摄像头 */
    SCBottomToolBarTypeCamera,
    /** 全体禁音 */
    SCBottomToolBarTypeAllNoAudio,
    /** 消息 */
    SCBottomToolBarTypeChat,
    /** 退出 */
    SCBottomToolBarTypeExit,
    /** 展开收起 */
    SCBottomToolBarTypeOnOff
};

/// 小班课视频弹出工具类型
typedef NS_ENUM(NSInteger, SCVideoViewControlType)
{
    /** 音频控制 */
    SCVideoViewControlTypeAudio,
    /** 视频控制 */
    SCVideoViewControlTypeVideo,
    /** 镜像控制 */
    SCVideoViewControlTypeMirror,
    /** 画笔权限 */
    SCVideoViewControlTypeCanDraw,
    /** 上下台控制 */
    SCVideoViewControlTypeOnStage,
    /** 焦点 */
    SCVideoViewControlTypeFouce,
    /** 复位控制 */
    SCVideoViewControlTypeRestore,
    /** 奖杯 */
    SCVideoViewControlTypeGiftCup,
    /** 全体复位 */
    SCVideoViewControlTypeAllRestore,
    /** 全体奖杯 */
    SCVideoViewControlTypeAllGiftCup
};


typedef NS_ENUM(NSInteger, SCToolBoxType)
{
    /** 答题器 */
    SCToolBoxTypeAnswer,
    /** 花名册 */
    SCToolBoxTypeAlbum,
    /** 计时器 */
    SCToolBoxTypeTimer,
    /** 抢答器 */
    SCToolBoxTypeResponder,

};


/// 1:Android pad；2:Andriod phone；3:ipad；4:iphone；5:mac explorer；6:mac client；7:windows explorer；8:windows client
/// 用户设备类型
typedef NS_ENUM(NSUInteger, YSUserDevicetype)
{
    YSUserDevicetypeUnknow = 0,
    /** Android pad */
    YSUserDevicetypeAndroidPad = 1,
    /** Android phone */
    YSUserDevicetypeAndroidPhone,
    /** ipad */
    YSUserDevicetypeipad,
    /** iphone */
    YSUserDevicetypeiphone,
    /** mac explorer */
    YSUserDevicetypeMacExplorer,
    /** mac client */
    YSUserDevicetypeMacClient,
    /** windows explorer */
    YSUserDevicetypeWindowsExplorer,
    /** windows client */
    YSUserDevicetypeWindowsClient
};

typedef NS_ENUM(NSUInteger, YSClassFiletype)
{
    YSClassFiletype_Other,
    /** WhiteBoard */
    YSClassFiletype_WhiteBoard,
    /** PPT */
    YSClassFiletype_PPT,
    /** Excel */
    YSClassFiletype_Excel,
    /** Word */
    YSClassFiletype_Word,
    /** jpg */
    YSClassFiletype_JPG,
    /** Txt */
    YSClassFiletype_Txt,
    /** Mp4 */
    YSClassFiletype_Mp4,
    /** Mp3 */
    YSClassFiletype_Mp3,
    /** PDF */
    YSClassFiletype_PDF,
    /** H5 */
    YSClassFiletype_H5
};

#endif /* YSLiveEnumHeader_h */
