//
//  YSLiveMacros.h
//  YSLive
//
//  Created by jiang deng on 2019/10/14.
//  Copyright © 2019 FS. All rights reserved.
//

#ifndef YSLiveMacros_h
#define YSLiveMacros_h

#define YSWHITEBOARD_USEHTTPDNS 1
#if YSSDK
#define YSWHITEBOARD_USEHTTPDNS_ADDALI 0
#else
#define YSWHITEBOARD_USEHTTPDNS_ADDALI 1
#endif

/// 当前用户的model
#define YSCurrentUser [YSLiveManager shareInstance].localUser

#define YSLive_AppKey       @""

#define YSLive_LogPath      @"YSLive_Log"

#define YSLive_HTTPS         1

#define YSLive_Http         YSLive_HTTPS ? @"https" : @"http"
#define YSLive_Port         YSLive_HTTPS ? (443) : (80)
#define YSLive_IsHttps      YSLive_HTTPS ? @"YES" : @"NO"


#define YSSchool_Server     @"school.roadofcloud.net"

#if USE_TEST_HELP

// 开发环境
#define YSLIVE_HOST_DEV         @"demo.roadofcloud.net"
#define YS_SIGNINADDRESS_DEV    @"https://1069568596212347.cn-beijing.fc.aliyuncs.com/2016-08-15/proxy/demo/addsignin/"
#define YS_FLOWERADDRESS_DEV    @"https://1069568596212347.cn-beijing.fc.aliyuncs.com/2016-08-15/proxy/demo/sendflowers/"

// 测试环境
#define YSLIVE_HOST_TEST        @"release.roadofcloud.net"
#define YS_SIGNINADDRESS_TEST   @"https://1069568596212347.cn-beijing.fc.aliyuncs.com/2016-08-15/proxy/release/addsignin/"
#define YS_FLOWERADDRESS_TEST   @"https://1069568596212347.cn-beijing.fc.aliyuncs.com/2016-08-15/proxy/release/sendflowers/"

// 线上环境
#define YSLIVE_HOST_ONLINE      @"api.roadofcloud.net"
#define YS_SIGNINADDRESS_ONLINE @"https://1069568596212347.cn-beijing.fc.aliyuncs.com/2016-08-15/proxy/interaction/addsignin/"
#define YS_FLOWERADDRESS_ONLINE @"https://1069568596212347.cn-beijing.fc.aliyuncs.com/2016-08-15/proxy/interaction/sendflowers/"

#define YSLIVE_HOST_INIT        YSLIVE_HOST_DEV
#define YS_SIGNINADDRESS_INIT   YS_SIGNINADDRESS_DEV
#define YS_FLOWERADDRESS_INIT   YS_FLOWERADDRESS_DEV

#define YSLIVE_HOST_KEY         (@"debug_roomhost")
#define YSLIVE_HOST             [[NSUserDefaults standardUserDefaults] objectForKey:YSLIVE_HOST_KEY]

#define YS_SIGNINADDRESS_KEY    (@"debug_signinAddress")
#define YS_SIGNINADDRESS        [[NSUserDefaults standardUserDefaults] objectForKey:YS_SIGNINADDRESS_KEY]

#define YS_FLOWERADDRESS_KEY    (@"debug_flowerAddress")
#define YS_FLOWERADDRESS        [[NSUserDefaults standardUserDefaults] objectForKey:YS_FLOWERADDRESS_KEY]

#define YSLIVE_ROOMIDINDEX_KEY  (@"debug_roomidindex")
#define YSLIVE_ROOMIDINDEX      [[NSUserDefaults standardUserDefaults] objectForKey:YSLIVE_ROOMIDINDEX_KEY]

#else

//#define YSLIVE_HOST_INIT        @"api.roadofcloud.com"
//#define YSLIVE_HOST_KEY         (@"release_roomhost")
#define YSLIVE_HOST             @"api.roadofcloud.net"

#define YS_SIGNINADDRESS        @"https://1069568596212347.cn-beijing.fc.aliyuncs.com/2016-08-15/proxy/interaction/addsignin/"
#define YS_FLOWERADDRESS        @"https://1069568596212347.cn-beijing.fc.aliyuncs.com/2016-08-15/proxy/interaction/sendflowers/"

#endif

// 1812719198       iOS 一对一16:9
// 947444868        iOS 一对一4:3
//#define YSLive_RoomId @"1955519694"  //直播间

//#define YSLive_RoomId @"357839743"

//#define YSLive_RoomId @"1195050735"  //小班课 IOS_1V多_  16：9
#define YSLive_RoomId @"922739244"  //小班课 IOS_1V多_  4：3
//#define YSLive_RoomId       @"1164674398" //小班课IOS_1V1_ 16:9
//#define YSLive_RoomId       @"1672617739" //小班课IOS_1V1_  4:3
//#define YSLive_RoomId       @"1011757934"  //直播

