/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "BMSDImageTransformer.h"
#import "UIColor+BMSDHexString.h"
#if BMSD_UIKIT || BMSD_MAC
#import <CoreImage/CoreImage.h>
#endif

// Separator for different transformerKey, for example, `image.png` |> flip(YES,NO) |> rotate(pi/4,YES) => 'image-SDImageFlippingTransformer(1,0)-SDImageRotationTransformer(0.78539816339,1).png'
static NSString * const BMSDImageTransformerKeySeparator = @"-";

NSString * _Nullable BMSDTransformedKeyForKey(NSString * _Nullable key, NSString * _Nonnull transformerKey) {
    if (!key || !transformerKey) {
        return nil;
    }
    // Find the file extension
    NSURL *keyURL = [NSURL URLWithString:key];
    NSString *ext = keyURL ? keyURL.pathExtension : key.pathExtension;
    if (ext.length > 0) {
        // For non-file URL
        if (keyURL && !keyURL.isFileURL) {
            // keep anything except path (like URL query)
            NSURLComponents *component = [NSURLComponents componentsWithURL:keyURL resolvingAgainstBaseURL:NO];
            component.path = [[[component.path.stringByDeletingPathExtension stringByAppendingString:BMSDImageTransformerKeySeparator] stringByAppendingString:transformerKey] stringByAppendingPathExtension:ext];
            return component.URL.absoluteString;
        } else {
            // file URL
            return [[[key.stringByDeletingPathExtension stringByAppendingString:BMSDImageTransformerKeySeparator] stringByAppendingString:transformerKey] stringByAppendingPathExtension:ext];
        }
    } else {
        return [[key stringByAppendingString:BMSDImageTransformerKeySeparator] stringByAppendingString:transformerKey];
    }
}

NSString * _Nullable BMSDThumbnailedKeyForKey(NSString * _Nullable key, CGSize thumbnailPixelSize, BOOL preserveAspectRatio) {
    NSString *thumbnailKey = [NSString stringWithFormat:@"Thumbnail({%f,%f},%d)", thumbnailPixelSize.width, thumbnailPixelSize.height, preserveAspectRatio];
    return BMSDTransformedKeyForKey(key, thumbnailKey);
}

@interface BMSDImagePipelineTransformer ()

@property (nonatomic, copy, readwrite, nonnull) NSArray<id<BMSDImageTransformer>> *transformers;
@property (nonatomic, copy, readwrite) NSString *transformerKey;

@end

@implementation BMSDImagePipelineTransformer

+ (instancetype)transformerWithTransformers:(NSArray<id<BMSDImageTransformer>> *)transformers {
    BMSDImagePipelineTransformer *transformer = [BMSDImagePipelineTransformer new];
    transformer.transformers = transformers;
    transformer.transformerKey = [[self class] cacheKeyForTransformers:transformers];
    
    return transformer;
}

+ (NSString *)cacheKeyForTransformers:(NSArray<id<BMSDImageTransformer>> *)transformers {
    if (transformers.count == 0) {
        return @"";
    }
    NSMutableArray<NSString *> *cacheKeys = [NSMutableArray arrayWithCapacity:transformers.count];
    [transformers enumerateObjectsUsingBlock:^(id<BMSDImageTransformer>  _Nonnull transformer, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *cacheKey = transformer.transformerKey;
        [cacheKeys addObject:cacheKey];
    }];
    
    return [cacheKeys componentsJoinedByString:BMSDImageTransformerKeySeparator];
}

- (UIImage *)transformedImageWithImage:(UIImage *)image forKey:(NSString *)key {
    if (!image) {
        return nil;
    }
    UIImage *transformedImage = image;
    for (id<BMSDImageTransformer> transformer in self.transformers) {
        transformedImage = [transformer transformedImageWithImage:transformedImage forKey:key];
    }
    return transformedImage;
}

@end

@interface BMSDImageRoundCornerTransformer ()

@property (nonatomic, assign) CGFloat cornerRadius;
@property (nonatomic, assign) BMSDRectCorner corners;
@property (nonatomic, assign) CGFloat borderWidth;
@property (nonatomic, strong, nullable) UIColor *borderColor;

@end

@implementation BMSDImageRoundCornerTransformer

+ (instancetype)transformerWithRadius:(CGFloat)cornerRadius corners:(BMSDRectCorner)corners borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor {
    BMSDImageRoundCornerTransformer *transformer = [BMSDImageRoundCornerTransformer new];
    transformer.cornerRadius = cornerRadius;
    transformer.corners = corners;
    transformer.borderWidth = borderWidth;
    transformer.borderColor = borderColor;
    
    return transformer;
}

- (NSString *)transformerKey {
    return [NSString stringWithFormat:@"BMSDImageRoundCornerTransformer(%f,%lu,%f,%@)", self.cornerRadius, (unsigned long)self.corners, self.borderWidth, self.borderColor.bmsd_hexString];
}

- (UIImage *)transformedImageWithImage:(UIImage *)image forKey:(NSString *)key {
    if (!image) {
        return nil;
    }
    return [image bmsd_roundedCornerImageWithRadius:self.cornerRadius corners:self.corners borderWidth:self.borderWidth borderColor:self.borderColor];
}

@end

@interface BMSDImageResizingTransformer ()

@property (nonatomic, assign) CGSize size;
@property (nonatomic, assign) BMSDImageScaleMode scaleMode;

@end

@implementation BMSDImageResizingTransformer

+ (instancetype)transformerWithSize:(CGSize)size scaleMode:(BMSDImageScaleMode)scaleMode {
    BMSDImageResizingTransformer *transformer = [BMSDImageResizingTransformer new];
    transformer.size = size;
    transformer.scaleMode = scaleMode;
    
    return transformer;
}

