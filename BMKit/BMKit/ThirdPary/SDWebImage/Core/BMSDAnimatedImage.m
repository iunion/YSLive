/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "BMSDAnimatedImage.h"
#import "NSImage+BMCompatibility.h"
#import "BMSDImageCoder.h"
#import "BMSDImageCodersManager.h"
#import "BMSDImageFrame.h"
#import "UIImage+BMMemoryCacheCost.h"
#import "UIImage+BMMetadata.h"
#import "UIImage+BMMultiFormat.h"
#import "BMSDImageCoderHelper.h"
#import "BMSDImageAssetManager.h"
#import "objc/runtime.h"

static CGFloat BMSDImageScaleFromPath(NSString *string) {
    if (string.length == 0 || [string hasSuffix:@"/"]) return 1;
    NSString *name = string.stringByDeletingPathExtension;
    __block CGFloat scale = 1;
    
    NSRegularExpression *pattern = [NSRegularExpression regularExpressionWithPattern:@"@[0-9]+\\.?[0-9]*x$" options:NSRegularExpressionAnchorsMatchLines error:nil];
    [pattern enumerateMatchesInString:name options:kNilOptions range:NSMakeRange(0, name.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        scale = [string substringWithRange:NSMakeRange(result.range.location + 1, result.range.length - 2)].doubleValue;
    }];
    
    return scale;
}

@interface BMSDAnimatedImage ()

@property (nonatomic, strong) id<BMSDAnimatedImageCoder> animatedCoder;
@property (nonatomic, assign, readwrite) BMSDImageFormat animatedImageFormat;
@property (atomic, copy) NSArray<BMSDImageFrame *> *loadedAnimatedImageFrames; // Mark as atomic to keep thread-safe
@property (nonatomic, assign, getter=isAllFramesLoaded) BOOL allFramesLoaded;

@end

@implementation BMSDAnimatedImage
@dynamic scale; // call super

#pragma mark - UIImage override method
+ (instancetype)imageNamed:(NSString *)name {
#if __has_include(<UIKit/UITraitCollection.h>)
    return [self imageNamed:name inBundle:nil compatibleWithTraitCollection:nil];
#else
    return [self imageNamed:name inBundle:nil];
#endif
}

#if __has_include(<UIKit/UITraitCollection.h>)
+ (instancetype)imageNamed:(NSString *)name inBundle:(NSBundle *)bundle compatibleWithTraitCollection:(UITraitCollection *)traitCollection {
    if (!traitCollection) {
        traitCollection = UIScreen.mainScreen.traitCollection;
    }
    CGFloat scale = traitCollection.displayScale;
    return [self imageNamed:name inBundle:bundle scale:scale];
}
#else
+ (instancetype)imageNamed:(NSString *)name inBundle:(NSBundle *)bundle {
    return [self imageNamed:name inBundle:bundle scale:0];
}
#endif

// 0 scale means automatically check
+ (instancetype)imageNamed:(NSString *)name inBundle:(NSBundle *)bundle scale:(CGFloat)scale {
    if (!name) {
        return nil;
    }
    if (!bundle) {
        bundle = [NSBundle mainBundle];
    }
    BMSDImageAssetManager *assetManager = [BMSDImageAssetManager sharedAssetManager];
    BMSDAnimatedImage *image = (BMSDAnimatedImage *)[assetManager imageForName:name];
    if ([image isKindOfClass:[BMSDAnimatedImage class]]) {
        return image;
    }
    NSString *path = [assetManager getPathForName:name bundle:bundle preferredScale:&scale];
    if (!path) {
        return image;
    }
    NSData *data = [NSData dataWithContentsOfFile:path];
    if (!data) {
        return image;
    }
    image = [[self alloc] initWithData:data scale:scale];
    if (image) {
        [assetManager storeImage:image forName:name];
    }
    
    return image;
}

+ (instancetype)imageWithContentsOfFile:(NSString *)path {
    return [[self alloc] initWithContentsOfFile:path];
}

+ (instancetype)imageWithData:(NSData *)data {
    return [[self alloc] initWithData:data];
}

+ (instancetype)imageWithData:(NSData *)data scale:(CGFloat)scale {
    return [[self alloc] initWithData:data scale:scale];
}

- (instancetype)initWithContentsOfFile:(NSString *)path {
    NSData *data = [NSData dataWithContentsOfFile:path];
    return [self initWithData:data scale:BMSDImageScaleFromPath(path)];
}

- (instancetype)initWithData:(NSData *)data {
    return [self initWithData:data scale:1];
}

- (instancetype)initWithData:(NSData *)data scale:(CGFloat)scale {
    return [self initWithData:data scale:scale options:nil];
}

