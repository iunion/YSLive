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

#define YS_APPSTORE_DOWNLOADAPP_ADDRESS     @"itms-apps://itunes.apple.com/app/id1489026684"
#define YS_APPID                            @"1489026684"

// 崩溃日志
//#define CRASH_REPORT_ADDRESS    @"http://global.talk-cloud.com/update/public"
#define CRASH_REPORT_ADDRESS    @"http://crash.roadofcloud.com/update/public/"
#define CRASH_IDENTIFIER        @"bfe4ad0dd2c941c3b3ce0453a0c6aa65"

// 百度翻译
static NSString *const YSAPP_ID_BaiDu = @"20190926000337599";
static NSString *const YSSECURITY_KEY = @"fFFxmgclVTLMt0kogAbH";
static NSString *const YSTRANS_API_HOST = @"http://api.fanyi.baidu.com/api/trans/vip/translate";

#endif /* YSAppMacros_h */
