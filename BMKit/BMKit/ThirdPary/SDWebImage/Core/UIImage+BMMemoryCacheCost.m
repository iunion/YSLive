/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "UIImage+BMMemoryCacheCost.h"
#import "objc/runtime.h"
#import "NSImage+BMCompatibility.h"

FOUNDATION_STATIC_INLINE NSUInteger BMSDMemoryCacheCostForImage(UIImage *image) {
    CGImageRef imageRef = image.CGImage;
    if (!imageRef) {
        return 0;
    }
    NSUInteger bytesPerFrame = CGImageGetBytesPerRow(imageRef) * CGImageGetHeight(imageRef);
    NSUInteger frameCount;
#if BMSD_MAC
    frameCount = 1;
#elif BMSD_UIKIT || BMSD_WATCH
    // Filter the same frame in `_UIAnimatedImage`.
    frameCount = image.images.count > 0 ? [NSSet setWithArray:image.images].count : 1;
#endif
    NSUInteger cost = bytesPerFrame * frameCount;
    return cost;
}

@implementation UIImage (BMMemoryCacheCost)

- (NSUInteger)bmsd_memoryCost {
    NSNumber *value = objc_getAssociatedObject(self, @selector(bmsd_memoryCost));
    NSUInteger memoryCost;
    if (value != nil) {
        memoryCost = [value unsignedIntegerValue];
    } else {
        memoryCost = BMSDMemoryCacheCostForImage(self);
    }
    return memoryCost;
}

- (void)setBmsd_memoryCost:(NSUInteger)bmsd_memoryCost {
    objc_setAssociatedObject(self, @selector(bmsd_memoryCost), @(bmsd_memoryCost), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
