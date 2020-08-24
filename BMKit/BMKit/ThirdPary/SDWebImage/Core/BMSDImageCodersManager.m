/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "BMSDImageCodersManager.h"
#import "BMSDImageIOCoder.h"
#import "BMSDImageGIFCoder.h"
#import "BMSDImageAPNGCoder.h"
#import "BMSDImageHEICCoder.h"
#import "BMSDInternalMacros.h"

@interface BMSDImageCodersManager ()

@property (nonatomic, strong, nonnull) dispatch_semaphore_t codersLock;

@end

@implementation BMSDImageCodersManager
{
    NSMutableArray<id<BMSDImageCoder>> *_imageCoders;
}

+ (nonnull instancetype)sharedManager {
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [self new];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        // initialize with default coders
        _imageCoders = [NSMutableArray arrayWithArray:@[[BMSDImageIOCoder sharedCoder], [BMSDImageGIFCoder sharedCoder], [BMSDImageAPNGCoder sharedCoder]]];
        _codersLock = dispatch_semaphore_create(1);
    }
    return self;
}

- (NSArray<id<BMSDImageCoder>> *)coders
{
    BMSD_LOCK(self.codersLock);
    NSArray<id<BMSDImageCoder>> *coders = [_imageCoders copy];
    BMSD_UNLOCK(self.codersLock);
    return coders;
}

- (void)setCoders:(NSArray<id<BMSDImageCoder>> *)coders
{
    BMSD_LOCK(self.codersLock);
    [_imageCoders removeAllObjects];
    if (coders.count) {
        [_imageCoders addObjectsFromArray:coders];
    }
    BMSD_UNLOCK(self.codersLock);
}

#pragma mark - Coder IO operations

- (void)addCoder:(nonnull id<BMSDImageCoder>)coder {
    if (![coder conformsToProtocol:@protocol(BMSDImageCoder)]) {
        return;
    }
    BMSD_LOCK(self.codersLock);
    [_imageCoders addObject:coder];
    BMSD_UNLOCK(self.codersLock);
}

- (void)removeCoder:(nonnull id<BMSDImageCoder>)coder {
    if (![coder conformsToProtocol:@protocol(BMSDImageCoder)]) {
        return;
    }
    BMSD_LOCK(self.codersLock);
    [_imageCoders removeObject:coder];
    BMSD_UNLOCK(self.codersLock);
}

#pragma mark - SDImageCoder
- (BOOL)canDecodeFromData:(NSData *)data {
    NSArray<id<BMSDImageCoder>> *coders = self.coders;
    for (id<BMSDImageCoder> coder in coders.reverseObjectEnumerator) {
        if ([coder canDecodeFromData:data]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)canEncodeToFormat:(BMSDImageFormat)format {
    NSArray<id<BMSDImageCoder>> *coders = self.coders;
    for (id<BMSDImageCoder> coder in coders.reverseObjectEnumerator) {
        if ([coder canEncodeToFormat:format]) {
            return YES;
        }
    }
    return NO;
}

- (UIImage *)decodedImageWithData:(NSData *)data options:(nullable BMSDImageCoderOptions *)options {
    if (!data) {
        return nil;
    }
    UIImage *image;
    NSArray<id<BMSDImageCoder>> *coders = self.coders;
    for (id<BMSDImageCoder> coder in coders.reverseObjectEnumerator) {
        if ([coder canDecodeFromData:data]) {
            image = [coder decodedImageWithData:data options:options];
            break;
        }
    }
    
    return image;
}

- (NSData *)encodedDataWithImage:(UIImage *)image format:(BMSDImageFormat)format options:(nullable BMSDImageCoderOptions *)options {
    if (!image) {
        return nil;
    }
    NSArray<id<BMSDImageCoder>> *coders = self.coders;
    for (id<BMSDImageCoder> coder in coders.reverseObjectEnumerator) {
        if ([coder canEncodeToFormat:format]) {
            return [coder encodedDataWithImage:image format:format options:options];
        }
    }
    return nil;
}

@end