- (NSString *)transformerKey {
    CGSize size = self.size;
    return [NSString stringWithFormat:@"BMSDImageResizingTransformer({%f,%f},%lu)", size.width, size.height, (unsigned long)self.scaleMode];
}

- (UIImage *)transformedImageWithImage:(UIImage *)image forKey:(NSString *)key {
    if (!image) {
        return nil;
    }
    return [image bmsd_resizedImageWithSize:self.size scaleMode:self.scaleMode];
}

@end

@interface BMSDImageCroppingTransformer ()

@property (nonatomic, assign) CGRect rect;

@end

@implementation BMSDImageCroppingTransformer

+ (instancetype)transformerWithRect:(CGRect)rect {
    BMSDImageCroppingTransformer *transformer = [BMSDImageCroppingTransformer new];
    transformer.rect = rect;
    
    return transformer;
}

- (NSString *)transformerKey {
    CGRect rect = self.rect;
    return [NSString stringWithFormat:@"BMSDImageCroppingTransformer({%f,%f,%f,%f})", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height];
}

- (UIImage *)transformedImageWithImage:(UIImage *)image forKey:(NSString *)key {
    if (!image) {
        return nil;
    }
    return [image bmsd_croppedImageWithRect:self.rect];
}

@end

@interface BMSDImageFlippingTransformer ()

@property (nonatomic, assign) BOOL horizontal;
@property (nonatomic, assign) BOOL vertical;

@end

@implementation BMSDImageFlippingTransformer

+ (instancetype)transformerWithHorizontal:(BOOL)horizontal vertical:(BOOL)vertical {
    BMSDImageFlippingTransformer *transformer = [BMSDImageFlippingTransformer new];
    transformer.horizontal = horizontal;
    transformer.vertical = vertical;
    
    return transformer;
}

- (NSString *)transformerKey {
    return [NSString stringWithFormat:@"BMSDImageFlippingTransformer(%d,%d)", self.horizontal, self.vertical];
}

- (UIImage *)transformedImageWithImage:(UIImage *)image forKey:(NSString *)key {
    if (!image) {
        return nil;
    }
    return [image bmsd_flippedImageWithHorizontal:self.horizontal vertical:self.vertical];
}

@end

@interface BMSDImageRotationTransformer ()

@property (nonatomic, assign) CGFloat angle;
@property (nonatomic, assign) BOOL fitSize;

@end

@implementation BMSDImageRotationTransformer

+ (instancetype)transformerWithAngle:(CGFloat)angle fitSize:(BOOL)fitSize {
    BMSDImageRotationTransformer *transformer = [BMSDImageRotationTransformer new];
    transformer.angle = angle;
    transformer.fitSize = fitSize;
    
    return transformer;
}

- (NSString *)transformerKey {
    return [NSString stringWithFormat:@"BMSDImageRotationTransformer(%f,%d)", self.angle, self.fitSize];
}

- (UIImage *)transformedImageWithImage:(UIImage *)image forKey:(NSString *)key {
    if (!image) {
        return nil;
    }
    return [image bmsd_rotatedImageWithAngle:self.angle fitSize:self.fitSize];
}

@end

#pragma mark - Image Blending

@interface BMSDImageTintTransformer ()

@property (nonatomic, strong, nonnull) UIColor *tintColor;

@end

@implementation BMSDImageTintTransformer

+ (instancetype)transformerWithColor:(UIColor *)tintColor {
    BMSDImageTintTransformer *transformer = [BMSDImageTintTransformer new];
    transformer.tintColor = tintColor;
    
    return transformer;
}

- (NSString *)transformerKey {
    return [NSString stringWithFormat:@"BMSDImageTintTransformer(%@)", self.tintColor.bmsd_hexString];
}

- (UIImage *)transformedImageWithImage:(UIImage *)image forKey:(NSString *)key {
    if (!image) {
        return nil;
    }
    return [image bmsd_tintedImageWithColor:self.tintColor];
}

@end

#pragma mark - Image Effect

@interface BMSDImageBlurTransformer ()

@property (nonatomic, assign) CGFloat blurRadius;

@end

@implementation BMSDImageBlurTransformer

+ (instancetype)transformerWithRadius:(CGFloat)blurRadius {
    BMSDImageBlurTransformer *transformer = [BMSDImageBlurTransformer new];
    transformer.blurRadius = blurRadius;
    
    return transformer;
}

- (NSString *)transformerKey {
    return [NSString stringWithFormat:@"BMSDImageBlurTransformer(%f)", self.blurRadius];
}

- (UIImage *)transformedImageWithImage:(UIImage *)image forKey:(NSString *)key {
    if (!image) {
        return nil;
    }
    return [image bmsd_blurredImageWithRadius:self.blurRadius];
}

@end

#if BMSD_UIKIT || BMSD_MAC
@interface BMSDImageFilterTransformer ()

@property (nonatomic, strong, nonnull) CIFilter *filter;

@end

@implementation BMSDImageFilterTransformer

+ (instancetype)transformerWithFilter:(CIFilter *)filter {
    BMSDImageFilterTransformer *transformer = [BMSDImageFilterTransformer new];
    transformer.filter = filter;
    
    return transformer;
}

- (NSString *)transformerKey {
    return [NSString stringWithFormat:@"BMSDImageFilterTransformer(%@)", self.filter.name];
}

- (UIImage *)transformedImageWithImage:(UIImage *)image forKey:(NSString *)key {
    if (!image) {
        return nil;
    }
    return [image bmsd_filteredImageWithFilter:self.filter];
}

@end
#endif
