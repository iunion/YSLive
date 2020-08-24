/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "UIImage+BMMetadata.h"
#import "NSImage+BMCompatibility.h"
#import "BMSDInternalMacros.h"
#import "objc/runtime.h"

@implementation UIImage (BMMetadata)

#if BMSD_UIKIT || BMSD_WATCH

- (NSUInteger)bmsd_imageLoopCount {
    NSUInteger imageLoopCount = 0;
    NSNumber *value = objc_getAssociatedObject(self, @selector(bmsd_imageLoopCount));
    if ([value isKindOfClass:[NSNumber class]]) {
        imageLoopCount = value.unsignedIntegerValue;
    }
    return imageLoopCount;
}

- (void)setBmsd_imageLoopCount:(NSUInteger)bmsd_imageLoopCount {
    NSNumber *value = @(bmsd_imageLoopCount);
    objc_setAssociatedObject(self, @selector(bmsd_imageLoopCount), value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)bmsd_isAnimated {
    return (self.images != nil);
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
- (BOOL)bmsd_isVector {
    if (@available(iOS 13.0, tvOS 13.0, watchOS 6.0, *)) {
        // Xcode 11 supports symbol image, keep Xcode 10 compatible currently
        SEL SymbolSelector = NSSelectorFromString(@"isSymbolImage");
        if ([self respondsToSelector:SymbolSelector] && [self performSelector:SymbolSelector]) {
            return YES;
        }
        // SVG
        SEL SVGSelector = BMSD_SEL_SPI(CGSVGDocument);
        if ([self respondsToSelector:SVGSelector] && [self performSelector:SVGSelector]) {
            return YES;
        }
    }
    if (@available(iOS 11.0, tvOS 11.0, watchOS 4.0, *)) {
        // PDF
        SEL PDFSelector = BMSD_SEL_SPI(CGPDFPage);
        if ([self respondsToSelector:PDFSelector] && [self performSelector:PDFSelector]) {
            return YES;
        }
    }
    return NO;
}
#pragma clang diagnostic pop

#else

- (NSUInteger)bmsd_imageLoopCount {
    NSUInteger imageLoopCount = 0;
    NSRect imageRect = NSMakeRect(0, 0, self.size.width, self.size.height);
    NSImageRep *imageRep = [self bestRepresentationForRect:imageRect context:nil hints:nil];
    NSBitmapImageRep *bitmapImageRep;
    if ([imageRep isKindOfClass:[NSBitmapImageRep class]]) {
        bitmapImageRep = (NSBitmapImageRep *)imageRep;
    }
    if (bitmapImageRep) {
        imageLoopCount = [[bitmapImageRep valueForProperty:NSImageLoopCount] unsignedIntegerValue];
    }
    return imageLoopCount;
}

- (void)setBmsd_imageLoopCount:(NSUInteger)bmsd_imageLoopCount {
    NSRect imageRect = NSMakeRect(0, 0, self.size.width, self.size.height);
    NSImageRep *imageRep = [self bestRepresentationForRect:imageRect context:nil hints:nil];
    NSBitmapImageRep *bitmapImageRep;
    if ([imageRep isKindOfClass:[NSBitmapImageRep class]]) {
        bitmapImageRep = (NSBitmapImageRep *)imageRep;
    }
    if (bitmapImageRep) {
        [bitmapImageRep setProperty:NSImageLoopCount withValue:@(bmsd_imageLoopCount)];
    }
}

- (BOOL)bmsd_isAnimated {
    BOOL isAnimated = NO;
    NSRect imageRect = NSMakeRect(0, 0, self.size.width, self.size.height);
    NSImageRep *imageRep = [self bestRepresentationForRect:imageRect context:nil hints:nil];
    NSBitmapImageRep *bitmapImageRep;
    if ([imageRep isKindOfClass:[NSBitmapImageRep class]]) {
        bitmapImageRep = (NSBitmapImageRep *)imageRep;
    }
    if (bitmapImageRep) {
        NSUInteger frameCount = [[bitmapImageRep valueForProperty:NSImageFrameCount] unsignedIntegerValue];
        isAnimated = frameCount > 1 ? YES : NO;
    }
    return isAnimated;
}

- (BOOL)bmsd_isVector {
    NSRect imageRect = NSMakeRect(0, 0, self.size.width, self.size.height);
    NSImageRep *imageRep = [self bestRepresentationForRect:imageRect context:nil hints:nil];
    if ([imageRep isKindOfClass:[NSPDFImageRep class]]) {
        return YES;
    }
    if ([imageRep isKindOfClass:[NSEPSImageRep class]]) {
        return YES;
    }
    if ([NSStringFromClass(imageRep.class) hasSuffix:@"NSSVGImageRep"]) {
        return YES;
    }
    return NO;
}

#endif

- (BMSDImageFormat)bmsd_imageFormat {
    BMSDImageFormat imageFormat = BMSDImageFormatUndefined;
    NSNumber *value = objc_getAssociatedObject(self, @selector(bmsd_imageFormat));
    if ([value isKindOfClass:[NSNumber class]]) {
        imageFormat = value.integerValue;
        return imageFormat;
    }
    // Check CGImage's UTType, may return nil for non-Image/IO based image
    if (@available(iOS 9.0, tvOS 9.0, macOS 10.11, watchOS 2.0, *)) {
        CFStringRef uttype = CGImageGetUTType(self.CGImage);
        imageFormat = [NSData bmsd_imageFormatFromUTType:uttype];
    }
    return imageFormat;
}

- (void)setBmsd_imageFormat:(BMSDImageFormat)bmsd_imageFormat {
    objc_setAssociatedObject(self, @selector(bmsd_imageFormat), @(bmsd_imageFormat), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setBmsd_isIncremental:(BOOL)bmsd_isIncremental {
    objc_setAssociatedObject(self, @selector(bmsd_isIncremental), @(bmsd_isIncremental), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)bmsd_isIncremental {
    NSNumber *value = objc_getAssociatedObject(self, @selector(bmsd_isIncremental));
    return value.boolValue;
}

@end
