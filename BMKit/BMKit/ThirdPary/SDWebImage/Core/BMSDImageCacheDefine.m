/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "BMSDImageCacheDefine.h"
#import "BMSDImageCodersManager.h"
#import "BMSDImageCoderHelper.h"
#import "BMSDAnimatedImage.h"
#import "UIImage+BMMetadata.h"
#import "BMSDInternalMacros.h"

UIImage * _Nullable BMSDImageCacheDecodeImageData(NSData * _Nonnull imageData, NSString * _Nonnull cacheKey, BMSDWebImageOptions options, BMSDWebImageContext * _Nullable context) {
    UIImage *image;
    BOOL decodeFirstFrame = BMSD_OPTIONS_CONTAINS(options, BMSDWebImageDecodeFirstFrameOnly);
    NSNumber *scaleValue = context[BMSDWebImageContextImageScaleFactor];
    CGFloat scale = scaleValue.doubleValue >= 1 ? scaleValue.doubleValue : BMSDImageScaleFactorForKey(cacheKey);
    NSNumber *preserveAspectRatioValue = context[BMSDWebImageContextImagePreserveAspectRatio];
    NSValue *thumbnailSizeValue;
    BOOL shouldScaleDown = BMSD_OPTIONS_CONTAINS(options, BMSDWebImageScaleDownLargeImages);
    if (shouldScaleDown) {
        CGFloat thumbnailPixels = BMSDImageCoderHelper.defaultScaleDownLimitBytes / 4;
        CGFloat dimension = ceil(sqrt(thumbnailPixels));
        thumbnailSizeValue = @(CGSizeMake(dimension, dimension));
    }
    if (context[BMSDWebImageContextImageThumbnailPixelSize]) {
        thumbnailSizeValue = context[BMSDWebImageContextImageThumbnailPixelSize];
    }
    
    BMSDImageCoderMutableOptions *mutableCoderOptions = [NSMutableDictionary dictionaryWithCapacity:2];
    mutableCoderOptions[BMSDImageCoderDecodeFirstFrameOnly] = @(decodeFirstFrame);
    mutableCoderOptions[BMSDImageCoderDecodeScaleFactor] = @(scale);
    mutableCoderOptions[BMSDImageCoderDecodePreserveAspectRatio] = preserveAspectRatioValue;
    mutableCoderOptions[BMSDImageCoderDecodeThumbnailPixelSize] = thumbnailSizeValue;
    mutableCoderOptions[BMSDImageCoderWebImageContext] = context;
    BMSDImageCoderOptions *coderOptions = [mutableCoderOptions copy];
    
    // Grab the image coder
    id<BMSDImageCoder> imageCoder;
    if ([context[BMSDWebImageContextImageCoder] conformsToProtocol:@protocol(BMSDImageCoder)]) {
        imageCoder = context[BMSDWebImageContextImageCoder];
    } else {
        imageCoder = [BMSDImageCodersManager sharedManager];
    }
    
    if (!decodeFirstFrame) {
        Class animatedImageClass = context[BMSDWebImageContextAnimatedImageClass];
        // check whether we should use `SDAnimatedImage`
        if ([animatedImageClass isSubclassOfClass:[UIImage class]] && [animatedImageClass conformsToProtocol:@protocol(BMSDAnimatedImage)]) {
            image = [[animatedImageClass alloc] initWithData:imageData scale:scale options:coderOptions];
            if (image) {
                // Preload frames if supported
                if (options & BMSDWebImagePreloadAllFrames && [image respondsToSelector:@selector(preloadAllFrames)]) {
                    [((id<BMSDAnimatedImage>)image) preloadAllFrames];
                }
            } else {
                // Check image class matching
                if (options & BMSDWebImageMatchAnimatedImageClass) {
                    return nil;
                }
            }
        }
    }
    if (!image) {
        image = [imageCoder decodedImageWithData:imageData options:coderOptions];
    }
    if (image) {
        BOOL shouldDecode = !BMSD_OPTIONS_CONTAINS(options, BMSDWebImageAvoidDecodeImage);
        if ([image.class conformsToProtocol:@protocol(BMSDAnimatedImage)]) {
            // `SDAnimatedImage` do not decode
            shouldDecode = NO;
        } else if (image.bmsd_isAnimated) {
            // animated image do not decode
            shouldDecode = NO;
        }
        if (shouldDecode) {
            image = [BMSDImageCoderHelper decodedImageWithImage:image];
        }
    }
    
    return image;
}
