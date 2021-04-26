//
//  YSLiveMacros.h
//  YSLive
//
//  Created by jiang deng on 2019/10/14.
//  Copyright © 2019 FS. All rights reserved.
//

#ifndef YSLiveMacros_h
#define YSLiveMacros_h

/// 当前用户的model
#define YSCurrentUser [YSLiveManager sharedInstance].localUser

#define YSLive_AppKey       @""

#define YSLive_LogPath      @"YSLive_Log"

#define YSLive_HTTPS         1

#define YSLive_Http         YSLive_HTTPS ? @"https" : @"http"
#define YSLive_Port         YSLive_HTTPS ? (443) : (80)
#define YSLive_IsHttps      YSLive_HTTPS ? @"YES" : @"NO"


//#define YSSchool_Server     @"school.roadofcloud.net"
#define YSSchool_Server     @"school.cloudhub.vip"

#if USE_TEST_HELP

// 开发环境
//#define YSLIVE_HOST_DEV         @"demo.roadofcloud.net"
#define YSLIVE_HOST_DEV         @"api-demo.cloudhub.vip"
#define YS_SIGNINADDRESS_DEV    @"https://1069568596212347.cn-beijing.fc.aliyuncs.com/2016-08-15/proxy/demo/addsignin/"
#define YS_FLOWERADDRESS_DEV    @"https://1069568596212347.cn-beijing.fc.aliyuncs.com/2016-08-15/proxy/demo/sendflowers/"

// 测试环境
//#define YSLIVE_HOST_TEST        @"release.roadofcloud.net"
#define YSLIVE_HOST_TEST        @"api-release.cloudhub.vip"
#define YS_SIGNINADDRESS_TEST   @"https://1069568596212347.cn-beijing.fc.aliyuncs.com/2016-08-15/proxy/release/addsignin/"
#define YS_FLOWERADDRESS_TEST   @"https://1069568596212347.cn-beijing.fc.aliyuncs.com/2016-08-15/proxy/release/sendflowers/"

// 线上环境
//#define YSLIVE_HOST_ONLINE      @"api.roadofcloud.net"
#define YSLIVE_HOST_ONLINE      @"api.cloudhub.vip"
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
//#define YSLIVE_HOST             @"api.roadofcloud.net"
#define YSLIVE_HOST             @"api.cloudhub.vip"

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


#pragma mark - NSDictionary Keys

// 缓存数据key
//static NSString *const kYSMethodNameKey = @"YSCacheMsg_MethodName"; // 缓存函数名
//static NSString *const kYSParameterKey = @"YSCacheMsg_Parameter";  // 缓存参数


// 起始请小写
#pragma mark - NSUserDefaults Keys

// 被T时间
static NSString *const YSKickTime = @"ysKickTime";
static NSString *const TKKickRoom = @"TKKickRoom";


#pragma mark - NSNotificationName Keys

// 接收聊天消息通知
static NSNotificationName const ysReceiveMessageNotification = @"ysReceiveMessageNotification";


static NSNotificationName const ysClassBeginNotification = @"ysCeacherControlClassBegin";

//static  NSString *const sWhiteboardID               = @"whiteboardID";

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