- (instancetype)initWithData:(NSData *)data scale:(CGFloat)scale options:(BMSDImageCoderOptions *)options {
    if (!data || data.length == 0) {
        return nil;
    }
    data = [data copy]; // avoid mutable data
    id<BMSDAnimatedImageCoder> animatedCoder = nil;
    for (id<BMSDImageCoder>coder in [BMSDImageCodersManager sharedManager].coders.reverseObjectEnumerator) {
        if ([coder conformsToProtocol:@protocol(BMSDAnimatedImageCoder)]) {
            if ([coder canDecodeFromData:data]) {
                if (!options) {
                    options = @{BMSDImageCoderDecodeScaleFactor : @(scale)};
                }
                animatedCoder = [[[coder class] alloc] initWithAnimatedImageData:data options:options];
                break;
            }
        }
    }
    if (!animatedCoder) {
        return nil;
    }
    return [self initWithAnimatedCoder:animatedCoder scale:scale];
}

- (instancetype)initWithAnimatedCoder:(id<BMSDAnimatedImageCoder>)animatedCoder scale:(CGFloat)scale {
    if (!animatedCoder) {
        return nil;
    }
    UIImage *image = [animatedCoder animatedImageFrameAtIndex:0];
    if (!image) {
        return nil;
    }
#if BMSD_MAC
    self = [super initWithCGImage:image.CGImage scale:MAX(scale, 1) orientation:kCGImagePropertyOrientationUp];
#else
    self = [super initWithCGImage:image.CGImage scale:MAX(scale, 1) orientation:image.imageOrientation];
#endif
    if (self) {
        // Only keep the animated coder if frame count > 1, save RAM usage for non-animated image format (APNG/WebP)
        if (animatedCoder.animatedImageFrameCount > 1) {
            _animatedCoder = animatedCoder;
        }
        NSData *data = [animatedCoder animatedImageData];
        BMSDImageFormat format = [NSData bmsd_imageFormatForImageData:data];
        _animatedImageFormat = format;
    }
    return self;
}

#pragma mark - Preload
- (void)preloadAllFrames {
    if (!_animatedCoder) {
        return;
    }
    if (!self.isAllFramesLoaded) {
        NSMutableArray<BMSDImageFrame *> *frames = [NSMutableArray arrayWithCapacity:self.animatedImageFrameCount];
        for (size_t i = 0; i < self.animatedImageFrameCount; i++) {
            UIImage *image = [self animatedImageFrameAtIndex:i];
            NSTimeInterval duration = [self animatedImageDurationAtIndex:i];
            BMSDImageFrame *frame = [BMSDImageFrame frameWithImage:image duration:duration]; // through the image should be nonnull, used as nullable for `animatedImageFrameAtIndex:`
            [frames addObject:frame];
        }
        self.loadedAnimatedImageFrames = frames;
        self.allFramesLoaded = YES;
    }
}

- (void)unloadAllFrames {
    if (!_animatedCoder) {
        return;
    }
    if (self.isAllFramesLoaded) {
        self.loadedAnimatedImageFrames = nil;
        self.allFramesLoaded = NO;
    }
}

#pragma mark - NSSecureCoding
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _animatedImageFormat = [aDecoder decodeIntegerForKey:NSStringFromSelector(@selector(animatedImageFormat))];
        NSData *animatedImageData = [aDecoder decodeObjectOfClass:[NSData class] forKey:NSStringFromSelector(@selector(animatedImageData))];
        if (!animatedImageData) {
            return self;
        }
        CGFloat scale = self.scale;
        id<BMSDAnimatedImageCoder> animatedCoder = nil;
        for (id<BMSDImageCoder>coder in [BMSDImageCodersManager sharedManager].coders.reverseObjectEnumerator) {
            if ([coder conformsToProtocol:@protocol(BMSDAnimatedImageCoder)]) {
                if ([coder canDecodeFromData:animatedImageData]) {
                    animatedCoder = [[[coder class] alloc] initWithAnimatedImageData:animatedImageData options:@{BMSDImageCoderDecodeScaleFactor : @(scale)}];
                    break;
                }
            }
        }
        if (!animatedCoder) {
            return self;
        }
        if (animatedCoder.animatedImageFrameCount > 1) {
            _animatedCoder = animatedCoder;
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeInteger:self.animatedImageFormat forKey:NSStringFromSelector(@selector(animatedImageFormat))];
    NSData *animatedImageData = self.animatedImageData;
    if (animatedImageData) {
        [aCoder encodeObject:animatedImageData forKey:NSStringFromSelector(@selector(animatedImageData))];
    }
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

#pragma mark - SDAnimatedImageProvider

- (NSData *)animatedImageData {
    return [self.animatedCoder animatedImageData];
}

- (NSUInteger)animatedImageLoopCount {
    return [self.animatedCoder animatedImageLoopCount];
}

- (NSUInteger)animatedImageFrameCount {
    return [self.animatedCoder animatedImageFrameCount];
}

- (UIImage *)animatedImageFrameAtIndex:(NSUInteger)index {
    if (index >= self.animatedImageFrameCount) {
        return nil;
    }
    if (self.isAllFramesLoaded) {
        BMSDImageFrame *frame = [self.loadedAnimatedImageFrames objectAtIndex:index];
        return frame.image;
    }
    return [self.animatedCoder animatedImageFrameAtIndex:index];
}

