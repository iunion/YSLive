/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "BMSDImageAPNGCoder.h"
#if BMSD_MAC
#import <CoreServices/CoreServices.h>
#else
#import <MobileCoreServices/MobileCoreServices.h>
#endif

@implementation BMSDImageAPNGCoder

+ (instancetype)sharedCoder {
    static BMSDImageAPNGCoder *coder;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        coder = [[BMSDImageAPNGCoder alloc] init];
    });
    return coder;
}

#pragma mark - Subclass Override

+ (BMSDImageFormat)imageFormat {
    return BMSDImageFormatPNG;
}

+ (NSString *)imageUTType {
    return (__bridge NSString *)kUTTypePNG;
}

+ (NSString *)dictionaryProperty {
    return (__bridge NSString *)kCGImagePropertyPNGDictionary;
}

+ (NSString *)unclampedDelayTimeProperty {
    return (__bridge NSString *)kCGImagePropertyAPNGUnclampedDelayTime;
}

+ (NSString *)delayTimeProperty {
    return (__bridge NSString *)kCGImagePropertyAPNGDelayTime;
}

+ (NSString *)loopCountProperty {
    return (__bridge NSString *)kCGImagePropertyAPNGLoopCount;
}

+ (NSUInteger)defaultLoopCount {
    return 0;
}

@end
