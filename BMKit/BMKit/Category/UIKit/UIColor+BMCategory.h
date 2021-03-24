//
//  UIColor+BMCategory.h
//  BMBasekit
//
//  Created by DennisDeng on 12-1-11.
//  Copyright (c) 2012年 DennisDeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (BMHex)

/// 以下颜色使用RGB16进制颜色数值字符串标识
/// 前缀支持 0X 0x 中文＃ 英文#
/// 格式支持 #RRGGBB   #AARRGGBB   #RGB ==> #RRGGBB   #ARGB ==> #AARRGGBB
/// # 前缀  R 红色  G 绿色  B 蓝色  A alpha
/// 其中格式#RGB 会被转换为 #RRGGBB 例 #ABC ==> #AABBCC
/// 其中格式#ARGB 会被转换为 #AARRGGBB 例 #0ABC ==> #00AABBCC
/// 透明色指定使用 #0 或 0x0
+ (nullable UIColor *)bm_colorWithHexString:(nullable NSString *)stringToConvert;
+ (nullable UIColor *)bm_colorWithHexString:(nullable NSString *)stringToConvert alpha:(CGFloat)alpha;
+ (nullable UIColor *)bm_colorWithHexString:(nullable NSString *)stringToConvert default:(nullable UIColor *)color;
+ (nullable UIColor *)bm_colorWithHexString:(NSString *)stringToConvert alpha:(CGFloat)alpha default:(nullable UIColor *)color;

/// 格式支持 #RRGGBBAA 及 RGBA(r,b,g,a)，RGBA(r,b,g)
+ (nullable UIColor *)bm_colorWithRGBAHexString:(NSString *)stringToConvert;
+ (nullable UIColor *)bm_colorWithRGBAHexString:(NSString *)stringToConvert alpha:(CGFloat)alpha;
+ (nullable UIColor *)bm_colorWithRGBAHexString:(NSString *)stringToConvert alpha:(CGFloat)alpha default:(nullable UIColor *)color;

+ (UIColor *)bm_colorWithHex:(UInt32)hex;
+ (UIColor *)bm_colorWithHex:(UInt32)hex alpha:(CGFloat)alpha;

+ (NSString *)bm_hexStringFromColor:(UIColor *)color;
+ (NSString *)bm_hexStringFromColor:(UIColor *)color withStartChar:(NSString *)startChar haveAlpha:(BOOL)haveAlpha;
- (NSString *)bm_hexString;
- (NSString *)bm_hexStringWithStartChar:(NSString *)startChar;
- (NSString *)bm_hexStringWithStartChar:(NSString *)startChar haveAlpha:(BOOL)haveAlpha;

- (NSString *)bm_RBGAHexStringWithStartChar:(NSString *)startChar haveAlpha:(BOOL)haveAlpha;
- (NSString *)bm_RBGAHexStringWithStartChar:(NSString *)startChar haveAlpha:(BOOL)haveAlpha isRGBA:(BOOL)isRGBA;

+ (UIColor *)bm_randomColor;
+ (UIColor *)bm_randomColorWithAlpha:(CGFloat)alpha;

// 从startColor过渡到endColor
// progress: 0~1.0
+ (UIColor *)bm_startColor:(UIColor *)startColor endColor:(UIColor *)endColor progress:(CGFloat)progress;
+ (UIColor *)bm_startColorHex:(UInt32)startColor endColorHex:(UInt32)endColor progress:(CGFloat)progress;
+ (UIColor *)bm_startColorHex:(UInt32)startColor endColorHex:(UInt32)endColor startAlpha:(CGFloat)startAlpha endAlpha:(CGFloat)endAlpha progress:(CGFloat)progress;

- (nullable UIColor *)bm_blendWithColor:(UIColor *)color progress:(CGFloat)progress;

@end



@interface UIColor (BMExpanded)
@property (nonatomic, readonly) CGColorSpaceModel bm_colorSpaceModel;
@property (nonatomic, readonly) BOOL bm_canProvideRGBComponents;

