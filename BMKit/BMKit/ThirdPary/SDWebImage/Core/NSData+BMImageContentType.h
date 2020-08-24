/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 * (c) Fabrice Aneche
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import <Foundation/Foundation.h>
#import "BMSDWebImageCompat.h"

/**
 You can use switch case like normal enum. It's also recommended to add a default case. You should not assume anything about the raw value.
 For custom coder plugin, it can also extern the enum for supported format. See `SDImageCoder` for more detailed information.
 */
typedef NSInteger BMSDImageFormat NS_TYPED_EXTENSIBLE_ENUM;
static const BMSDImageFormat BMSDImageFormatUndefined = -1;
static const BMSDImageFormat BMSDImageFormatJPEG      = 0;
static const BMSDImageFormat BMSDImageFormatPNG       = 1;
static const BMSDImageFormat BMSDImageFormatGIF       = 2;
static const BMSDImageFormat BMSDImageFormatTIFF      = 3;
static const BMSDImageFormat BMSDImageFormatWebP      = 4;
static const BMSDImageFormat BMSDImageFormatHEIC      = 5;
static const BMSDImageFormat BMSDImageFormatHEIF      = 6;
static const BMSDImageFormat BMSDImageFormatPDF       = 7;
static const BMSDImageFormat BMSDImageFormatSVG       = 8;

/**
 NSData category about the image content type and UTI.
 */
@interface NSData (BMImageContentType)

/**
 *  Return image format
 *
 *  @param data the input image data
 *
 *  @return the image format as `SDImageFormat` (enum)
 */
+ (BMSDImageFormat)bmsd_imageFormatForImageData:(nullable NSData *)data;

/**
 *  Convert SDImageFormat to UTType
 *
 *  @param format Format as SDImageFormat
 *  @return The UTType as CFStringRef
 *  @note For unknown format, `kUTTypeImage` abstract type will return
 */
+ (nonnull CFStringRef)bmsd_UTTypeFromImageFormat:(BMSDImageFormat)format CF_RETURNS_NOT_RETAINED NS_SWIFT_NAME(sd_UTType(from:));

/**
 *  Convert UTType to SDImageFormat
 *
 *  @param uttype The UTType as CFStringRef
 *  @return The Format as SDImageFormat
 *  @note For unknown type, `SDImageFormatUndefined` will return
 */
+ (BMSDImageFormat)bmsd_imageFormatFromUTType:(nonnull CFStringRef)uttype;

@end
