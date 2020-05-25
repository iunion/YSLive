//
//  YSAppMacros.h
//  YSLive
//
//  Created by jiang deng on 2019/10/12.
//  Copyright © 2019 FS. All rights reserved.
//

#ifndef YSAppMacros_h
#define YSAppMacros_h

#define YSAPP_APPNAME               @"YSLive"
#define YS_SCBUNDLE_NAME            @ "YSResources.bundle"
#define YS_MEETINGBUNDLE_NAME       @ "YSMeetingResources.bundle"

#define YS_BUNDLE_NAME      ([YSLiveManager shareInstance].room_UseTheType == YSAppUseTheTypeMeeting) ? YS_MEETINGBUNDLE_NAME : YS_SCBUNDLE_NAME
#define YSAPP_Localized     [NSBundle bundleWithPath:[[NSBundle bm_mainResourcePath] stringByAppendingPathComponent:YS_BUNDLE_NAME]]
#define YSLocalized(s)      [YSAPP_Localized localizedStringForKey:s value:@"" table:nil]

#define YSAPPLogin_Localized    [NSBundle bundleWithPath:[[NSBundle bm_mainResourcePath] stringByAppendingPathComponent:YS_SCBUNDLE_NAME]]
/// 登录单独使用
#define YSLoginLocalized(s)      [YSAPPLogin_Localized localizedStringForKey:s value:@"" table:nil]

#define YS_ONLINESCHOOL_NAME       @ "YSOnlineSchool.bundle"

#define YSAPP_LocalizedSchool     [NSBundle bundleWithPath:[[NSBundle bm_mainResourcePath] stringByAppendingPathComponent:YS_ONLINESCHOOL_NAME]]
#define YSLocalizedSchool(s)      [YSAPP_LocalizedSchool localizedStringForKey:s value:@"" table:nil]

//换肤
#define YSSkinDefineColor(s) [[YSSkinManager shareInstance] getDefaultColorWithKey:(s)]

#define YSSkinElement(z , s) [[YSSkinManager shareInstance] getElementColorOrImageWithName:(z) andKey:(s)]

#define YSSkinDefineImage(s) [[YSSkinManager shareInstance] getDefaultImageWithKey:(s)]

// 苹果AppID
#if YSCUSTOMIZED_WSKJ

#define YS_APPSTORE_DOWNLOADAPP_ADDRESS     @"itms-apps://itunes.apple.com/app/id1463540096"
#define YS_APPID                            @"1463540096"

#else

#define YS_APPSTORE_DOWNLOADAPP_ADDRESS     @"itms-apps://itunes.apple.com/app/id1489026684"
#define YS_APPID                            @"1489026684"

#endif


// 崩溃日志
//#define CRASH_REPORT_ADDRESS    @"http://global.talk-cloud.com/update/public"
#define CRASH_REPORT_ADDRESS    @"http://crash.roadofcloud.com/update/public/"
#define CRASH_IDENTIFIER        @"bfe4ad0dd2c941c3b3ce0453a0c6aa65"

// 百度翻译
static NSString *const YSAPP_ID_BaiDu = @"20190926000337599";
static NSString *const YSSECURITY_KEY = @"fFFxmgclVTLMt0kogAbH";
static NSString *const YSTRANS_API_HOST = @"http://api.fanyi.baidu.com/api/trans/vip/translate";


#define YSPHONENUMBER_LENGTH            11

#define YSPASSWORD_MINLENGTH            8
#define YSPASSWORD_MAXLENGTH            16

#define LEAKS_ENABLED                   0
#endif /* YSAppMacros_h */
