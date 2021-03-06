//
//  YSAppMacros.h
//  YSLive
//
//  Created by jiang deng on 2019/10/12.
//  Copyright © 2019 FS. All rights reserved.
//

#ifndef YSAppMacros_h
#define YSAppMacros_h

#define YSAPP_NEWERROR              0


#define YSAPP_APPNAME               @"YSLive"
#define YS_SCBUNDLE_NAME            @ "YSResources.bundle"
#define YS_MEETINGBUNDLE_NAME       @ "YSMeetingResources.bundle"

#define YS_BUNDLE_NAME      ([YSLiveManager sharedInstance].room_UseType == CHRoomUseTypeMeeting) ? YS_MEETINGBUNDLE_NAME : YS_SCBUNDLE_NAME
#define YSAPP_Localized     [NSBundle bundleWithPath:[[NSBundle bm_mainResourcePath] stringByAppendingPathComponent:YS_BUNDLE_NAME]]
#define YSLocalized(s)      [YSAPP_Localized localizedStringForKey:s value:@"" table:nil]

#define YSAPPLogin_Localized    [NSBundle bundleWithPath:[[NSBundle bm_mainResourcePath] stringByAppendingPathComponent:YS_SCBUNDLE_NAME]]
/// 登录单独使用
#define YSLoginLocalized(s)      [YSAPPLogin_Localized localizedStringForKey:s value:@"" table:nil]

#define YS_ONLINESCHOOL_NAME       @ "YSOnlineSchool.bundle"

#define YSAPP_LocalizedSchool     [NSBundle bundleWithPath:[[NSBundle bm_mainResourcePath] stringByAppendingPathComponent:YS_ONLINESCHOOL_NAME]]
#define YSLocalizedSchool(s)      [YSAPP_LocalizedSchool localizedStringForKey:s value:@"" table:nil]

//小班课 + 直播 换肤
#define YSSkinDefineColor(s) [[YSLiveSkinManager shareInstance] getCommonColorWithType:CHSkinClassOrOnline_class WithKey:(s)]
#define YSSkinDefineImage(s) [[YSLiveSkinManager shareInstance] getCommonImageWithType:CHSkinClassOrOnline_class WithKey:(s)]

#define YSSkinElementColor(z , s) [[YSLiveSkinManager shareInstance] getElementColorWithType:CHSkinClassOrOnline_class WithName:(z) andKey:(s)]
#define YSSkinElementImage(z , s) [[YSLiveSkinManager shareInstance] getElementImageWithType:CHSkinClassOrOnline_class WithName:(z) andKey:(s)]

//网校 换肤
#define YSSkinOnlineDefineColor(s) [[YSLiveSkinManager shareInstance] getCommonColorWithType:CHSkinClassOrOnline_online WithKey:(s)]
#define YSSkinOnlineDefineImage(s) [[YSLiveSkinManager shareInstance] getCommonImageWithType:CHSkinClassOrOnline_online WithKey:(s)]

#define YSSkinOnlineElementColor(z , s) [[YSLiveSkinManager shareInstance] getElementColorWithType:CHSkinClassOrOnline_online WithName:(z) andKey:(s)]
#define YSSkinOnlineElementImage(z , s) [[YSLiveSkinManager shareInstance] getElementImageWithType:CHSkinClassOrOnline_online WithName:(z) andKey:(s)]


// 苹果AppID
#ifdef YSCUSTOMIZED_WSKJ

#define YS_APPSTORE_DOWNLOADAPP_ADDRESS     @"itms-apps://itunes.apple.com/app/id1463540096"
#define YS_APPID                            @"1463540096"

#else

#define YS_APPSTORE_DOWNLOADAPP_ADDRESS     @"itms-apps://itunes.apple.com/app/id1524580594"
//#define YS_APPID                            @"1489026684"
#define YS_APPID                            @"1524580594"

#endif


// 崩溃日志
//#define CRASH_REPORT_ADDRESS    @"http://global.talk-cloud.com/update/public"
#define CRASH_REPORT_ADDRESS    @"http://crash.roadofcloud.com/update/public/"
#define CRASH_IDENTIFIER        @"bfe4ad0dd2c941c3b3ce0453a0c6aa65"

// 百度翻译
static NSString *const YSAPP_ID_BaiDu = @"20190926000337599";
static NSString *const YSSECURITY_KEY = @"fFFxmgclVTLMt0kogAbH";
static NSString *const YSTRANS_API_HOST = @"http://api.fanyi.baidu.com/api/trans/vip/translate";

// 用户协议
static NSString *const YSUserAgreement = @"YSUserAgreement";
// 隐私条款
static NSString *const YSPrivacyClause = @"PrivacyClause";

#define YSPHONENUMBER_LENGTH            11

#define YSPASSWORD_MINLENGTH            8
#define YSPASSWORD_MAXLENGTH            16

#endif /* YSAppMacros_h */


#define YSGiftMp3SoundId                (CHUISoundId_Start+1)
