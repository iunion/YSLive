//
//  YSAPIMacros.h
//  YSLive
//
//  Created by jiang deng on 2019/10/12.
//  Copyright © 2019 FS. All rights reserved.
//

#ifndef YSAPIMacros_h
#define YSAPIMacros_h

#if USE_TEST_HELP

// 开发环境
#define YS_URL_SERVER_DEV       (@"https://devftls.odrcloud.net")
#define YS_H5_SERVER_DEV        (@"https://devftlsh5.odrcloud.net")

// 测试环境
#define YS_URL_SERVER_TEST      (@"https://testftls.odrcloud.cn")
#define YS_H5_SERVER_TEST       (@"https://testftlsh5.odrcloud.cn")

// 线上环境
#define YS_URL_SERVER_ONLINE    (@"https://ftlsh5.odrcloud.cn")
#define YS_H5_SERVER_ONLINE     (@"https://ftlsh5.odrcloud.cn")

#define YS_URL_SERVER_INIT      YS_URL_SERVER_DEV
#define YS_H5_SERVER_INIT       YS_H5_SERVER_DEV

#define YS_URL_SERVER_KEY       (@"debug_api_server")
#define YS_URL_SERVER           [[NSUserDefaults standardUserDefaults] objectForKey:YS_URL_SERVER_KEY]

#define YS_H5_SERVER_KEY        (@"debug_h5_server")
#define YS_H5_SERVER            [[NSUserDefaults standardUserDefaults] objectForKey:YS_H5_SERVER_KEY]

#else

#define YS_URL_SERVER           (@"https://ftlsh5.odrcloud.cn")
#define YS_H5_SERVER            (@"https://ftlsh5.odrcloud.cn")

#endif


// 一般API超时时间
#define YSAPI_TIMEOUT_SECONDS               (30.0f)
// 数据上传超时时间
#define YSAPI_UPLOADIMAGE_TIMEOUT_SECONDS   (60.0f)
// 重试一次，即调用二次
#define YSAPI_TIMEOUT_RETRY_COUNT           (0)

// gps
#define YSAPI_GPS_LATITUDE_KEY              (@"latitude")
#define YSAPI_GPS_LONGITUDE_KEY             (@"longitude")

// errorCode
#define YSAPI_NET_ERRORCODE                 -100
#define YSAPI_DATA_ERRORCODE                -101
#define YSAPI_JSON_ERRORCODE                -102

// 每次加载数据的方式 按页取/按个数取, 默认: YSAPILoadDataType_Count
typedef NS_ENUM(NSUInteger, YSAPILoadDataType)
{
    YSAPILoadDataType_Count,
    YSAPILoadDataType_Page = 1,
};





#endif /* YSAPIMacros_h */
