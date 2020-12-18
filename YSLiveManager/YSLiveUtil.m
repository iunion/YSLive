//
//  YSLiveUtil.m
//  YSLive
//
//  Created by jiang deng on 2019/10/19.
//  Copyright © 2019 FS. All rights reserved.
//

#import "YSLiveUtil.h"
//#include <netdb.h>
#include <arpa/inet.h>

#import "YSCoreStatus.h"

@implementation YSLiveUtil

+ (BOOL)checkDataType:(id)data
{
    if (!data)
    {
        return YES;
    }
    if ([data isKindOfClass:[NSNumber class]] || [data isKindOfClass:[NSString class]] || [data isKindOfClass:[NSDictionary class]]  || [data isKindOfClass:[NSArray class]])
    {
        return YES;
    }
    return NO;
}

+ (NSString *)makeApiSignWithData:(NSObject *)data
{
    if (![YSLiveUtil checkDataType:data])
    {
        return @"";
    }
    
    if ([data isKindOfClass:[NSString class]])
    {
        return (NSString *)data;
    }
    else if ([data isKindOfClass:[NSNumber class]])
    {
        NSNumber *number = (NSNumber *)data;
        NSString *string = [NSString stringWithFormat:@"%@", number];
        return string;
    }
    else if ([data isKindOfClass:[NSArray class]])
    {
        NSArray *array = (NSArray *)data;
        NSMutableString *string = [[NSMutableString alloc] initWithString:@""];
        for (NSUInteger i=0; i<array.count; i++)
        {
            [string appendFormat:@"%@%@", @(i), [YSLiveUtil makeApiSignWithData:array[i]]];
        }
        
        return string;
    }
    else if ([data isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *dic = (NSDictionary *)data;
        NSArray *KeyArray = [dic allKeys];
        KeyArray = [KeyArray bm_sortedArray];
        
        NSMutableString *string = [NSMutableString stringWithString:@""];
        for (NSString *key in KeyArray)
        {
            [string appendFormat:@"%@%@", key, [YSLiveUtil makeApiSignWithData:[dic objectForKey:key]]];
        }
        return string;
    }
    
    return @"";
}

/// 发生错误 回调的提示信息
/// @param errorCode 错误码
+ (NSString *)getOccuredErrorCode:(NSInteger)errorCode
{
    return [YSLiveUtil getOccuredErrorCode:errorCode defaultMessage:nil];
}

+ (NSString *)getOccuredErrorCode:(NSInteger)errorCode defaultMessage:(NSString *)message
{
    NSString *alertMessage = message;
    switch (errorCode)
    {
        case CHErrorCode_JoinGroupRoom_RequestFailed:
        { // 900  客户端只能以学生身份进入分组房间
            alertMessage = YSLocalized(@"Error.JoinGroupRoom");
        }
            break;

        case CHErrorCode_CheckRoom_ServerOverdue:
        { // 3001  服务器过期
            alertMessage = YSLocalized(@"Error.ServerExpired");
        }
            break;
        case CHErrorCode_CheckRoom_RoomFreeze:
        { // 3002  公司被冻结
            alertMessage = YSLocalized(@"Error.CompanyFreeze");
        }
            break;
        case CHErrorCode_CheckRoom_RoomDeleteOrOrverdue: // 3003  房间过期或删除
        {
            alertMessage = YSLocalized(@"Error.RoomDeletedOrExpired");
        }
            break;
        case CHErrorCode_CheckRoom_RoomNonExistent:
        { // 4007 房间不存在 房间被删除或者过期
            alertMessage = YSLocalized(@"Error.RoomNonExistent");
        }
            break;
        case CHErrorCode_CheckRoom_RequestFailed:
        {
            alertMessage = YSLocalized(@"Error.WaitingForNetwork");
        }
            break;
        case CHErrorCode_CheckRoom_PasswordError:
        { // 4008  房间密码错误
            alertMessage = YSLocalized(@"Error.PwdError");
        }
            break;
        case CHErrorCode_CheckRoom_WrongPasswordForRole:
        { // 4012  密码与角色不符
            alertMessage = YSLocalized(@"Error.PwdError");
        }
            break;
        case CHErrorCode_CheckRoom_RoomNumberOverRun:
        { // 4103  房间人数超限
            alertMessage = YSLocalized(@"Error.MemberOverRoomLimit");
        }
            break;
        case CHErrorCode_CheckRoom_NeedPassword:
        { // 4110  该房间需要密码，请输入密码
            alertMessage = YSLocalized(@"Error.NeedPwd");
        } break;
            
        case CHErrorCode_CheckRoom_RoomPointOverrun:
        { // 4112  企业点数超限
            alertMessage = YSLocalized(@"Error.pointOverRun");
        }
            break;
        case CHErrorCode_CheckRoom_RoomAuthenError:
        { // 4109  认证错误
            alertMessage = YSLocalized(@"Error.AuthIncorrect");
        }
            break;
            
        default:
        {
#ifdef DEBUG
            if ([message bm_isNotEmpty])
            {
                alertMessage = [NSString stringWithFormat:@"%@(%@)", message, @(errorCode)];
            }
            else
            {
                alertMessage = [NSString stringWithFormat:@"%@(%@)", YSLocalized(@"Error.WaitingForNetwork"), @(errorCode)];
            }
#else
            if ([YSCoreStatus currentNetWorkStatus] == YSCoreNetWorkStatusNone)
            {
                alertMessage = YSLocalized(@"Error.WaitingForNetwork");//@"网络错误，请稍后再试";
            }
            else
            {
                if ([message bm_isNotEmpty])
                {
                    alertMessage = message;
                }
                else
                {
                    alertMessage = YSLocalized(@"Error.CanNotConnectNetworkError");//@"服务器繁忙，请稍后再试";
                }
            }
#endif
        }
            break;
    }
    
    return alertMessage;
}
@end
