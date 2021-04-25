/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "BMSDWebImageDefine.h"
#import "UIImage+BMMetadata.h"
#import "NSImage+BMCompatibility.h"
#import "BMSDAssociatedObject.h"

#pragma mark - Image scale

static inline NSArray<NSNumber *> * _Nonnull BMSDImageScaleFactors() {
    return @[@2, @3];
}

inline CGFloat BMSDImageScaleFactorForKey(NSString * _Nullable key) {
    CGFloat scale = 1;
    if (!key) {
        return scale;
    }
    // Check if target OS support scale
#if BMSD_WATCH
    if ([[WKInterfaceDevice currentDevice] respondsToSelector:@selector(screenScale)])
#elif BMSD_UIKIT
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)])
#elif BMSD_MAC
    if ([[NSScreen mainScreen] respondsToSelector:@selector(backingScaleFactor)])
#endif
    {
        // a@2x.png -> 8
        if (key.length >= 8) {
            // Fast check
            BOOL isURL = [key hasPrefix:@"http://"] || [key hasPrefix:@"https://"];
            for (NSNumber *scaleFactor in BMSDImageScaleFactors()) {
                // @2x. for file name and normal url
                NSString *fileScale = [NSString stringWithFormat:@"@%@x.", scaleFactor];
                if ([key containsString:fileScale]) {
                    scale = scaleFactor.doubleValue;
                    return scale;
                }
                if (isURL) {
                    // %402x. for url encode
                    NSString *urlScale = [NSString stringWithFormat:@"%%40%@x.", scaleFactor];
                    if ([key containsString:urlScale]) {
                        scale = scaleFactor.doubleValue;
                        return scale;
                    }
                }
            }
        }
    }
    return scale;
}

inline UIImage * _Nullable BMSDScaledImageForKey(NSString * _Nullable key, UIImage * _Nullable image) {
    if (!image) {
        return nil;
    }
    CGFloat scale = BMSDImageScaleFactorForKey(key);
    return BMSDScaledImageForScaleFactor(scale, image);
}

inline UIImage * _Nullable BMSDScaledImageForScaleFactor(CGFloat scale, UIImage * _Nullable image) {
    if (!image) {
        return nil;
    }
    if (scale <= 1) {
        return image;
    }
    if (scale == image.scale) {
        return image;
    }
    UIImage *scaledImage;
    if (image.bmsd_isAnimated) {
        UIImage *animatedImage;
#if BMSD_UIKIT || BMSD_WATCH
        // `UIAnimatedImage` images share the same size and scale.
        NSMutableArray<UIImage *> *scaledImages = [NSMutableArray array];
        
        for (UIImage *tempImage in image.images) {
            UIImage *tempScaledImage = [[UIImage alloc] initWithCGImage:tempImage.CGImage scale:scale orientation:tempImage.imageOrientation];
            [scaledImages addObject:tempScaledImage];
        }
        
        animatedImage = [UIImage animatedImageWithImages:scaledImages duration:image.duration];
        animatedImage.bmsd_imageLoopCount = image.bmsd_imageLoopCount;
#else
        // Animated GIF for `NSImage` need to grab `NSBitmapImageRep`;
        NSRect imageRect = NSMakeRect(0, 0, image.size.width, image.size.height);
        NSImageRep *imageRep = [image bestRepresentationForRect:imageRect context:nil hints:nil];
        NSBitmapImageRep *bitmapImageRep;
        if ([imageRep isKindOfClass:[NSBitmapImageRep class]]) {
            bitmapImageRep = (NSBitmapImageRep *)imageRep;
        }
        if (bitmapImageRep) {
            NSSize size = NSMakeSize(image.size.width / scale, image.size.height / scale);
            animatedImage = [[NSImage alloc] initWithSize:size];
            bitmapImageRep.size = size;
            [animatedImage addRepresentation:bitmapImageRep];
        }
#endif
        scaledImage = animatedImage;
    } else {
#if BMSD_UIKIT || BMSD_WATCH
        scaledImage = [[UIImage alloc] initWithCGImage:image.CGImage scale:scale orientation:image.imageOrientation];
#else
        scaledImage = [[UIImage alloc] initWithCGImage:image.CGImage scale:scale orientation:kCGImagePropertyOrientationUp];
#endif
    }
    BMSDImageCopyAssociatedObject(image, scaledImage);
    
    return scaledImage;
}

#pragma mark - Context option

BMSDWebImageContextOption const BMSDWebImageContextSetImageOperationKey = @"setImageOperationKey";
BMSDWebImageContextOption const BMSDWebImageContextCustomManager = @"customManager";
BMSDWebImageContextOption const BMSDWebImageContextImageCache = @"imageCache";
BMSDWebImageContextOption const BMSDWebImageContextImageLoader = @"imageLoader";
BMSDWebImageContextOption const BMSDWebImageContextImageCoder = @"imageCoder";
BMSDWebImageContextOption const BMSDWebImageContextImageTransformer = @"imageTransformer";
BMSDWebImageContextOption const BMSDWebImageContextImageScaleFactor = @"imageScaleFactor";
BMSDWebImageContextOption const BMSDWebImageContextImagePreserveAspectRatio = @"imagePreserveAspectRatio";
BMSDWebImageContextOption const BMSDWebImageContextImageThumbnailPixelSize = @"imageThumbnailPixelSize";
BMSDWebImageContextOption const BMSDWebImageContextQueryCacheType = @"queryCacheType";
BMSDWebImageContextOption const BMSDWebImageContextStoreCacheType = @"storeCacheType";
BMSDWebImageContextOption const BMSDWebImageContextOriginalQueryCacheType = @"originalQueryCacheType";
BMSDWebImageContextOption const BMSDWebImageContextOriginalStoreCacheType = @"originalStoreCacheType";
BMSDWebImageContextOption const BMSDWebImageContextOriginalImageCache = @"originalImageCache";
BMSDWebImageContextOption const BMSDWebImageContextAnimatedImageClass = @"animatedImageClass";
BMSDWebImageContextOption const BMSDWebImageContextDownloadRequestModifier = @"downloadRequestModifier";
BMSDWebImageContextOption const BMSDWebImageContextDownloadResponseModifier = @"downloadResponseModifier";
BMSDWebImageContextOption const BMSDWebImageContextDownloadDecryptor = @"downloadDecryptor";
BMSDWebImageContextOption const BMSDWebImageContextCacheKeyFilter = @"cacheKeyFilter";
BMSDWebImageContextOption const BMSDWebImageContextCacheSerializer = @"cacheSerializer";