// With the exception of -alpha, these properties will function
// correctly only if this color is an RGB or white color.
// In these cases, canProvideRGBComponents returns YES.
@property (nonatomic, readonly) CGFloat bm_red;
@property (nonatomic, readonly) CGFloat bm_green;
@property (nonatomic, readonly) CGFloat bm_blue;
@property (nonatomic, readonly) CGFloat bm_white;
@property (nonatomic, readonly) CGFloat bm_hue;
@property (nonatomic, readonly) CGFloat bm_saturation;
@property (nonatomic, readonly) CGFloat bm_brightness;
@property (nonatomic, readonly) CGFloat bm_alpha;
@property (nonatomic, readonly) CGFloat bm_luminance;
@property (nonatomic, readonly) UInt32 bm_rgbHex;
@property (nonatomic, readonly) UInt32 bm_argbHex;
@property (nonatomic, readonly) UInt32 bm_rgbaHex;

- (UIColor *)bm_changeAlpha:(CGFloat)alpha;

- (BOOL)bm_isLighterColor;
- (nullable UIColor *)bm_lighterColor;
- (nullable UIColor *)bm_darkerColor;

- (NSString *)bm_colorSpaceString;
- (nullable NSArray *)bm_arrayFromRGBAComponents;

// Bulk access to RGB and HSB components of the color
// HSB components are converted from the RGB components
- (BOOL)bm_red:(nullable CGFloat *)r green:(nullable CGFloat *)g blue:(nullable CGFloat *)b alpha:(nullable CGFloat *)a;
- (BOOL)bm_hue:(nullable CGFloat *)h saturation:(nullable CGFloat *)s brightness:(nullable CGFloat *)b alpha:(nullable CGFloat *)a;

// Return a grey-scale representation of the color
- (UIColor *)bm_colorByLuminanceMapping;

// Arithmetic operations on the color
- (nullable UIColor *)bm_colorByMultiplyingByRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha;
- (nullable UIColor *)bm_colorByAddingRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha;
- (nullable UIColor *)bm_colorByLighteningToRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha;
- (nullable UIColor *)bm_colorByDarkeningToRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha;

- (nullable UIColor *)bm_colorByMultiplyingBy:(CGFloat)f;
- (nullable UIColor *)bm_colorByAdding:(CGFloat)f;
- (nullable UIColor *)bm_colorByLighteningTo:(CGFloat)f;
- (nullable UIColor *)bm_colorByDarkeningTo:(CGFloat)f;

- (nullable UIColor *)bm_colorByMultiplyingByColor:(UIColor *)color;
- (nullable UIColor *)bm_colorByAddingColor:(UIColor *)color;
- (nullable UIColor *)bm_colorByLighteningToColor:(UIColor *)color;
- (nullable UIColor *)bm_colorByDarkeningToColor:(UIColor *)color;

// Related colors
- (UIColor *)bm_contrastingColor; // A good contrasting color: will be either black or white
- (nullable UIColor *)bm_complementaryColor; // A complementary color that should look good with this color
- (nullable UIColor *)bm_disableColor;
- (UIColor *)bm_inverseColor;
- (nullable NSArray*)bm_triadicColors; // Two colors that should look good with this color
- (nullable NSArray*)bm_analogousColorsWithStepAngle:(CGFloat)stepAngle pairCount:(int)pairs; // Multiple pairs of colors

// String representations of the color
- (nullable NSString *)bm_stringFromColor;

// Low level conversions between RGB and HSL spaces
+ (void)bm_hue:(CGFloat)h saturation:(CGFloat)s brightness:(CGFloat)v toRed:(CGFloat *)r green:(CGFloat *)g blue:(CGFloat *)b;
+ (void)bm_red:(CGFloat)r green:(CGFloat)g blue:(CGFloat)b toHue:(CGFloat *)h saturation:(CGFloat *)s brightness:(CGFloat *)v;

@end

@interface UIColor (ImagePoint)

+ (UIColor *)bm_colorFromImage:(UIImage *)image atPoint:(CGPoint)point;

@end

NS_ASSUME_NONNULL_END
