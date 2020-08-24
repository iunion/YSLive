/*
* This file is part of the SDWebImage package.
* (c) Olivier Poitrey <rs@dailymotion.com>
*
* For the full copyright and license information, please view the LICENSE
* file that was distributed with this source code.
*/

#import "BMSDImageAWebPCoder.h"
#import "BMSDImageIOAnimatedCoderInternal.h"

// These constants are available from iOS 14+ and Xcode 12. This raw value is used for toolchain and firmware compatibility
static NSString * kBMSDCGImagePropertyWebPDictionary = @"{WebP}";
static NSString * kBMSDCGImagePropertyWebPLoopCount = @"LoopCount";
static NSString * kBMSDCGImagePropertyWebPDelayTime = @"DelayTime";
static NSString * kBMSDCGImagePropertyWebPUnclampedDelayTime = @"UnclampedDelayTime";

@implementation BMSDImageAWebPCoder

+ (void)initialize {
#if __IPHONE_14_0 || __TVOS_14_0 || __MAC_11_0 || __WATCHOS_7_0
    // Xcode 12
    if (@available(iOS 14, tvOS 14, macOS 11, watchOS 7, *)) {
        // Use SDK instead of raw value
        kBMSDCGImagePropertyWebPDictionary = (__bridge NSString *)kCGImagePropertyWebPDictionary;
        kBMSDCGImagePropertyWebPLoopCount = (__bridge NSString *)kCGImagePropertyWebPLoopCount;
        kBMSDCGImagePropertyWebPDelayTime = (__bridge NSString *)kCGImagePropertyWebPDelayTime;
        kBMSDCGImagePropertyWebPUnclampedDelayTime = (__bridge NSString *)kCGImagePropertyWebPUnclampedDelayTime;
    }
#endif
}

+ (instancetype)sharedCoder {
    static BMSDImageAWebPCoder *coder;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        coder = [[BMSDImageAWebPCoder alloc] init];
    });
    return coder;
}

#pragma mark - SDImageCoder

- (BOOL)canDecodeFromData:(nullable NSData *)data {
    switch ([NSData bmsd_imageFormatForImageData:data]) {
        case BMSDImageFormatWebP:
            // Check WebP decoding compatibility
            return [self.class canDecodeFromFormat:BMSDImageFormatWebP];
        default:
            return NO;
    }
}

- (BOOL)canIncrementalDecodeFromData:(NSData *)data {
    return [self canDecodeFromData:data];
}

- (BOOL)canEncodeToFormat:(BMSDImageFormat)format {
    switch (format) {
        case BMSDImageFormatWebP:
            // Check WebP encoding compatibility
            return [self.class canEncodeToFormat:BMSDImageFormatWebP];
        default:
            return NO;
    }
}

#pragma mark - Subclass Override

+ (BMSDImageFormat)imageFormat {
    return BMSDImageFormatWebP;
}

+ (NSString *)imageUTType {
    return (__bridge NSString *)kBMSDUTTypeWebP;
}

+ (NSString *)dictionaryProperty {
    return kBMSDCGImagePropertyWebPDictionary;
}

+ (NSString *)unclampedDelayTimeProperty {
    return kBMSDCGImagePropertyWebPUnclampedDelayTime;
}

+ (NSString *)delayTimeProperty {
    return kBMSDCGImagePropertyWebPDelayTime;
}

+ (NSString *)loopCountProperty {
    return kBMSDCGImagePropertyWebPLoopCount;
}

+ (NSUInteger)defaultLoopCount {
    return 0;
}

@end
