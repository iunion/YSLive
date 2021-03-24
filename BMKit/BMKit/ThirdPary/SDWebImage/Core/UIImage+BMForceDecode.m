/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "UIImage+BMForceDecode.h"
#import "BMSDImageCoderHelper.h"
#import "objc/runtime.h"

@implementation UIImage (BMForceDecode)

- (BOOL)bmsd_isDecoded {
    NSNumber *value = objc_getAssociatedObject(self, @selector(bmsd_isDecoded));
    return value.boolValue;
}

- (void)setBmsd_isDecoded:(BOOL)bmsd_isDecoded {
    objc_setAssociatedObject(self, @selector(bmsd_isDecoded), @(bmsd_isDecoded), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (nullable UIImage *)bmsd_decodedImageWithImage:(nullable UIImage *)image {
    if (!image) {
        return nil;
    }
    return [BMSDImageCoderHelper decodedImageWithImage:image];
}

+ (nullable UIImage *)bmsd_decodedAndScaledDownImageWithImage:(nullable UIImage *)image {
    return [self bmsd_decodedAndScaledDownImageWithImage:image limitBytes:0];
}

+ (nullable UIImage *)bmsd_decodedAndScaledDownImageWithImage:(nullable UIImage *)image limitBytes:(NSUInteger)bytes {
    if (!image) {
        return nil;
    }
    return [BMSDImageCoderHelper decodedAndScaledDownImageWithImage:image limitBytes:bytes];
}

@end
