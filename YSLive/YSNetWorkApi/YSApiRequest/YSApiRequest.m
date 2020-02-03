//
//  YSApiRequest.m
//  YSLive
//
//  Created by jiang deng on 2019/10/12.
//  Copyright © 2019 FS. All rights reserved.
//

#import "YSApiRequest.h"
#import "YSLocation.h"
#if YSSDK
#else
#import "YSCoreStatus.h"
#endif

#import "YSAppInfo.h"

@implementation YSApiRequest

+ (NSString *)publicErrorMessageWithCode:(NSInteger)code
{
    NSString *errorMessage;
    switch (code)
    {
        case 9999:
            errorMessage = @"服务器内部异常";
            break;
        case 1001:
            errorMessage = @"用户未登录";
            break;
        case 1002:
            errorMessage = @"认证令牌失效";
            break;
        case 1003:
            errorMessage = @"非法参数";
            break;
        case 1004:
            errorMessage = @"权限不足";
            break;
        case 1005:
            errorMessage = @"结果为空";
            break;
        case 1006:
            errorMessage = @"操作数据库失败";
            break;
        case 136001:
            errorMessage = @"您已举报过该内容，系统将尽快处理。";
            break;
        case YSAPI_NET_ERRORCODE:
        {
#if YSSDK
            errorMessage = @"网络错误，请稍后再试";
#else
            if ([YSCoreStatus currentNetWorkStatus] == YSCoreNetWorkStatusNone)
            {
                errorMessage = @"网络错误，请稍后再试";
            }
            else
            {
                errorMessage = @"服务器繁忙，请稍后再试";
            }
#endif
        }
            break;
            
        case YSAPI_DATA_ERRORCODE:
        case YSAPI_JSON_ERRORCODE:
            errorMessage = @"数据错误，请稍后再试";
            break;
            
        default:
            errorMessage = @"其他错误";
            break;
    }
    return errorMessage;
}

+ (AFHTTPSessionManager *)makeYSHTTPSessionManager
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    // 增加application/octet-stream，text/html
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"application/octet-stream", @"text/html", @"audio/mpeg", @"audio/mp3", @"text/plain", nil];
    
    return manager;
}

// deviceId     设备号
// deviceModel  设备型号
// osVersion    系统版本号
// cType        设备系统类型
// appVersion   app版本

// JWTToken
// timer        当前时间戳
+ (AFHTTPRequestSerializer *)requestSerializer
{
    static AFHTTPRequestSerializer *YSRequestSerializer;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        YSRequestSerializer = [AFHTTPRequestSerializer serializer];
        YSRequestSerializer.timeoutInterval = YSAPI_TIMEOUT_SECONDS;
        
        // 设备号
//        [YSRequestSerializer setValue:[YSAppInfo getOpenUDID] forHTTPHeaderField:@"deviceId"];
//        // 设备型号
//        [YSRequestSerializer setValue:[UIDevice bm_devicePlatformString] forHTTPHeaderField:@"deviceModel"];
//        // 设备系统类型
//        [YSRequestSerializer setValue:@"IOS" forHTTPHeaderField:@"cType"];
//        // 系统版本号
//        [YSRequestSerializer setValue:CURRENT_SYSTEMVERSION forHTTPHeaderField:@"osVersion"];
//        // app名称
//        [YSRequestSerializer setValue:YSAPP_APPNAME forHTTPHeaderField:@"appName"];
//        // app版本
//        [YSRequestSerializer setValue:APP_VERSIONNO forHTTPHeaderField:@"appVersion"];
//        // 渠道 "App Store"
//        [YSRequestSerializer setValue:[YSAppInfo catchChannelName] forHTTPHeaderField:@"channelCode"];
    });
    
    return YSRequestSerializer;
}

+ (void)logUrlPramaWithURL:(NSString *)URLString parameters:(NSDictionary *)parameters
{
    __block NSString *queryString = nil;
    [parameters enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop) {
        NSString *escapedKey = key;//[key stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
        NSString *escapedValue = value;//[value stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        if (!queryString)
        {
            queryString = [NSString stringWithFormat:@"%@=%@", escapedKey, escapedValue];
        }
        else
        {
            queryString = [queryString stringByAppendingFormat:@"&%@=%@", escapedKey, escapedValue];
        }
    }];
    
    BMLog(@"%@", [NSString stringWithFormat:[URLString rangeOfString:@"?"].location == NSNotFound ? @"%@?%@" : @"%@&%@", URLString, queryString]);
}

+ (NSMutableURLRequest *)makeRequestWithURL:(NSString *)URLString parameters:(NSDictionary *)parameters
{
    return [YSApiRequest makeRequestWithURL:URLString parameters:parameters isPost:YES];
}

+ (NSMutableURLRequest *)makeRequestWithURL:(NSString *)URLString parameters:(NSDictionary *)parameters isPost:(BOOL)isPost
{
    AFHTTPRequestSerializer *requestSerializer = [YSApiRequest requestSerializer];
    
    NSMutableDictionary *parameterDic;
    if ([parameters bm_isNotEmptyDictionary])
    {
        parameterDic = [[NSMutableDictionary alloc] initWithDictionary:parameters];
    }
    else
    {
        parameterDic = [[NSMutableDictionary alloc] init];
    }
    
#ifdef DEBUG
    [YSApiRequest logUrlPramaWithURL:URLString parameters:parameterDic];
#endif
    
    NSString *method = isPost ? @"POST" : @"GET";
    NSError *serializationError = nil;
    NSMutableURLRequest *request = [requestSerializer requestWithMethod:method URLString:URLString parameters:parameterDic error:&serializationError];
    if (serializationError)
    {
        return nil;
    }
    
    // 时间戳
//    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
//    NSString *tmp = [NSString stringWithFormat:@"%@", @(time)];
//    [request setValue:tmp forHTTPHeaderField:@"timer"];
//    
//    // GPS定位
//    [request setValue:[NSString stringWithFormat:@"%f", [YSLocation userLocationLongitude]] forHTTPHeaderField:YSAPI_GPS_LONGITUDE_KEY];
//    [request setValue:[NSString stringWithFormat:@"%f", [YSLocation userLocationLatitude]] forHTTPHeaderField:YSAPI_GPS_LATITUDE_KEY];
//    
//    // 网络状态
//    [request setValue:[YSCoreStatus currentFSNetWorkStatusString] forHTTPHeaderField:@"netWorkStandard"];
    
    // token
//    if ([FSUserInfoModel isLogin])
//    {
//        NSString *token = [FSUserInfoModel userInfo].m_Token;
//        if ([token bm_isNotEmpty])
//        {
//            [request setValue:token forHTTPHeaderField:@"JWTToken"];
//        }
//    }
    
    BMLog(@"HeaderFields: %@", [request allHTTPHeaderFields]);
    
    return request;
}

@end
