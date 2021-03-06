//
//  UIColor+BMCategory.m
//  BMBasekit
//
//  Created by DennisDeng on 12-1-11.
//  Copyright (c) 2012年 DennisDeng. All rights reserved.
//

/*
 Current outstanding request list:
 - PolarBearFarm - color descriptions ([UIColor warmGrayWithHintOfBlueTouchOfRedAndSplashOfYellowColor])
 - Eridius - UIColor needs a method that takes 2 colors and gives a third complementary one
 - Consider UIMutableColor that can be adjusted (brighter, cooler, warmer, thicker-alpha, etc)
 */

/*
 FOR REFERENCE: Color Space Models: enum CGColorSpaceModel {
 kCGColorSpaceModelUnknown = -1,
 kCGColorSpaceModelMonochrome,
 kCGColorSpaceModelRGB,
 kCGColorSpaceModelCMYK,
 kCGColorSpaceModelLab,
 kCGColorSpaceModelDeviceN,
 kCGColorSpaceModelIndexed,
 kCGColorSpaceModelPattern
 };
 */

#import "UIColor+BMCategory.h"

#define DEFAULT_VOID_COLOR [UIColor whiteColor]

@implementation UIColor (BMHex)

+ (UIColor *)bm_colorWithHexString:(NSString *)stringToConvert
{
    return [UIColor bm_colorWithHexString:stringToConvert alpha:1.0f];
}

+ (UIColor *)bm_colorWithHexString:(NSString *)stringToConvert alpha:(CGFloat)alpha
{
    return [UIColor bm_colorWithHexString:stringToConvert alpha:alpha default:DEFAULT_VOID_COLOR];
}

+ (UIColor *)bm_colorWithHexString:(NSString *)stringToConvert default:(UIColor *)color
{
    return [UIColor bm_colorWithHexString:stringToConvert alpha:1.0f default:color];
}

+ (CGFloat)bm_colorComponentFrom:(NSString *)string start:(NSUInteger)start length:(NSUInteger)length
{
    NSString *substring = [string substringWithRange:NSMakeRange(start, length)];
    NSString *fullHex = length == 2 ? substring : [NSString stringWithFormat:@"%@%@", substring, substring];
    unsigned int hexComponent;
    [[NSScanner scannerWithString:fullHex] scanHexInt:&hexComponent];
    return hexComponent / 255.0f;
}

+ (UIColor *)bm_colorWithHexString:(NSString *)stringToConvert alpha:(CGFloat)alpha default:(UIColor *)color
{
//    NSString *cString = [[stringToConvert stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
//
//    // String should be 6 or 8 characters
//    if ([cString length] < 3)
//    {
//        return color;
//    }
//
//    unsigned rgbValue = 0;
//    NSScanner *scanner = [NSScanner scannerWithString:cString];
//    
//    if ([cString hasPrefix:@"#"] || [cString hasPrefix:@"＃"])// bypass '#' character
//    {
//        [scanner setScanLocation:1];
//    }
//    else if ([cString hasPrefix:@"0X"])
//    {
//        [scanner setScanLocation:2];
//    }
//    [scanner scanHexInt:&rgbValue];
//    
//    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
    
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

    if (![colorString bm_isNotEmpty])
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
            red = [UIColor bm_colorComponentFrom:colorString start:0 length:1];
            green = [UIColor bm_colorComponentFrom:colorString start:1 length:1];
            blue = [UIColor bm_colorComponentFrom:colorString start:2 length:1];
            break;
            
        case 4: // #ARGB ==> #AARRGGBB
            alpha = [UIColor bm_colorComponentFrom:colorString start:0 length:1];
            red = [UIColor bm_colorComponentFrom:colorString start:1 length:1];
            green = [UIColor bm_colorComponentFrom:colorString start:2 length:1];
            blue = [UIColor bm_colorComponentFrom:colorString start:3 length:1];
            break;

        case 6: // #RRGGBB
            red = [UIColor bm_colorComponentFrom:colorString start:0 length:2];
            green = [UIColor bm_colorComponentFrom:colorString start:2 length:2];
            blue = [UIColor bm_colorComponentFrom:colorString start:4 length:2];
            break;
            
        case 8: // #AARRGGBB
            alpha = [UIColor bm_colorComponentFrom:colorString start:0 length:2];
            red = [UIColor bm_colorComponentFrom:colorString start:2 length:2];
            green = [UIColor bm_colorComponentFrom:colorString start:4 length:2];
            blue = [UIColor bm_colorComponentFrom:colorString start:6 length:2];
            break;
            
        default:
            return color;
    }

    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

/// 格式支持 #RRGGBBAA
+ (nullable UIColor *)bm_colorWithRGBAHexString:(NSString *)stringToConvert
{
    return [UIColor bm_colorWithRGBAHexString:stringToConvert alpha:1.0f];
}

