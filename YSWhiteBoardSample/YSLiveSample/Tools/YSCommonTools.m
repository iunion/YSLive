//
//  YSCommonTools.m
//  YSLiveSample
//
//  Created by 马迪 on 2020/9/4.
//  Copyright © 2020 yunshuxunlian. All rights reserved.
//

#import "YSCommonTools.h"


static inline NSString *getAssetsName(NSString *assetsName)
{
    if ([assetsName rangeOfString:@".xcassets"].location != NSNotFound)
    {
        return assetsName;
    }
    
    return [assetsName stringByAppendingPathExtension:@"xcassets"];
}

@implementation YSCommonTools




#pragma mark - 判断用户设备是iPhone, iPad 还是iPod touch
+ (BOOL)deviceIsIPad
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        return YES;
    }
    else
    {
        return NO;
    }
    
}


+ (NSDictionary *)dictionary:(NSDictionary*)dict ForKey:(id)key
{
    NSDictionary *value = nil;
    
    id object = [dict objectForKey:key];
    if ([self isValided:object] && [object isKindOfClass:[NSDictionary class]])
    {
        value = (NSDictionary *)object;
    }
    
    return value;
}


+ (NSString *)stringForKey:(id)key byDictionary:(NSDictionary*)dict
{
    NSString *value = nil;
    
    id object = [dict objectForKey:key];
    if ([self isValided:object])
    {
        if ([object isKindOfClass:[NSString class]])
        {
            value = (NSString *)object;
        }
        else if ([object isKindOfClass:[NSNumber class]])
        {
            value = ((NSNumber *)object).stringValue;
        }
        else if ([object isKindOfClass:[NSURL class]])
        {
            value = ((NSURL *)object).absoluteString;
        }
    }
    
    return value;
}

+ (UIColor *)colorWithHexString:(NSString *)stringToConvert
{
    CGFloat alpha = 1.0;
    
    UIColor *color = nil;
    
    NSString *colorString = [[stringToConvert stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // strip 0X if it appears
    //if ([cString hasPrefix:@"0X"] || [cString hasPrefix:@"0x"])
    if ([colorString hasPrefix:@"0X"])
    {
        colorString = [colorString substringFromIndex:2];
    }
    else if ([colorString hasPrefix:@"＃"] || [colorString hasPrefix:@"#"])
    {
        colorString = [colorString substringFromIndex:1];
    }

    if (![self isNotEmpty:colorString])
    {
        return color;
    }
    
    CGFloat red, blue, green;
    NSUInteger length = colorString.length;
    switch (length)
    {
        case 1: // 0
            if ([colorString isEqualToString:@"0"])
            {
                return [UIColor clearColor];
            }
            else
            {
                return color;
            }

        case 3: // #RGB ==> #RRGGBB
            red = [self colorComponentFrom:colorString start:0 length:1];
            green = [self colorComponentFrom:colorString start:1 length:1];
            blue = [self colorComponentFrom:colorString start:2 length:1];
            break;
            
        case 4: // #ARGB ==> #AARRGGBB
            alpha = [self colorComponentFrom:colorString start:0 length:1];
            red = [self colorComponentFrom:colorString start:1 length:1];
            green = [self colorComponentFrom:colorString start:2 length:1];
            blue = [self colorComponentFrom:colorString start:3 length:1];
            break;

        case 6: // #RRGGBB
            red = [self colorComponentFrom:colorString start:0 length:2];
            green = [self colorComponentFrom:colorString start:2 length:2];
            blue = [self colorComponentFrom:colorString start:4 length:2];
            break;
            
        case 8: // #AARRGGBB
            alpha = [self colorComponentFrom:colorString start:0 length:2];
            red = [self colorComponentFrom:colorString start:2 length:2];
            green = [self colorComponentFrom:colorString start:4 length:2];
            blue = [self colorComponentFrom:colorString start:6 length:2];
            break;
            
        default:
            return color;
    }

    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

+ (UIColor *)colorWithHex:(UInt32)hex
{
    CGFloat alpha = 1.0;
    
    return [UIColor colorWithRed:((float)((hex & 0xFF0000) >> 16)) / 255.0
                           green:((float)((hex & 0xFF00) >> 8)) / 255.0
                            blue:((float)(hex & 0xFF)) / 255.0
                           alpha:alpha];
}

+ (UIImage *)imageWithAssetsName:(NSString *)assetsName imageName:(NSString *)imageName fromBundle:(NSBundle*)bundle
{
    NSString *bundlePath = [bundle resourcePath];
    NSString *basePath = [bundlePath stringByAppendingPathComponent:getAssetsName(assetsName)];

    NSString *imageTmpName = [imageName stringByDeletingPathExtension];
    NSString *imagePathName = [imageTmpName stringByAppendingPathExtension:@"imageset"];

    if ([[[UIDevice currentDevice] systemVersion] floatValue] > 10.0)
     {
         NSString *imageFilePath = [[basePath stringByAppendingPathComponent:imagePathName] stringByAppendingPathComponent:imageName];
         return [UIImage imageWithContentsOfFile:imageFilePath];
     }

    NSString *name = [NSString stringWithFormat:@"%@@2x", imageName];
    NSString *imageFilePath = [[basePath stringByAppendingPathComponent:imagePathName] stringByAppendingPathComponent:name];
    UIImage *image = [UIImage imageWithContentsOfFile:imageFilePath];
    if (!image)
    {
        NSString *name = [NSString stringWithFormat:@"%@@3x", imageName];
        NSString *imageFilePath = [[basePath stringByAppendingPathComponent:imagePathName] stringByAppendingPathComponent:name];
        image = [UIImage imageWithContentsOfFile:imageFilePath];
    }
    if (!image)
    {
        NSString *imageFilePath = [[basePath stringByAppendingPathComponent:imagePathName] stringByAppendingPathComponent:imageName];
        image = [UIImage imageWithContentsOfFile:imageFilePath];
    }

    return image;
}


+ (CGFloat)colorComponentFrom:(NSString *)string start:(NSUInteger)start length:(NSUInteger)length
{
    NSString *substring = [string substringWithRange:NSMakeRange(start, length)];
    NSString *fullHex = length == 2 ? substring : [NSString stringWithFormat:@"%@%@", substring, substring];
    unsigned int hexComponent;
    [[NSScanner scannerWithString:fullHex] scanHexInt:&hexComponent];
    return hexComponent / 255.0f;
}

+ (BOOL)isValided:(id)obc
{
    return !(obc == nil || [obc isKindOfClass:[NSNull class]]);
}


+ (BOOL)isNotEmpty:(id)obc
{
    return !(obc == nil
             || [obc isKindOfClass:[NSNull class]]
             || ([obc respondsToSelector:@selector(length)]
                 && [(NSData *)obc length] == 0)
             || ([self respondsToSelector:@selector(count)]
                 && [(NSArray *)obc count] == 0));
}

+ (BOOL)isNotEmptyDictionary:(NSDictionary *)dict
{
    if ([self isNotEmpty:dict])
    {
        if ([dict isKindOfClass:[NSDictionary class]])
        {
            return (dict.allKeys.count > 0);
        }
    }
    
    return NO;
}


@end
