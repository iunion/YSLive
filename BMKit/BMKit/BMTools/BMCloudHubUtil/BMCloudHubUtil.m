//
//  BMCloudHubUtil.m
//  BMKit
//
//  Created by jiang deng on 2020/9/9.
//  Copyright © 2020 DennisDeng. All rights reserved.
//

#import "BMCloudHubUtil.h"
#import <arpa/inet.h>
#import <sys/utsname.h>

@implementation BMCloudHubUtil

/// 检测设备授权
+ (BOOL)checkAuthorizationStatus:(AVMediaType)mediaType
{
    AVAuthorizationStatus authorStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if (authorStatus == AVAuthorizationStatusRestricted ||
        authorStatus == AVAuthorizationStatusDenied)
    {
        return NO;
    }
    
    return YES;
}

+ (NSString *)getCurrentLanguage
{
    NSArray *language = [NSLocale preferredLanguages];
    if ([language objectAtIndex:0]) {
        NSString *currentLanguage = [language objectAtIndex:0];
        if ([currentLanguage length] >= 7 &&
            [[currentLanguage substringToIndex:7] isEqualToString:@"zh-Hans"])
        {
            return @"ch";
        }

        if ([currentLanguage length] >= 7 &&
            [[currentLanguage substringToIndex:7] isEqualToString:@"zh-Hant"])
        {
            return @"tw";
        }

        if ([currentLanguage length] >= 3 &&
            [[currentLanguage substringToIndex:3] isEqualToString:@"en-"])
        {
            return @"en";
        }
    }

    return @"en";
}