- (NSTimeInterval)animatedImageDurationAtIndex:(NSUInteger)index {
    if (index >= self.animatedImageFrameCount) {
        return 0;
    }
    if (self.isAllFramesLoaded) {
        BMSDImageFrame *frame = [self.loadedAnimatedImageFrames objectAtIndex:index];
        return frame.duration;
    }
    return [self.animatedCoder animatedImageDurationAtIndex:index];
}

@end

@implementation BMSDAnimatedImage (MemoryCacheCost)

- (NSUInteger)sd_memoryCost {
    NSNumber *value = objc_getAssociatedObject(self, @selector(sd_memoryCost));
    if (value != nil) {
        return value.unsignedIntegerValue;
    }
    
    CGImageRef imageRef = self.CGImage;
    if (!imageRef) {
        return 0;
    }
    NSUInteger bytesPerFrame = CGImageGetBytesPerRow(imageRef) * CGImageGetHeight(imageRef);
    NSUInteger frameCount = 1;
    if (self.isAllFramesLoaded) {
        frameCount = self.animatedImageFrameCount;
    }
    frameCount = frameCount > 0 ? frameCount : 1;
    NSUInteger cost = bytesPerFrame * frameCount;
    return cost;
}

@end

@implementation BMSDAnimatedImage (Metadata)

- (BOOL)sd_isAnimated {
    return YES;
}

- (NSUInteger)sd_imageLoopCount {
    return self.animatedImageLoopCount;
}

- (void)setSd_imageLoopCount:(NSUInteger)sd_imageLoopCount {
    return;
}

- (NSUInteger)sd_imageFrameCount {
    return self.animatedImageFrameCount;
}

- (BMSDImageFormat)sd_imageFormat {
    return self.animatedImageFormat;
}

- (void)setSd_imageFormat:(BMSDImageFormat)sd_imageFormat {
    return;
}

- (BOOL)sd_isVector {
    return NO;
}

@end

@implementation BMSDAnimatedImage (MultiFormat)

+ (nullable UIImage *)sd_imageWithData:(nullable NSData *)data {
    return [self sd_imageWithData:data scale:1];
}

+ (nullable UIImage *)sd_imageWithData:(nullable NSData *)data scale:(CGFloat)scale {
    return [self sd_imageWithData:data scale:scale firstFrameOnly:NO];
}

+ (nullable UIImage *)sd_imageWithData:(nullable NSData *)data scale:(CGFloat)scale firstFrameOnly:(BOOL)firstFrameOnly {
    if (!data) {
        return nil;
    }
    return [[self alloc] initWithData:data scale:scale options:@{BMSDImageCoderDecodeFirstFrameOnly : @(firstFrameOnly)}];
}

- (nullable NSData *)sd_imageData {
    NSData *imageData = self.animatedImageData;
    if (imageData) {
        return imageData;
    } else {
        return [self sd_imageDataAsFormat:self.animatedImageFormat];
    }
}

- (nullable NSData *)sd_imageDataAsFormat:(BMSDImageFormat)imageFormat {
    return [self sd_imageDataAsFormat:imageFormat compressionQuality:1];
}

- (nullable NSData *)sd_imageDataAsFormat:(BMSDImageFormat)imageFormat compressionQuality:(double)compressionQuality {
    return [self sd_imageDataAsFormat:imageFormat compressionQuality:compressionQuality firstFrameOnly:NO];
}

- (nullable NSData *)sd_imageDataAsFormat:(BMSDImageFormat)imageFormat compressionQuality:(double)compressionQuality firstFrameOnly:(BOOL)firstFrameOnly {
    if (firstFrameOnly) {
        // First frame, use super implementation
        return [super bmsd_imageDataAsFormat:imageFormat compressionQuality:compressionQuality firstFrameOnly:firstFrameOnly];
    }
    NSUInteger frameCount = self.animatedImageFrameCount;
    if (frameCount <= 1) {
        // Static image, use super implementation
        return [super bmsd_imageDataAsFormat:imageFormat compressionQuality:compressionQuality firstFrameOnly:firstFrameOnly];
    }
    // Keep animated image encoding, loop each frame.
    NSMutableArray<BMSDImageFrame *> *frames = [NSMutableArray arrayWithCapacity:frameCount];
    for (size_t i = 0; i < frameCount; i++) {
        UIImage *image = [self animatedImageFrameAtIndex:i];
        NSTimeInterval duration = [self animatedImageDurationAtIndex:i];
        BMSDImageFrame *frame = [BMSDImageFrame frameWithImage:image duration:duration];
        [frames addObject:frame];
    }
    UIImage *animatedImage = [BMSDImageCoderHelper animatedImageWithFrames:frames];
    NSData *imageData = [animatedImage bmsd_imageDataAsFormat:imageFormat compressionQuality:compressionQuality firstFrameOnly:firstFrameOnly];
    return imageData;
}

@end
