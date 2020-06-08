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

/// 白板文档格式类型
typedef NS_ENUM(NSUInteger, YSWhiteBordDocType)
{
    /// 普通文档
    YSWhiteBordDocType_GeneralFile = 0,
    /// 动态ppt
    YSWhiteBordDocType_DynamicPPT,
    /// 新版动态ppt
    YSWhiteBordDocType_NewDynamicPPT,
    /// h5文档
    YSWhiteBordDocType_H5Document
};

/// 白板文档媒体类型
//typedef NS_ENUM(NSUInteger, YSWhiteBordMediaType)
//{
//    /// 普通文档
//    YSWhiteBordMediaType_Video = 0,
//    /// 动态ppt
//    YSWhiteBordMediaType_Audio
//};

typedef NS_ENUM(NSUInteger, YSLiveRoomLayout)
{
    YSLiveRoomLayout_AroundLayout = 1,  //视频常规
    YSLiveRoomLayout_VideoLayout = 2,    //视频布局
    YSLiveRoomLayout_FocusLayout = 3    //焦点布局
};


/// 房间布局（51，52，53一对一布局，1，2，3，4，6，7一对多布局）
//typedef NS_ENUM(NSUInteger, YSLiveRoomLayout)
//{
//    RoomLayout_CoursewareDown = 1,      //视频置顶
//    RoomLayout_VideoDown = 2,           //视频置底
//    RoomLayout_Encompassment,           //视频围绕
//    RoomLayout_Bilateral,               //多人模式
//    RoomLayout_MainPeople = 6,          //主讲排列
//    RoomLayout_OnlyVideo = 7,           //自由视频
//
//    RoomLayout_oneToOne = 51,                   //常规布局(一对一)
//    RoomLayout_oneToOneDoubleDivision = 52,     //双师布局(一对一)
//    RoomLayout_oneToOneDoubleVideo = 53         //视频布局(一对一)
//};


/// app使用场景  3：小班课  4：直播   6：会议
typedef NS_ENUM(NSInteger, YSAppUseTheType)
{
    /** 小班课 */
    YSAppUseTheTypeSmallClass = 3,
    /** 直播 */
    YSAppUseTheTypeLiveRoom = 4,
    /** 会议*/
    YSAppUseTheTypeMeeting = 6
};

///// 小班课老师端顶部按钮
//typedef NS_ENUM(NSInteger, SCTeacherTopBarType)
//{
//    /** 轮询 */
//    SCTeacherTopBarTypePolling,
//    /** 花名册 */
//    SCTeacherTopBarTypePersonList,
//    /** 课件库 */
//    SCTeacherTopBarTypeCourseware,
//    /** 工具箱 */
//    SCTeacherTopBarTypeToolBox,
//    /** 全体控制 */
//    SCTeacherTopBarTypeAllControll,
//    /** 切换布局 */
//    SCTeacherTopBarTypeSwitchLayout,
//    /** 切换摄像头 */
//    SCTeacherTopBarTypeCamera,
//    /** 全体禁音 */
//    SCTeacherTopBarTypeAllNoAudio,
//    /** 消息 */
//    SCTeacherTopBarTypeChat,
//    /** 退出 */
//    SCTeacherTopBarTypeExit,
//    /** 展开收起 */
//    SCTeacherTopBarTypeOnOff
//};

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

//typedef NS_ENUM(NSInteger, PublishState) {
//    YSPublishStateNONE           = 0,            //没有
//    YSPublishStateAUDIOONLY      = 1,            //只有音频
//    YSPublishStateVIDEOONLY      = 2,            //只有视频
//    YSPublishStateBOTH           = 3,            //都有
//    YSPublishStateNONEONSTAGE    = 4,            //音视频都没有 但还在台上
//    YSPublishStateLocalNONE      = 5             //本地显示流
//};

typedef NS_OPTIONS(NSInteger, SCUserPublishState)
{
    SCUserPublishState_NONE         = 0,            // 没有
    SCUserPublishState_NONEONSTAGE  = 1 << 0,       // 在台上
    SCUserPublishState_AUDIOONLY    = 1 << 1,       // 在台上只有音频
    SCUserPublishState_VIDEOONLY    = 1 << 2,       // 在台上只有视频
    SCUserPublishState_BOTH         = SCUserPublishState_AUDIOONLY | SCUserPublishState_VIDEOONLY
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