+ (BOOL)isDomain:(NSString *)host
{
    const char *hostN= [host UTF8String];
    in_addr_t rt = inet_addr(hostN);
    if (rt == INADDR_NONE)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

/// 检查数据类型
+ (BOOL)checkDataClass:(id)data
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

+ (NSString *)stringFromJSONString:(NSString *)JSONString
{
    NSMutableString *mutableJSONString = [NSMutableString stringWithString:JSONString];
    NSString *character = nil;
    for (int i = 0; i < mutableJSONString.length; i ++)
    {
        character = [mutableJSONString substringWithRange:NSMakeRange(i, 1)];
        if ([character isEqualToString:@"\\"])
        {
            [mutableJSONString deleteCharactersInRange:NSMakeRange(i, 1)];
        }
    }
    
    return mutableJSONString;
}

#if 1
+ (NSDictionary *)convertWithData:(id)data
{
    if (!data)
    {
        return nil;
    }
    
    NSDictionary *dataDic = nil;
    if ([data isKindOfClass:[NSString class]])
    {
        NSString *tDataString = [NSString stringWithFormat:@"%@", data];
        NSData *tJsData = [tDataString dataUsingEncoding:NSUTF8StringEncoding];
        if (tJsData)
        {
            dataDic = [NSJSONSerialization JSONObjectWithData:tJsData
                                                      options:NSJSONReadingMutableContainers
                                                        error:nil];
        }
    }
    else if ([data isKindOfClass:[NSDictionary class]])
    {
        dataDic = (NSDictionary *)data;
    }
    else if ([data isKindOfClass:[NSData class]])
    {
        NSString *dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        dataDic = [BMCloudHubUtil convertWithData:dataStr];
    }
    
    return dataDic;
}
#else
/// 将数据转换成字典类型NSDictionary
+ (NSDictionary *)convertWithData:(id)data
{
    if (!data)
    {
        return nil;
    }
    
    NSDictionary *dataDic = nil;
    if ([data isKindOfClass:[NSString class]])
    {
        NSString *tDataString = [NSString stringWithFormat:@"%@", data];
        tDataString = [tDataString stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""];
        //tDataString = [tDataString stringByReplacingOccurrencesOfString:@"\\\\/" withString:@"/"];
        //tDataString = [tDataString stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
        //tDataString = [YSSessionUtil stringFromJSONString:tDataString];
        tDataString = [tDataString stringByReplacingOccurrencesOfString:@"\"{" withString:@"{"];
        tDataString = [tDataString stringByReplacingOccurrencesOfString:@"}\"" withString:@"}"];
        NSData *tJsData = [tDataString dataUsingEncoding:NSUTF8StringEncoding];
        if (tJsData)
        {
            dataDic = [NSJSONSerialization JSONObjectWithData:tJsData
                                                      options:NSJSONReadingMutableContainers
                                                        error:nil];
        }
    }
    else if ([data isKindOfClass:[NSDictionary class]])
    {
        dataDic = (NSDictionary *)data;
    }
    else if ([data isKindOfClass:[NSData class]])
    {
        NSString *dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        dataDic = [BMCloudHubUtil convertWithData:dataStr];
    }
    
    return dataDic;
}
#endif

/// 将数据转换成NSData
+ (nullable NSData *)convertWithObject:(nullable id)obj
{
    if (!obj)
    {
        return nil;
    }
    
    NSData *data = nil;
    if ([obj isKindOfClass:[NSString class]])
    {
        NSString *tDataString = [NSString stringWithFormat:@"%@", obj];
        tDataString = [tDataString stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""];
        //tDataString = [tDataString stringByReplacingOccurrencesOfString:@"\\\\/" withString:@"/"];
        //tDataString = [tDataString stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
        //tDataString = [YSSessionUtil stringFromJSONString:tDataString];
        tDataString = [tDataString stringByReplacingOccurrencesOfString:@"\"{" withString:@"{"];
        tDataString = [tDataString stringByReplacingOccurrencesOfString:@"}\"" withString:@"}"];
        data = [tDataString dataUsingEncoding:NSUTF8StringEncoding];
    }
    else if ([obj isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *tDataDic = (NSDictionary *)obj;
        NSString *dataStr = [tDataDic bm_toJSON];
        data = [BMCloudHubUtil convertWithObject:dataStr];
    }
    else if ([obj isKindOfClass:[NSNumber class]])
    {
        NSNumber *num = (NSNumber *)obj;
        NSString *tDataString = num.stringValue;
        data = [BMCloudHubUtil convertWithObject:tDataString];
    }
    else if ([obj isKindOfClass:[NSData class]])
    {
        data = (NSData *)obj;
    }
    
    return data;
}

/// 文件扩展名检查，是否是媒体文件
+ (BOOL)checkIsMedia:(NSString *)filetype;
{
    if ([filetype isEqualToString:@"mp3"]
        || [filetype isEqualToString:@"mp4"]
        || [filetype isEqualToString:@"webm"]
        || [filetype isEqualToString:@"ogg"]
        || [filetype isEqualToString:@"wav"])
    {
        return YES;
    }
    
    return NO;
}

/// 文件扩展名检查，是否是视频文件
+ (BOOL)checkIsVideo:(NSString *)filetype;
{
    if ([filetype isEqualToString:@"mp4"] || [filetype isEqualToString:@"webm"])
    {
        return YES;
    }
    
    return NO;
}

/// 文件扩展名检查，是否是音频文件
+ (BOOL)checkIsAudio:(NSString *)filetype;
{
    if ([filetype isEqualToString:@"mp3"] || [filetype isEqualToString:@"ogg"] || [filetype isEqualToString:@"wav"])
    {
        return YES;
    }
    
    return NO;
}

+ (BOOL)deviceIsConform
{
    // 获得设备类型 iPad4,4
    NSString *devicePlatform = [UIDevice bm_devicePlatform];
    NSArray *paragramArray = [devicePlatform componentsSeparatedByString:@","];
    if (paragramArray.count < 2)
    {
        return NO;
    }
    
    NSString *versionString = paragramArray[0]; //ipad 4
    NSString *typeStr = paragramArray[1];//4
    NSInteger type = [typeStr integerValue];

    NSArray *iPhoneArray = [versionString componentsSeparatedByString:@"iPhone"];
    NSArray *iPadArray = [versionString componentsSeparatedByString:@"iPad"];
    versionString = @"";
    if (iPhoneArray.count == 2)
    {
        versionString = iPhoneArray[1];
        NSInteger version = [versionString integerValue];
        if (version > 6)
        {
            return YES;
        }
    }
    else if (iPadArray.count == 2)
    {
        versionString = iPadArray[1];
        NSInteger version = [versionString integerValue];
        if (version > 4)
        {
            return YES;
        }
        else if (version == 4)
        {
            if (type > 6)
            {
                return YES;
            }
        }
    }

    return NO;
}

+ (NSString *)createUUID
{
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    CFStringRef cfstring = CFUUIDCreateString(kCFAllocatorDefault, uuid);
    const char *cStr = CFStringGetCStringPtr(cfstring,CFStringGetFastestEncoding(cfstring));
    unsigned char result[16];
    CC_MD5( cStr, (CC_LONG)strlen(cStr), result );
    CFRelease(uuid);
    CFRelease(cfstring);
   
    NSString *openUDID = [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%08lx",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15],
                 (unsigned long)(arc4random() % NSUIntegerMax)];
    
    return openUDID;
}

+ (NSString *)changeUrl:(NSURL *)url withProtocol:(NSString *)protocol host:(NSString *)host
{
    NSString *new;
    
    if (![protocol bm_isNotEmpty])
    {
        protocol = url.scheme;
    }
    
    NSString *path = url.path;
    if ([path bm_isNotEmpty])
    {
        new = [NSString stringWithFormat:@"%@://%@/%@", protocol, host, path];
    }
    else
    {
        new = [NSString stringWithFormat:@"%@://%@", protocol, host];
    }
    
    return new;
}

@end
