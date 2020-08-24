/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "BMSDImageLoader.h"
#import "BMSDWebImageCacheKeyFilter.h"
#import "BMSDImageCodersManager.h"
#import "BMSDImageCoderHelper.h"
#import "BMSDAnimatedImage.h"
#import "UIImage+BMMetadata.h"
#import "BMSDInternalMacros.h"
#import "objc/runtime.h"

static void * BMSDImageLoaderProgressiveCoderKey = &BMSDImageLoaderProgressiveCoderKey;

UIImage * _Nullable BMSDImageLoaderDecodeImageData(NSData * _Nonnull imageData, NSURL * _Nonnull imageURL, BMSDWebImageOptions options, BMSDWebImageContext * _Nullable context) {
    NSCParameterAssert(imageData);
    NSCParameterAssert(imageURL);
    
    UIImage *image;
    id<BMSDWebImageCacheKeyFilter> cacheKeyFilter = context[BMSDWebImageContextCacheKeyFilter];
    NSString *cacheKey;
    if (cacheKeyFilter) {
        cacheKey = [cacheKeyFilter cacheKeyForURL:imageURL];
    } else {
        cacheKey = imageURL.absoluteString;
    }
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
        // check whether we should use `SDAnimatedImage`
        Class animatedImageClass = context[BMSDWebImageContextAnimatedImageClass];
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

UIImage * _Nullable BMSDImageLoaderDecodeProgressiveImageData(NSData * _Nonnull imageData, NSURL * _Nonnull imageURL, BOOL finished,  id<BMSDWebImageOperation> _Nonnull operation, BMSDWebImageOptions options, BMSDWebImageContext * _Nullable context) {
    NSCParameterAssert(imageData);
    NSCParameterAssert(imageURL);
    NSCParameterAssert(operation);
    
    UIImage *image;
    id<BMSDWebImageCacheKeyFilter> cacheKeyFilter = context[BMSDWebImageContextCacheKeyFilter];
    NSString *cacheKey;
    if (cacheKeyFilter) {
        cacheKey = [cacheKeyFilter cacheKeyForURL:imageURL];
    } else {
        cacheKey = imageURL.absoluteString;
    }
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
    
    // Grab the progressive image coder
    id<BMSDProgressiveImageCoder> progressiveCoder = objc_getAssociatedObject(operation, BMSDImageLoaderProgressiveCoderKey);
    if (!progressiveCoder) {
        id<BMSDProgressiveImageCoder> imageCoder = context[BMSDWebImageContextImageCoder];
        // Check the progressive coder if provided
        if ([imageCoder conformsToProtocol:@protocol(BMSDProgressiveImageCoder)]) {
            progressiveCoder = [[[imageCoder class] alloc] initIncrementalWithOptions:coderOptions];
        } else {
            // We need to create a new instance for progressive decoding to avoid conflicts
            for (id<BMSDImageCoder> coder in [BMSDImageCodersManager sharedManager].coders.reverseObjectEnumerator) {
                if ([coder conformsToProtocol:@protocol(BMSDProgressiveImageCoder)] &&
                    [((id<BMSDProgressiveImageCoder>)coder) canIncrementalDecodeFromData:imageData]) {
                    progressiveCoder = [[[coder class] alloc] initIncrementalWithOptions:coderOptions];
                    break;
                }
            }
        }
        objc_setAssociatedObject(operation, BMSDImageLoaderProgressiveCoderKey, progressiveCoder, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    // If we can't find any progressive coder, disable progressive download
    if (!progressiveCoder) {
        return nil;
    }
    
    [progressiveCoder updateIncrementalData:imageData finished:finished];
    if (!decodeFirstFrame) {
        // check whether we should use `SDAnimatedImage`
        Class animatedImageClass = context[BMSDWebImageContextAnimatedImageClass];
        if ([animatedImageClass isSubclassOfClass:[UIImage class]] && [animatedImageClass conformsToProtocol:@protocol(BMSDAnimatedImage)] && [progressiveCoder conformsToProtocol:@protocol(BMSDAnimatedImageCoder)]) {
            image = [[animatedImageClass alloc] initWithAnimatedCoder:(id<BMSDAnimatedImageCoder>)progressiveCoder scale:scale];
            if (image) {
                // Progressive decoding does not preload frames
            } else {
                // Check image class matching
                if (options & BMSDWebImageMatchAnimatedImageClass) {
                    return nil;
                }
            }
        }
    }
    if (!image) {
        image = [progressiveCoder incrementalDecodedImageWithOptions:coderOptions];
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
        // mark the image as progressive (completionBlock one are not mark as progressive)
        image.bmsd_isIncremental = YES;
    }
    
    return image;
}

BMSDWebImageContextOption const BMSDWebImageContextLoaderCachedImage = @"loaderCachedImage";
