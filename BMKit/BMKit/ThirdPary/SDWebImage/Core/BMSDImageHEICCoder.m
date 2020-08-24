/*
* This file is part of the SDWebImage package.
* (c) Olivier Poitrey <rs@dailymotion.com>
*
* For the full copyright and license information, please view the LICENSE
* file that was distributed with this source code.
*/

#import "BMSDImageHEICCoder.h"
#import "BMSDImageIOAnimatedCoderInternal.h"

// These constants are available from iOS 13+ and Xcode 11. This raw value is used for toolchain and firmware compatibility
static NSString * kBMSDCGImagePropertyHEICSDictionary = @"{HEICS}";
static NSString * kBMSDCGImagePropertyHEICSLoopCount = @"LoopCount";
static NSString * kBMSDCGImagePropertyHEICSDelayTime = @"DelayTime";
static NSString * kBMSDCGImagePropertyHEICSUnclampedDelayTime = @"UnclampedDelayTime";

@implementation BMSDImageHEICCoder

+ (void)initialize {
#if __IPHONE_13_0 || __TVOS_13_0 || __MAC_10_15 || __WATCHOS_6_0
    // Xcode 11
    if (@available(iOS 13, tvOS 13, macOS 10.15, watchOS 6, *)) {
        // Use SDK instead of raw value
        kBMSDCGImagePropertyHEICSDictionary = (__bridge NSString *)kCGImagePropertyHEICSDictionary;
        kBMSDCGImagePropertyHEICSLoopCount = (__bridge NSString *)kCGImagePropertyHEICSLoopCount;
        kBMSDCGImagePropertyHEICSDelayTime = (__bridge NSString *)kCGImagePropertyHEICSDelayTime;
        kBMSDCGImagePropertyHEICSUnclampedDelayTime = (__bridge NSString *)kCGImagePropertyHEICSUnclampedDelayTime;
    }
#endif
}

+ (instancetype)sharedCoder {
    static BMSDImageHEICCoder *coder;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        coder = [[BMSDImageHEICCoder alloc] init];
    });
    return coder;
}

#pragma mark - SDImageCoder

- (BOOL)canDecodeFromData:(nullable NSData *)data {
    switch ([NSData bmsd_imageFormatForImageData:data]) {
        case BMSDImageFormatHEIC:
            // Check HEIC decoding compatibility
            return [self.class canDecodeFromFormat:BMSDImageFormatHEIC];
        case BMSDImageFormatHEIF:
            // Check HEIF decoding compatibility
            return [self.class canDecodeFromFormat:BMSDImageFormatHEIF];
        default:
            return NO;
    }
}

- (BOOL)canIncrementalDecodeFromData:(NSData *)data {
    return [self canDecodeFromData:data];
}

- (BOOL)canEncodeToFormat:(BMSDImageFormat)format {
    switch (format) {
        case BMSDImageFormatHEIC:
            // Check HEIC encoding compatibility
            return [self.class canEncodeToFormat:BMSDImageFormatHEIC];
        case BMSDImageFormatHEIF:
            // Check HEIF encoding compatibility
            return [self.class canEncodeToFormat:BMSDImageFormatHEIF];
        default:
            return NO;
    }
}

#pragma mark - Subclass Override

+ (BMSDImageFormat)imageFormat {
    return BMSDImageFormatHEIC;
}

+ (NSString *)imageUTType {
    return (__bridge NSString *)kBMSDUTTypeHEIC;
}

+ (NSString *)dictionaryProperty {
    return kBMSDCGImagePropertyHEICSDictionary;
}

+ (NSString *)unclampedDelayTimeProperty {
    return kBMSDCGImagePropertyHEICSUnclampedDelayTime;
}

+ (NSString *)delayTimeProperty {
    return kBMSDCGImagePropertyHEICSDelayTime;
}

+ (NSString *)loopCountProperty {
    return kBMSDCGImagePropertyHEICSLoopCount;
}

+ (NSUInteger)defaultLoopCount {
    return 0;
}

@end