+ (nullable UIColor *)bm_colorWithRGBAHexString:(NSString *)stringToConvert alpha:(CGFloat)alpha
{
    return [UIColor bm_colorWithRGBAHexString:stringToConvert alpha:(CGFloat)alpha default:DEFAULT_VOID_COLOR];
}

+ (nullable UIColor *)bm_colorWithRGBAHexString:(NSString *)stringToConvert alpha:(CGFloat)alpha default:(nullable UIColor *)color
{
    NSString *colorString = [[stringToConvert stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    if ([colorString hasPrefix:@"RGBA("])
    {
        colorString = [colorString substringFromIndex:5];
        colorString = [colorString stringByReplacingOccurrencesOfString:@")" withString:@""];
        NSArray *rgbaArray = [colorString componentsSeparatedByString:@","];
        if (rgbaArray.count == 3)
        {
            NSNumber *r = rgbaArray[0];
            NSNumber *g = rgbaArray[1];
            NSNumber *b = rgbaArray[2];
            UIColor *rgbColor = [UIColor colorWithRed:r.integerValue/255.0f
                                                green:g.integerValue/255.0f
                                                 blue:b.integerValue/255.0f
                                                alpha:alpha];
            return rgbColor;
        }
        else if (rgbaArray.count == 4)
        {
            NSNumber *r = rgbaArray[0];
            NSNumber *g = rgbaArray[1];
            NSNumber *b = rgbaArray[2];
            NSNumber *a = rgbaArray[3];
            alpha = a.floatValue;
            if (alpha > 1.0f)
            {
                alpha = 1.0f;
            }
            UIColor *rgbColor = [UIColor colorWithRed:r.integerValue/255.0f
                                                green:g.integerValue/255.0f
                                                 blue:b.integerValue/255.0f
                                                alpha:alpha];
            return rgbColor;
        }
        return color;
    }

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

    if (![colorString bm_isNotEmpty])
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
            red = [UIColor bm_colorComponentFrom:colorString start:0 length:1];
            green = [UIColor bm_colorComponentFrom:colorString start:1 length:1];
            blue = [UIColor bm_colorComponentFrom:colorString start:2 length:1];
            break;
            
        case 4: // #RGBA ==> #RRGGBBAA
            red = [UIColor bm_colorComponentFrom:colorString start:0 length:1];
            green = [UIColor bm_colorComponentFrom:colorString start:1 length:1];
            blue = [UIColor bm_colorComponentFrom:colorString start:2 length:1];
            alpha = [UIColor bm_colorComponentFrom:colorString start:3 length:1];
            break;

        case 6: // #RRGGBB
            red = [UIColor bm_colorComponentFrom:colorString start:0 length:2];
            green = [UIColor bm_colorComponentFrom:colorString start:2 length:2];
            blue = [UIColor bm_colorComponentFrom:colorString start:4 length:2];
            break;
            
        case 8: // #RRGGBBAA
            red = [UIColor bm_colorComponentFrom:colorString start:0 length:2];
            green = [UIColor bm_colorComponentFrom:colorString start:2 length:2];
            blue = [UIColor bm_colorComponentFrom:colorString start:4 length:2];
            alpha = [UIColor bm_colorComponentFrom:colorString start:6 length:2];
            break;
            
        default:
            return color;
    }

    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

// _hexUIColorRegex = [NSRegularExpression regularExpressionWithPattern:@"\\[\\s*UIColor\\s+(colorWithHex:\\s*(0[xX][0-9a-fA-F]{1,6})(\\s+alpha:\\s*([0-9]*.?[0-9]{1,})f?)?)\\s*\\]" options:0 error:NULL];
// NSString *hex = [text substringWithRange:[result rangeAtIndex:2]];
// index即是()小括号位置
// alpha = [[text substringWithRange:[result rangeAtIndex:4]] doubleValue];

+ (UIColor *)bm_colorWithHex:(UInt32)hex
{
	return [UIColor bm_colorWithHex:hex alpha:1.0f];
}

+ (UIColor *)bm_colorWithHex:(UInt32)hex alpha:(CGFloat)alpha
{
	return [UIColor colorWithRed:((float)((hex & 0xFF0000) >> 16)) / 255.0
                           green:((float)((hex & 0xFF00) >> 8)) / 255.0
                            blue:((float)(hex & 0xFF)) / 255.0
                           alpha:alpha];
}

+ (NSString *)bm_hexStringFromColor:(UIColor *)color
{
    return [UIColor bm_hexStringFromColor:color withStartChar:@"" haveAlpha:NO];
}

+ (NSString *)bm_hexStringFromColor:(UIColor *)color withStartChar:(NSString *)startChar haveAlpha:(BOOL)haveAlpha
{
    if (![startChar bm_isNotEmpty])
    {
        startChar = @"";
    }
    
    if (haveAlpha)
    {
        return [NSString stringWithFormat:@"%@%0.8X", startChar, (unsigned int)color.bm_argbHex];
    }
    else
    {
        return [NSString stringWithFormat:@"%@%0.6X", startChar, (unsigned int)color.bm_rgbHex];
    }
}

- (NSString *)bm_hexString
{
    return [self bm_hexStringWithStartChar:@"" haveAlpha:NO];
}

- (NSString *)bm_hexStringWithStartChar:(NSString *)startChar
{
    return [self bm_hexStringWithStartChar:startChar haveAlpha:NO];
}

- (NSString *)bm_hexStringWithStartChar:(NSString *)startChar haveAlpha:(BOOL)haveAlpha
{
    return [UIColor bm_hexStringFromColor:self withStartChar:startChar haveAlpha:haveAlpha];
}

- (NSString *)bm_RBGAHexStringWithStartChar:(NSString *)startChar haveAlpha:(BOOL)haveAlpha
{
    return [self bm_RBGAHexStringWithStartChar:startChar haveAlpha:haveAlpha isRGBA:NO];
}

- (NSString *)bm_RBGAHexStringWithStartChar:(NSString *)startChar haveAlpha:(BOOL)haveAlpha isRGBA:(BOOL)isRGBA
{
    if (![startChar bm_isNotEmpty])
    {
        startChar = @"";
    }
    
    if (isRGBA)
    {
        if (haveAlpha)
        {
            return [NSString stringWithFormat:@"rgba(%@,%@,%@,%@)", @((NSUInteger)(self.bm_red*255)), @((NSUInteger)(self.bm_green*255)), @((NSUInteger)(self.bm_blue*255)), @(self.bm_alpha)];
        }
        else
        {
            return [NSString stringWithFormat:@"rgba(%@,%@,%@)", @((NSUInteger)(self.bm_red*255)), @((NSUInteger)(self.bm_green*255)), @((NSUInteger)(self.bm_blue*255))];
        }
    }
    else
    {
        if (haveAlpha)
        {
            return [NSString stringWithFormat:@"%@%0.8X", startChar, (unsigned int)self.bm_rgbaHex];
        }
        else
        {
            return [NSString stringWithFormat:@"%@%0.6X", startChar, (unsigned int)self.bm_rgbHex];
        }
    }
}

+ (UIColor *)bm_randomColor
{
    return [UIColor bm_randomColorWithAlpha:1.0f];
}

+ (UIColor *)bm_randomColorWithAlpha:(CGFloat)alpha
{
	int r = arc4random() % 255;
	int g = arc4random() % 255;
	int b = arc4random() % 255;
	return [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:alpha];
}

+ (UIColor *)bm_startColor:(UIColor *)startColor endColor:(UIColor *)endColor progress:(CGFloat)progress
{
    return [UIColor bm_startColorHex:startColor.bm_rgbHex endColorHex:endColor.bm_rgbHex startAlpha:startColor.bm_alpha endAlpha:endColor.bm_alpha progress:progress];
}

+ (UIColor *)bm_startColorHex:(UInt32)startColor endColorHex:(UInt32)endColor progress:(CGFloat)progress
{
    return [UIColor bm_startColorHex:startColor endColorHex:endColor startAlpha:1.0 endAlpha:1.0 progress:progress];
}

+ (UIColor *)bm_startColorHex:(UInt32)startColor endColorHex:(UInt32)endColor startAlpha:(CGFloat)startAlpha endAlpha:(CGFloat)endAlpha progress:(CGFloat)progress
{
    UInt32 oHex = startColor;
    unsigned char oR = (oHex & 0xFF0000) >> 16;
    unsigned char oG = (oHex & 0xFF00) >> 8;
    unsigned char oB = oHex & 0xFF;
    //BMLog(@"HMMainVC_NavBgColorValue  %lX%lX%lX============", oR, oG, oB);
    
    UInt32 eHex = endColor;
    unsigned char eR = (eHex & 0xFF0000) >> 16;
    unsigned char eG = (eHex & 0xFF00) >> 8;
    unsigned char eB = eHex & 0xFF;
    //BMLog(@"UI_NAVIGATION_BGCOLOR_VALUE  %lX%lX%lX============", eR, eG, eB);
    
    BOOL isAddR = eR > oR;
    BOOL isAddG = eG > oG;
    BOOL isAddB = eB > oB;
    
    unsigned char delaR = isAddR ? (eR - oR)*progress :  (oR - eR)*progress;
    unsigned char delaG = isAddG ? (eG - oG)*progress :  (oG - eG)*progress;
    unsigned char delaB = isAddB ? (eB - oB)*progress :  (oB - eB)*progress;
    
    unsigned char R = isAddR ? oR + delaR : oR - delaR;
    unsigned char G = isAddG ? oG + delaG : oG - delaG;
    unsigned char B = isAddB ? oB + delaB : oB - delaB;
    
    // color RGB hex
    UInt32 s = (UInt32)((R << 16) + (G << 8) + B);
    
    // color alpha
    CGFloat dAlpha = endAlpha - startAlpha;
    CGFloat alpha = startAlpha + (dAlpha * progress);
    
    //BMLog(@"BGCOLOR_%0.2f %02hhX%02hhX%02hhX==", scale, R, G, B);
    return [UIColor bm_colorWithHex:(UInt32)s alpha:alpha];
}

- (nullable UIColor *)bm_blendWithColor:(UIColor *)color progress:(CGFloat)progress
{
    CGFloat fromRed = 0;
    CGFloat fromGreen = 0;
    CGFloat fromBlue = 0;
    CGFloat fromAlpha = 0;
    [self getRed:&fromRed green:&fromGreen blue:&fromBlue alpha:&fromAlpha];
    
    CGFloat toRed = 0;
    CGFloat toGreen = 0;
    CGFloat toBlue = 0;
    CGFloat toAlpha = 0;
    [color getRed:&toRed green:&toGreen blue:&toBlue alpha:&toAlpha];
    
    CGFloat newRed = fromRed + (toRed - fromRed) * progress;
    CGFloat newGreen = fromGreen + (toGreen - fromGreen) * progress;
    CGFloat newBlue = fromBlue + (toBlue - fromBlue) * progress;
    CGFloat newAlpha = fromAlpha + (toAlpha - fromAlpha) * progress;
    return [UIColor colorWithRed:newRed green:newGreen blue:newBlue alpha:newAlpha];
}

@end


@implementation UIColor (BMExpanded)

- (CGColorSpaceModel)bm_colorSpaceModel
{
    return CGColorSpaceGetModel(CGColorGetColorSpace(self.CGColor));
}

- (NSString *)bm_colorSpaceString
{
    switch (self.bm_colorSpaceModel)
    {
        case kCGColorSpaceModelUnknown:
            return @"kCGColorSpaceModelUnknown";
        case kCGColorSpaceModelMonochrome:
            return @"kCGColorSpaceModelMonochrome";
        case kCGColorSpaceModelRGB:
            return @"kCGColorSpaceModelRGB";
        case kCGColorSpaceModelCMYK:
            return @"kCGColorSpaceModelCMYK";
        case kCGColorSpaceModelLab:
            return @"kCGColorSpaceModelLab";
        case kCGColorSpaceModelDeviceN:
            return @"kCGColorSpaceModelDeviceN";
        case kCGColorSpaceModelIndexed:
            return @"kCGColorSpaceModelIndexed";
        case kCGColorSpaceModelPattern:
            return @"kCGColorSpaceModelPattern";
        default:
            return @"Not a valid color space";
    }
}

- (BOOL)bm_canProvideRGBComponents
{
    switch (self.bm_colorSpaceModel)
    {
        case kCGColorSpaceModelRGB:
        case kCGColorSpaceModelMonochrome:
            return YES;
            
        default:
            return NO;
    }
}

- (NSArray *)bm_arrayFromRGBAComponents
{
    NSAssert(self.bm_canProvideRGBComponents, @"Must be an RGB color to use -arrayFromRGBAComponents");
    
    CGFloat r,g,b,a;
    
    if (![self bm_red:&r green:&g blue:&b alpha:&a])
    {
        return nil;
    }
    
    return [NSArray arrayWithObjects:
            [NSNumber numberWithFloat:r],
            [NSNumber numberWithFloat:g],
            [NSNumber numberWithFloat:b],
            [NSNumber numberWithFloat:a],
            nil];
}

- (BOOL)bm_red:(CGFloat *)red green:(CGFloat *)green blue:(CGFloat *)blue alpha:(CGFloat *)alpha
{
    const CGFloat *components = CGColorGetComponents(self.CGColor);
    
    CGFloat r,g,b,a;
    
    switch (self.bm_colorSpaceModel)
    {
        case kCGColorSpaceModelMonochrome:
            r = g = b = components[0];
            a = components[1];
            break;
            
        case kCGColorSpaceModelRGB:
            r = components[0];
            g = components[1];
            b = components[2];
            a = components[3];
            break;
            
        default: // We don't know how to handle this model
            return NO;
    }
    
    if (red)
        *red = r;
    
    if (green)
        *green = g;
    
    if (blue)
        *blue = b;
    
    if (alpha)
        *alpha = a;
    
    return YES;
}

- (BOOL)bm_hue:(CGFloat *)hue saturation:(CGFloat *)saturation brightness:(CGFloat *)brightness alpha:(CGFloat *)alpha
{
    CGFloat r,g,b,a;
    if (![self bm_red:&r green:&g blue:&b alpha:&a]) return NO;
    
    [UIColor bm_red:r green:g blue:b toHue:hue saturation:saturation brightness:brightness];
    
    if (alpha)
        *alpha = a;
    
    return YES;
}

- (CGFloat)bm_red
{
    NSAssert(self.bm_canProvideRGBComponents, @"Must be an RGB color to use -red");
    
    const CGFloat *c = CGColorGetComponents(self.CGColor);
    return c[0];
}

- (CGFloat)bm_green
{
    NSAssert(self.bm_canProvideRGBComponents, @"Must be an RGB color to use -green");
    
    const CGFloat *c = CGColorGetComponents(self.CGColor);
    if (self.bm_colorSpaceModel == kCGColorSpaceModelMonochrome)
        return c[0];
    return c[1];
}

- (CGFloat)bm_blue
{
    NSAssert(self.bm_canProvideRGBComponents, @"Must be an RGB color to use -blue");
    
    const CGFloat *c = CGColorGetComponents(self.CGColor);
    if (self.bm_colorSpaceModel == kCGColorSpaceModelMonochrome)
        return c[0];
    return c[2];
}

- (CGFloat)bm_white
{
    NSAssert(self.bm_colorSpaceModel == kCGColorSpaceModelMonochrome, @"Must be a Monochrome color to use -white");
    
    const CGFloat *c = CGColorGetComponents(self.CGColor);
    return c[0];
}

- (CGFloat)bm_hue
{
    NSAssert(self.bm_canProvideRGBComponents, @"Must be an RGB color to use -hue");
    
    CGFloat h = 0.0f;
    [self bm_hue:&h saturation:nil brightness:nil alpha:nil];
    return h;
}

- (CGFloat)bm_saturation
{
    NSAssert(self.bm_canProvideRGBComponents, @"Must be an RGB color to use -saturation");
    
    CGFloat s = 0.0f;
    [self bm_hue:nil saturation:&s brightness:nil alpha:nil];
    return s;
}

- (CGFloat)bm_brightness
{
    NSAssert(self.bm_canProvideRGBComponents, @"Must be an RGB color to use -brightness");
    
    CGFloat v = 0.0f;
    [self bm_hue:nil saturation:nil brightness:&v alpha:nil];
    return v;
}

- (CGFloat)bm_alpha
{
    return CGColorGetAlpha(self.CGColor);
}

- (CGFloat)bm_luminance
{
    NSAssert(self.bm_canProvideRGBComponents, @"Must be a RGB color to use luminance");
    
    CGFloat r,g,b;
    if (![self bm_red:&r green:&g blue:&b alpha:nil]) return 0.0f;
    
    // http://en.wikipedia.org/wiki/Luma_(video)
    // Y = 0.2126 R + 0.7152 G + 0.0722 B
    
    return r*0.2126f + g*0.7152f + b*0.0722f;
}

- (UInt32)bm_rgbHex
{
    NSAssert(self.bm_canProvideRGBComponents, @"Must be a RGB color to use rgbHex");
    
    CGFloat r,g,b,a;
    if (![self bm_red:&r green:&g blue:&b alpha:&a]) return 0;
    
    r = MIN(MAX(r, 0.0f), 1.0f);
    g = MIN(MAX(g, 0.0f), 1.0f);
    b = MIN(MAX(b, 0.0f), 1.0f);
    
    return (((int)roundf(r * 255)) << 16)
    | (((int)roundf(g * 255)) << 8)
    | (((int)roundf(b * 255)));
}

- (UInt32)bm_argbHex
{
    NSAssert(self.bm_canProvideRGBComponents, @"Must be a RGB color to use rgbHex");
    
    CGFloat r,g,b,a;
    if (![self bm_red:&r green:&g blue:&b alpha:&a]) return 0;
    
    a = MIN(MAX(a, 0.0f), 1.0f);
    r = MIN(MAX(r, 0.0f), 1.0f);
    g = MIN(MAX(g, 0.0f), 1.0f);
    b = MIN(MAX(b, 0.0f), 1.0f);
    
    return (((int)roundf(a * 255)) << 24)
    | (((int)roundf(r * 255)) << 16)
    | (((int)roundf(g * 255)) << 8)
    | (((int)roundf(b * 255)));
}

- (UInt32)bm_rgbaHex
{
    NSAssert(self.bm_canProvideRGBComponents, @"Must be a RGB color to use rgbHex");
    
    CGFloat r,g,b,a;
    if (![self bm_red:&r green:&g blue:&b alpha:&a]) return 0;
    
    a = MIN(MAX(a, 0.0f), 1.0f);
    r = MIN(MAX(r, 0.0f), 1.0f);
    g = MIN(MAX(g, 0.0f), 1.0f);
    b = MIN(MAX(b, 0.0f), 1.0f);
    
    return (((int)roundf(r * 255)) << 24)
    | (((int)roundf(g * 255)) << 16)
    | (((int)roundf(b * 255)) << 8)
    | (((int)roundf(a * 255)));
}

- (UIColor *)bm_changeAlpha:(CGFloat)alpha
{
    return [UIColor colorWithRed:self.bm_red
                    green:self.bm_green
                     blue:self.bm_blue
                    alpha:alpha];
}

- (BOOL)bm_isLighterColor
{
    const CGFloat* components = CGColorGetComponents(self.CGColor);
    return (components[0]+components[1]+components[2])/3 >= 0.5;
}

- (UIColor *)bm_lighterColor
{
    if ([self isEqual:[UIColor whiteColor]]) return [UIColor colorWithWhite:0.99 alpha:1.0];
    if ([self isEqual:[UIColor blackColor]]) return [UIColor colorWithWhite:0.01 alpha:1.0];
    CGFloat hue, saturation, brightness, alpha, white;
    if ([self getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha])
    {
        return [UIColor colorWithHue:hue
                          saturation:saturation
                          brightness:MIN(brightness * 1.3, 1.0)
                               alpha:alpha];
    }
    else if ([self getWhite:&white alpha:&alpha])
    {
        return [UIColor colorWithWhite:MIN(white * 1.3, 1.0) alpha:alpha];
    }
    return nil;
}

- (UIColor *)bm_darkerColor
{
    if ([self isEqual:[UIColor whiteColor]]) return [UIColor colorWithWhite:0.99 alpha:1.0];
    if ([self isEqual:[UIColor blackColor]]) return [UIColor colorWithWhite:0.01 alpha:1.0];
    CGFloat hue, saturation, brightness, alpha, white;
    if ([self getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha])
    {
        return [UIColor colorWithHue:hue
                          saturation:saturation
                          brightness:brightness * 0.75
                               alpha:alpha];
    }
    else if ([self getWhite:&white alpha:&alpha])
    {
        return [UIColor colorWithWhite:MAX(white * 0.75, 0.0) alpha:alpha];
    }
    return nil;
}

#pragma mark Arithmetic operations

- (UIColor *)bm_colorByLuminanceMapping
{
    return [UIColor colorWithWhite:self.bm_luminance alpha:1.0f];
}

- (UIColor *)bm_colorByMultiplyingByRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha
{
    NSAssert(self.bm_canProvideRGBComponents, @"Must be a RGB color to use arithmetic operations");
    
    CGFloat r,g,b,a;
    if (![self bm_red:&r green:&g blue:&b alpha:&a]) return nil;
    
    return [UIColor colorWithRed:MAX(0.0, MIN(1.0, r * red))
                           green:MAX(0.0, MIN(1.0, g * green))
                            blue:MAX(0.0, MIN(1.0, b * blue))
                           alpha:MAX(0.0, MIN(1.0, a * alpha))];
}

- (UIColor *)bm_colorByAddingRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha
{
    NSAssert(self.bm_canProvideRGBComponents, @"Must be a RGB color to use arithmetic operations");
    
    CGFloat r,g,b,a;
    if (![self bm_red:&r green:&g blue:&b alpha:&a]) return nil;
    
    return [UIColor colorWithRed:MAX(0.0, MIN(1.0, r + red))
                           green:MAX(0.0, MIN(1.0, g + green))
                            blue:MAX(0.0, MIN(1.0, b + blue))
                           alpha:MAX(0.0, MIN(1.0, a + alpha))];
}

- (UIColor *)bm_colorByLighteningToRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha
{
    NSAssert(self.bm_canProvideRGBComponents, @"Must be a RGB color to use arithmetic operations");
    
    CGFloat r,g,b,a;
    if (![self bm_red:&r green:&g blue:&b alpha:&a]) return nil;
    
    return [UIColor colorWithRed:MAX(r, red)
                           green:MAX(g, green)
                            blue:MAX(b, blue)
                           alpha:MAX(a, alpha)];
}

- (UIColor *)bm_colorByDarkeningToRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha
{
    NSAssert(self.bm_canProvideRGBComponents, @"Must be a RGB color to use arithmetic operations");
    
    CGFloat r,g,b,a;
    if (![self bm_red:&r green:&g blue:&b alpha:&a]) return nil;
    
    return [UIColor colorWithRed:MIN(r, red)
                           green:MIN(g, green)
                            blue:MIN(b, blue)
                           alpha:MIN(a, alpha)];
}

- (UIColor *)bm_colorByMultiplyingBy:(CGFloat)f
{
    return [self bm_colorByMultiplyingByRed:f green:f blue:f alpha:1.0f];
}

- (UIColor *)bm_colorByAdding:(CGFloat)f
{
    return [self bm_colorByMultiplyingByRed:f green:f blue:f alpha:0.0f];
}

- (UIColor *)bm_colorByLighteningTo:(CGFloat)f
{
    return [self bm_colorByLighteningToRed:f green:f blue:f alpha:0.0f];
}

- (UIColor *)bm_colorByDarkeningTo:(CGFloat)f
{
    return [self bm_colorByDarkeningToRed:f green:f blue:f alpha:1.0f];
}

- (UIColor *)bm_colorByMultiplyingByColor:(UIColor *)color
{
    NSAssert(self.bm_canProvideRGBComponents, @"Must be a RGB color to use arithmetic operations");
    
    CGFloat r,g,b,a;
    if (![self bm_red:&r green:&g blue:&b alpha:&a]) return nil;
    
    return [self bm_colorByMultiplyingByRed:r green:g blue:b alpha:1.0f];
}

- (UIColor *)bm_colorByAddingColor:(UIColor *)color
{
    NSAssert(self.bm_canProvideRGBComponents, @"Must be a RGB color to use arithmetic operations");
    
    CGFloat r,g,b,a;
    if (![self bm_red:&r green:&g blue:&b alpha:&a]) return nil;
    
    return [self bm_colorByAddingRed:r green:g blue:b alpha:0.0f];
}

- (UIColor *)bm_colorByLighteningToColor:(UIColor *)color
{
    NSAssert(self.bm_canProvideRGBComponents, @"Must be a RGB color to use arithmetic operations");
    
    CGFloat r,g,b,a;
    if (![self bm_red:&r green:&g blue:&b alpha:&a]) return nil;
    
    return [self bm_colorByLighteningToRed:r green:g blue:b alpha:0.0f];
}

- (UIColor *)bm_colorByDarkeningToColor:(UIColor *)color
{
    NSAssert(self.bm_canProvideRGBComponents, @"Must be a RGB color to use arithmetic operations");
    
    CGFloat r,g,b,a;
    if (![self bm_red:&r green:&g blue:&b alpha:&a]) return nil;
    
    return [self bm_colorByDarkeningToRed:r green:g blue:b alpha:1.0f];
}


#pragma mark Complementary Colors, etc

// Pick a color that is likely to contrast well with this color
- (UIColor *)bm_contrastingColor
{
    return (self.bm_luminance > 0.5f) ? [UIColor blackColor] : [UIColor whiteColor];
}

// Pick the color that is 180 degrees away in hue
- (UIColor *)bm_complementaryColor
{
    // Convert to HSB
    CGFloat h,s,v,a;
    if (![self bm_hue:&h saturation:&s brightness:&v alpha:&a]) return nil;
    
    // Pick color 180 degrees away
    h += 180.0f;
    if (h > 360.f) h -= 360.0f;
    
    // Create a color in RGB
    return [UIColor colorWithHue:h saturation:s brightness:v alpha:a];
}

- (UIColor *)bm_disableColor
{
    NSAssert(self.bm_canProvideRGBComponents, @"Must be a RGB color to use arithmetic operations");
    
    CGFloat r,g,b,a;
    if (![self bm_red:&r green:&g blue:&b alpha:&a]) return nil;
    r = floorf(r * 100.0 + 0.5) / 100.0;
    g = floorf(g * 100.0 + 0.5) / 100.0;
    b = floorf(b * 100.0 + 0.5) / 100.0;

    r += 0.4;
    g += 0.4;
    b += 0.4;
    
//    r = ((int)(r * 255) % 255) / 255.0;
//    g = ((int)(g * 255) % 255) / 255.0;
//    b = ((int)(b * 255) % 255) / 255.0;

    return [UIColor colorWithRed:r green:g blue:b alpha:1];
}

- (UIColor *)bm_inverseColor
{
    CGColorRef oldCGColor = self.CGColor;
    
    size_t numberOfComponents = CGColorGetNumberOfComponents(oldCGColor);
    
    // can not invert - the only component is the alpha
    // e.g. self == [UIColor groupTableViewBackgroundColor]
    if (numberOfComponents == 1)
    {
        return [UIColor colorWithCGColor:oldCGColor];
    }
    
    const CGFloat *oldComponentColors = CGColorGetComponents(oldCGColor);
    CGFloat newComponentColors[numberOfComponents];
    
    NSInteger i = numberOfComponents - 1;
    newComponentColors[i] = oldComponentColors[i]; // alpha
    while (--i >= 0)
    {
        newComponentColors[i] = 1 - oldComponentColors[i];
    }
    
    CGColorRef newCGColor = CGColorCreate(CGColorGetColorSpace(oldCGColor), newComponentColors);
    UIColor *newColor = [UIColor colorWithCGColor:newCGColor];
    CGColorRelease(newCGColor);
    
    return newColor;
}

// Pick two colors more colors such that all three are equidistant on the color wheel
// (120 degrees and 240 degress difference in hue from self)
- (NSArray*)bm_triadicColors
{
    return [self bm_analogousColorsWithStepAngle:120.0f pairCount:1];
}

// Pick n pairs of colors, stepping in increasing steps away from this color around the wheel
- (NSArray*)bm_analogousColorsWithStepAngle:(CGFloat)stepAngle pairCount:(int)pairs
{
    // Convert to HSB
    CGFloat h,s,v,a;
    if (![self bm_hue:&h saturation:&s brightness:&v alpha:&a]) return nil;
    
    NSMutableArray* colors = [NSMutableArray arrayWithCapacity:pairs * 2];
    
    if (stepAngle < 0.0f)
        stepAngle *= -1.0f;
    
    for (int i = 1; i <= pairs; ++i) {
        CGFloat a = fmodf(stepAngle * i, 360.0f);
        
        CGFloat h1 = fmodf(h + a, 360.0f);
        CGFloat h2 = fmodf(h + 360.0f - a, 360.0f);
        
        [colors addObject:[UIColor colorWithHue:h1 saturation:s brightness:v alpha:a]];
        [colors addObject:[UIColor colorWithHue:h2 saturation:s brightness:v alpha:a]];
    }
    
    return [colors copy];
}

#pragma mark String utilities

- (NSString *)bm_stringFromColor
{
    NSAssert(self.bm_canProvideRGBComponents, @"Must be an RGB color to use -stringFromColor");
    
    NSString *result;
    switch (self.bm_colorSpaceModel)
    {
        case kCGColorSpaceModelRGB:
            result = [NSString stringWithFormat:@"{%0.3f, %0.3f, %0.3f, %0.3f}", self.bm_red, self.bm_green, self.bm_blue, self.bm_alpha];
            break;
        case kCGColorSpaceModelMonochrome:
            result = [NSString stringWithFormat:@"{%0.3f, %0.3f}", self.bm_white, self.bm_alpha];
            break;
        default:
            result = nil;
    }
    
    return result;
}


#pragma mark Color Space Conversions

+ (void)bm_hue:(CGFloat)h saturation:(CGFloat)s brightness:(CGFloat)v toRed:(CGFloat *)pR green:(CGFloat *)pG blue:(CGFloat *)pB
{
    CGFloat r = 0, g = 0, b = 0;
    
    // From Foley and Van Dam
    
    if (s == 0.0f)
    {
        // Achromatic color: there is no hue
        r = g = b = v;
    }
    else
    {
        // Chromatic color: there is a hue
        if (h == 360.0f) h = 0.0f;
        h /= 60.0f; // h is now in [0, 6)
        
        int i = floorf(h); // largest integer <= h
        CGFloat f = h - i; // fractional part of h
        CGFloat p = v * (1 - s);
        CGFloat q = v * (1 - (s * f));
        CGFloat t = v * (1 - (s * (1 - f)));
        
        switch (i)
        {
            case 0: r = v; g = t; b = p; break;
            case 1: r = q; g = v; b = p; break;
            case 2: r = p; g = v; b = t; break;
            case 3: r = p; g = q; b = v; break;
            case 4: r = t; g = p; b = v; break;
            case 5: r = v; g = p; b = q; break;
        }
    }
    
    if (pR) *pR = r;
    if (pG) *pG = g;
    if (pB) *pB = b;
}


+ (void)bm_red:(CGFloat)r green:(CGFloat)g blue:(CGFloat)b toHue:(CGFloat *)pH saturation:(CGFloat *)pS brightness:(CGFloat *)pV
{
    CGFloat h,s,v;
    
    // From Foley and Van Dam
    
    CGFloat max = MAX(r, MAX(g, b));
    CGFloat min = MIN(r, MIN(g, b));
    
    // Brightness
    v = max;
    
    // Saturation
    s = (max != 0.0f) ? ((max - min) / max) : 0.0f;
    
    if (s == 0.0f)
    {
        // No saturation, so undefined hue
        h = 0.0f;
    }
    else
    {
        // Determine hue
        CGFloat rc = (max - r) / (max - min); // Distance of color from red
        CGFloat gc = (max - g) / (max - min); // Distance of color from green
        CGFloat bc = (max - b) / (max - min); // Distance of color from blue
        
        if (r == max) h = bc - gc; // resulting color between yellow and magenta
        else if (g == max) h = 2 + rc - bc; // resulting color between cyan and yellow
        else /* if (b == max) */ h = 4 + gc - rc; // resulting color between magenta and cyan
        
        h *= 60.0f; // Convert to degrees
        if (h < 0.0f) h += 360.0f; // Make non-negative
    }
    
    if (pH) *pH = h;
    if (pS) *pS = s;
    if (pV) *pV = v;
}

@end

@implementation UIColor (ImagePoint)

// https://stackoverflow.com/questions/448125/how-to-get-pixel-data-from-a-uiimage-cocoa-touch-or-cgimage-core-graphics/1262893#1262893
+ (UIColor *)bm_colorFromImage:(UIImage *)image atPoint:(CGPoint)point
{
    //Encapsulate our image
    CGImageRef imageRef = image.CGImage;
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    
    //Specify the colorspace we're in
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    //Extract the data we need
    unsigned char *rawData = calloc(height * width * 4, sizeof(unsigned char));
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, width, height, bitsPerComponent, bytesPerRow,
                                                 colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    //Release colorspace
    CGColorSpaceRelease(colorSpace);
    
    //Draw and release image
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(context);
    
    //rawData now contains the image data in RGBA8888
    NSInteger byteIndex = (bytesPerRow * point.y) + (point.x * bytesPerPixel);
    
    //Define our RGBA values
    CGFloat red = (rawData[byteIndex] * 1.f) / 255.f;
    CGFloat green = (rawData[byteIndex + 1] * 1.f) / 255.f;
    CGFloat blue = (rawData[byteIndex + 2] * 1.f) / 255.f;
    CGFloat alpha = (rawData[byteIndex + 3] * 1.0) / 255.f;
    
    //Free our rawData
    free(rawData);
    
    //Return color
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

@end

