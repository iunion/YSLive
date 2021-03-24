/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "UIImage+BMMultiFormat.h"
#import "BMSDImageCodersManager.h"

@implementation UIImage (BMMultiFormat)

+ (nullable UIImage *)bmsd_imageWithData:(nullable NSData *)data {
    return [self bmsd_imageWithData:data scale:1];
}

+ (nullable UIImage *)bmsd_imageWithData:(nullable NSData *)data scale:(CGFloat)scale {
    return [self bmsd_imageWithData:data scale:scale firstFrameOnly:NO];
}

+ (nullable UIImage *)bmsd_imageWithData:(nullable NSData *)data scale:(CGFloat)scale firstFrameOnly:(BOOL)firstFrameOnly {
    if (!data) {
        return nil;
    }
    BMSDImageCoderOptions *options = @{BMSDImageCoderDecodeScaleFactor : @(MAX(scale, 1)), BMSDImageCoderDecodeFirstFrameOnly : @(firstFrameOnly)};
    return [[BMSDImageCodersManager sharedManager] decodedImageWithData:data options:options];
}

- (nullable NSData *)bmsd_imageData {
    return [self bmsd_imageDataAsFormat:BMSDImageFormatUndefined];
}

- (nullable NSData *)bmsd_imageDataAsFormat:(BMSDImageFormat)imageFormat {
    return [self bmsd_imageDataAsFormat:imageFormat compressionQuality:1];
}

- (nullable NSData *)bmsd_imageDataAsFormat:(BMSDImageFormat)imageFormat compressionQuality:(double)compressionQuality {
    return [self bmsd_imageDataAsFormat:imageFormat compressionQuality:compressionQuality firstFrameOnly:NO];
}

- (nullable NSData *)bmsd_imageDataAsFormat:(BMSDImageFormat)imageFormat compressionQuality:(double)compressionQuality firstFrameOnly:(BOOL)firstFrameOnly {
    BMSDImageCoderOptions *options = @{BMSDImageCoderEncodeCompressionQuality : @(compressionQuality), BMSDImageCoderEncodeFirstFrameOnly : @(firstFrameOnly)};
    return [[BMSDImageCodersManager sharedManager] encodedDataWithImage:self format:imageFormat options:options];
}

@end
