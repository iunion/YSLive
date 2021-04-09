//
//  YSLiveEnumHeader.h
//  YSLive
//
//  Created by jiang deng on 2019/10/16.
//  Copyright © 2019 FS. All rights reserved.
//

#ifndef YSLiveEnumHeader_h
#define YSLiveEnumHeader_h

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
    /** 视频调整 */
    SCBottomToolBarTypeVideoAdjustment,
    /** 消息 */
    SCBottomToolBarTypeChat,
    /** 退出 */
    SCBottomToolBarTypeExit,
    /** 展开收起 */
    SCBottomToolBarTypeOnOff
};

/// 小班课视频弹出工具类型
typedef NS_ENUM(NSInteger, CHVideoViewControlType)
{
    /** 音频控制 */
    CHVideoViewControlTypeAudio,
    /** 视频控制 */
    CHVideoViewControlTypeVideo,
    /** 镜像控制 */
    CHVideoViewControlTypeMirror,
    /** 画笔权限 */
    CHVideoViewControlTypeCanDraw,
    /** 上下台控制 */
    CHVideoViewControlTypeOnStage,
    /** 焦点 */
    CHVideoViewControlTypeFouce,
    /** 复位控制 */
    CHVideoViewControlTypeRestore,
    /** 奖杯 */
    CHVideoViewControlTypeGiftCup,
    /** 全体复位 */
    CHVideoViewControlTypeAllRestore,
    /** 全体奖杯 */
    CHVideoViewControlTypeAllGiftCup
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
    /** 骰子*/
    SCToolBoxTypeDice,
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

/// 全屏时视频切换按钮
typedef enum : NSUInteger {
    FullFloatControlCancle = 1,
    FullFloatControlMine,
    FullFloatControlAll,
} FullFloatControl;


#endif /* YSLiveEnumHeader_h */