#define YSWhiteBoard_HttpDnsService_AccountID   131798


/// 网宿host头
static NSString *const YSWhiteBoard_domain_ws_header = @"rddoccdnws.roadofcloud";
static NSString *const YSWhiteBoard_domain_demows_header = @"rddoccdndemows.roadofcloud";
/// 网宿host
static NSString *const YSWhiteBoard_domain_ws = @"rddoccdnws.roadofcloud.com";
static NSString *const YSWhiteBoard_domain_demows = @"rddoccdndemows.roadofcloud.com";

/// 网宿dns解析
static NSString *const YSWhiteBoard_wshttpdnsurl = @"http://edge.wshttpdns.com/v1/httpdns/clouddns";

#if YSWHITEBOARD_USEHTTPDNS_ADDALI
/// 阿里host头
static NSString *const YSWhiteBoard_domain_ali_header = @"rddoccdn.roadofcloud";
static NSString *const YSWhiteBoard_domain_demoali_header = @"rddocdemo.roadofcloud";
/// 阿里host
static NSString *const YSWhiteBoard_domain_ali = @"rddoccdn.roadofcloud.com";
static NSString *const YSWhiteBoard_domain_demoali = @"rddocdemo.roadofcloud.com";
#endif

#pragma mark - NSDictionary Keys

// 缓存数据key
static NSString *const kYSMethodNameKey = @"YSCacheMsg_MethodName"; // 缓存函数名
static NSString *const kYSParameterKey = @"YSCacheMsg_Parameter";  // 缓存参数


// 起始请小写
#pragma mark - NSUserDefaults Keys

// 被T时间
static NSString *const YSKickTime = @"ysKickTime";
static NSString *const TKKickRoom = @"TKKickRoom";


#pragma mark - NSNotificationName Keys

//static NSNotificationName const ysPluggInMicrophoneNotification = @"ysPluggInMicrophone";
//static NSNotificationName const ysUnunpluggingHeadsetNotification = @"ysUnunpluggingHeadset";

// 接收聊天消息通知
static NSNotificationName const ysReceiveMessageNotification = @"ysReceiveMessageNotification";
// 人员更新通知
//static NSNotificationName const ysUserListNotification = @"ysUserListNotification";

static NSNotificationName const ysClassBeginNotification = @"ysCeacherControlClassBegin";


#pragma mark - 用户属性
// sdk管理 ?
/// 发布状态
static  NSString *const sUserPublishstate           = @"publishstate";
/// 画笔权限 YES NO
static  NSString *const sUserCandraw                = @"candraw";
/// UDP状态发生变化，1是畅通，2是防火墙导致不畅通
static  NSString *const sUserUdpState               = @"udpstate";
/// 关闭视频 YES NO
static  NSString *const sUserDisableVideo           = @"disablevideo";
/// 关闭音频 YES NO
static  NSString *const sUserDisableAudio           = @"disableaudio";

/// 是否进入后台 YES NO
static  NSString *const sUserIsInBackGround         = @"isInBackGround";

/// 用户设备状态
static  NSString *const sUserVideoFail              = @"vfail";
static  NSString *const sUserAudioFail              = @"afail";



/// 用户设备类型
/// AndroidPad:Android pad；AndroidPhone:Andriod phone；
/// iPad:iPad；iPhone:iPhone；
/// MacPC:mac explorer；MacClient:mac client；
/// WindowPC:windows explorer；WindowClient:windows client
static  NSString *const sUserDevicetype             = @"devicetype";

// 用户管理 ?
/// 举手 YES NO 允许上台
static  NSString *const sUserRaisehand              = @"raisehand";
/// 画笔颜色值
static  NSString *const sUserPrimaryColor           = @"primaryColor";
/// 奖杯数
static  NSString *const sUserGiftNumber             = @"giftnumber";
static  NSString *const sUserGiftinfo               = @"giftinfo";
/// 是否禁言 YES NO
static  NSString *const sUserDisablechat            = @"disablechat";

/// 网络状态 0:好 1：差
static  NSString *const sUserNetWorkState            = @"medialinebad";


static  NSString *const sVolume                     = @"volume";
static  NSString *const sFromId                     = @"fromId";
static  NSString *const sUser                        = @"User";

/// 允许/拒绝上麦
static  NSString *const sUserUpPlatform            = @"isAllowUpPlatForm";

// 全体静音
static  NSString *const sMuteAudio                  = @"MuteAudio";


#pragma mark - 待删除

static  NSString *const sMobile                     = @"mobile";//拍照上传入口
static  NSString *const sLowConsume                 = @"LowConsume";

