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

@implementation YSLiveUtil

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
        dataDic = [YSLiveUtil convertWithData:dataStr];
    }
    
    return dataDic;
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

+ (BOOL)checkIsMedia:(NSString *)filetype
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

+ (BOOL)checkIsVideo:(NSString *)filetype
{
    if ([filetype isEqualToString:@"mp4"] || [filetype isEqualToString:@"webm"])
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

@end
