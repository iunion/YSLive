/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 * (c) Fabrice Aneche
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "NSData+BMImageContentType.h"
#if BMSD_MAC
#import <CoreServices/CoreServices.h>
#else
#import <MobileCoreServices/MobileCoreServices.h>
#endif
#import "BMSDImageIOAnimatedCoderInternal.h"

#define kSVGTagEnd @"</svg>"

@implementation NSData (BMImageContentType)

+ (BMSDImageFormat)bmsd_imageFormatForImageData:(nullable NSData *)data {
    if (!data) {
        return BMSDImageFormatUndefined;
    }
    
    // File signatures table: http://www.garykessler.net/library/file_sigs.html
    uint8_t c;
    [data getBytes:&c length:1];
    switch (c) {
        case 0xFF:
            return BMSDImageFormatJPEG;
        case 0x89:
            return BMSDImageFormatPNG;
        case 0x47:
            return BMSDImageFormatGIF;
        case 0x49:
        case 0x4D:
            return BMSDImageFormatTIFF;
        case 0x52: {
            if (data.length >= 12) {
                //RIFF....WEBP
                NSString *testString = [[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(0, 12)] encoding:NSASCIIStringEncoding];
                if ([testString hasPrefix:@"RIFF"] && [testString hasSuffix:@"WEBP"]) {
                    return BMSDImageFormatWebP;
                }
            }
            break;
        }
        case 0x00: {
            if (data.length >= 12) {
                //....ftypheic ....ftypheix ....ftyphevc ....ftyphevx
                NSString *testString = [[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(4, 8)] encoding:NSASCIIStringEncoding];
                if ([testString isEqualToString:@"ftypheic"]
                    || [testString isEqualToString:@"ftypheix"]
                    || [testString isEqualToString:@"ftyphevc"]
                    || [testString isEqualToString:@"ftyphevx"]) {
                    return BMSDImageFormatHEIC;
                }
                //....ftypmif1 ....ftypmsf1
                if ([testString isEqualToString:@"ftypmif1"] || [testString isEqualToString:@"ftypmsf1"]) {
                    return BMSDImageFormatHEIF;
                }
            }
            break;
        }
        case 0x25: {
            if (data.length >= 4) {
                //%PDF
                NSString *testString = [[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(1, 3)] encoding:NSASCIIStringEncoding];
                if ([testString isEqualToString:@"PDF"]) {
                    return BMSDImageFormatPDF;
                }
            }
        }
        case 0x3C: {
            // Check end with SVG tag
            if ([data rangeOfData:[kSVGTagEnd dataUsingEncoding:NSUTF8StringEncoding] options:NSDataSearchBackwards range: NSMakeRange(data.length - MIN(100, data.length), MIN(100, data.length))].location != NSNotFound) {
                return BMSDImageFormatSVG;
            }
        }
    }
    return BMSDImageFormatUndefined;
}

+ (nonnull CFStringRef)bmsd_UTTypeFromImageFormat:(BMSDImageFormat)format {
    CFStringRef UTType;
    switch (format) {
        case BMSDImageFormatJPEG:
            UTType = kUTTypeJPEG;
            break;
        case BMSDImageFormatPNG:
            UTType = kUTTypePNG;
            break;
        case BMSDImageFormatGIF:
            UTType = kUTTypeGIF;
            break;
        case BMSDImageFormatTIFF:
            UTType = kUTTypeTIFF;
            break;
        case BMSDImageFormatWebP:
            UTType = kBMSDUTTypeWebP;
            break;
        case BMSDImageFormatHEIC:
            UTType = kBMSDUTTypeHEIC;
            break;
        case BMSDImageFormatHEIF:
            UTType = kBMSDUTTypeHEIF;
            break;
        case BMSDImageFormatPDF:
            UTType = kUTTypePDF;
            break;
        case BMSDImageFormatSVG:
            UTType = kUTTypeScalableVectorGraphics;
            break;
        default:
            // default is kUTTypeImage abstract type
            UTType = kUTTypeImage;
            break;
    }
    return UTType;
}

+ (BMSDImageFormat)bmsd_imageFormatFromUTType:(CFStringRef)uttype {
    if (!uttype) {
        return BMSDImageFormatUndefined;
    }
    BMSDImageFormat imageFormat;
    if (CFStringCompare(uttype, kUTTypeJPEG, 0) == kCFCompareEqualTo) {
        imageFormat = BMSDImageFormatJPEG;
    } else if (CFStringCompare(uttype, kUTTypePNG, 0) == kCFCompareEqualTo) {
        imageFormat = BMSDImageFormatPNG;
    } else if (CFStringCompare(uttype, kUTTypeGIF, 0) == kCFCompareEqualTo) {
        imageFormat = BMSDImageFormatGIF;
    } else if (CFStringCompare(uttype, kUTTypeTIFF, 0) == kCFCompareEqualTo) {
        imageFormat = BMSDImageFormatTIFF;
    } else if (CFStringCompare(uttype, kBMSDUTTypeWebP, 0) == kCFCompareEqualTo) {
        imageFormat = BMSDImageFormatWebP;
    } else if (CFStringCompare(uttype, kBMSDUTTypeHEIC, 0) == kCFCompareEqualTo) {
        imageFormat = BMSDImageFormatHEIC;
    } else if (CFStringCompare(uttype, kBMSDUTTypeHEIF, 0) == kCFCompareEqualTo) {
        imageFormat = BMSDImageFormatHEIF;
    } else if (CFStringCompare(uttype, kUTTypePDF, 0) == kCFCompareEqualTo) {
        imageFormat = BMSDImageFormatPDF;
    } else if (CFStringCompare(uttype, kUTTypeScalableVectorGraphics, 0) == kCFCompareEqualTo) {
        imageFormat = BMSDImageFormatSVG;
    } else {
        imageFormat = BMSDImageFormatUndefined;
    }
    return imageFormat;
}

@end