static  NSString *const sClassBegin                 = @"ClassBegin";//上课
static  NSString *const sStreamFailure              = @"StreamFailure";
static  NSString *const sAllAll                     = @"__AllAll";
static  NSString *const sVideoDraghandle            = @"videoDraghandle";//视频拖拽
static  NSString *const sVideoSplitScreen           = @"VideoSplitScreen";//分屏
static  NSString *const sDoubleClickVideo           = @"doubleClickVideo";//双击视频
static  NSString *const sVideoZoom                  = @"VideoChangeSize";//视频缩放
static  NSString *const sChangeServerArea           = @"RemoteControl";// 助教协助切换服务器（课件服务器）
static  NSString *const sServerName                 = @"servername";//助教协助切换服务器（优选网络）
static  NSString *const sUpdateTime                 = @"UpdateTime";

static  NSString *const sEveryoneBanChat            = @"EveryoneBanChat";//全体禁言
static  NSString *const sOnlyAudioRoom              = @"OnlyAudioRoom"; //音频教室
static  NSString *const sWBFullScreen               = @"FullScreen";// 全屏
static  NSString *const sBigRoom                    = @"BigRoom";// 大并发
static  NSString *const sTimer                      = @"timer";// 计时器
static  NSString *const sShowPageBeforeClass        = @"ShowPageBeforeClass";// 课前切换课件
static  NSString *const sSwitchLayout               = @"switchLayout";// 布局切换

// 白板信令
static  NSString *const sWBPageCount                = @"WBPageCount";//加页
static  NSString *const sShowPage                   = @"ShowPage";//显示文档
static  NSString *const sDocumentFilePage_ShowPage  = @"DocumentFilePage_ShowPage";
static  NSString *const sActionShow                 = @"show";
static  NSString *const sSharpsChange               = @"SharpsChange";//画笔
static  NSString *const sDocumentChange             = @"DocumentChange";//添加或删除文档
static  NSString *const sOnPageFinished             = @"onPageFinished";
static  NSString *const sChangeWebPageFullScreen    = @"changeWebPageFullScreen";//白板放大事件
static  NSString *const sOnJsPlay                   = @"onJsPlay";
static  NSString *const scloseDynamicPptWebPlay     = @"closeDynamicPptWebPlay";//closeNewPptVideo更改为closeDynamicPptWebPlay

// 工具箱 - 抢答器
static  NSString *const sQiangDaQi                  = @"qiangDaQi";
static  NSString *const sQiangDaQiMesg              = @"qiangDaQiMesg";
static  NSString *const sQiangDaZhe                 = @"QiangDaZhe";
static  NSString *const sResponderDrag              = @"ResponderDrag";
static  NSString *const sActionID                   = @"actionID";

// 自定义
static  NSString *const sNeedPictureInPictureSmall  = @"needPictureInPictureSmall";

//小白板
static  NSString *const sAssociatedMsgID            = @"associatedMsgID";
static  NSString *const sName                       = @"name";
static  NSString *const s_Prepareing                = @"_prepareing";
static  NSString *const s_Dispenseed                = @"_dispenseed";
static  NSString *const s_Recycle                   = @"_recycle";
static  NSString *const s_AgainDispenseed           = @"_againDispenseed";

static  NSString *const sBlackBoardState            = @"blackBoardState";
static  NSString *const sCurrentTapKey              = @"currentTapKey";
static  NSString *const sBlackBoard_new             = @"BlackBoard_new";
static  NSString *const sUserHasNewBlackBoard       = @"UserHasNewBlackBoard";
static  NSString *const sWhiteboardID               = @"whiteboardID";

static  NSString *const sBlackBoardCommon           = @"blackBoardCommon";

// 播放mp3，mp4
static  NSString *const sVideo_MediaFilePage_ShowPage   = @"Video_MediaFilePage_ShowPage";
static  NSString *const sAudio_MediaFilePage_ShowPage   = @"Audio_MediaFilePage_ShowPage";

//白板类型
static  NSString *const sVideoWhiteboard                = @"VideoWhiteboard";

//拍摄照片、选择照片上传
static  NSString *const sTakePhotosUploadNotification   = @"sTakePhotosUploadNotification";
static  NSString *const sChoosePhotosUploadNotification = @"sChoosePhotosUploadNotification";

// 皮肤
static NSString *const TKCartoonSkin = @"purple";// 默认紫色 皮肤
static NSString *const TKBlackSkin   = @"black"; // 黑皮
static NSString *const TKOrangeSkin   = @"tigerlily"; // 橙皮




// 上下台时间间隔标识符
static NSString *const TKUnderPlatformTime = @"TKUnderPlatformTime";

static NSNotificationName const sDocListViewNotification = @"docListViewNotification";


#endif /* YSLiveMacros_h */

#import "YSLiveEnumHeader.h"

#import "YSLiveUtil.h"
