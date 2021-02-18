//
//  BMIconFont.h
//  BMKit
//
//  Created by jiang deng on 2021/2/8.
//  Copyright © 2021 DennisDeng. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BMIconFont : NSObject

/// 注册字体
+ (nullable NSString *)registerFontWithFontFileName:(NSString *)fontFileName;
+ (nullable NSString *)registerFontWithFontFileName:(NSString *)fontFileName extension:(NSString *)extension;
+ (nullable NSString *)registerFontWithURL:(NSURL *)url;

@property (nonatomic, strong, readonly) NSString *fontName;

/// 设置字体
- (instancetype)initWithFontFileName:(NSString *)fontFileName;
- (instancetype)initWithFontFileName:(NSString *)fontFileName extension:(NSString *)extension;

/// 获取字体，使用前请先确认fontName不为nil
- (UIFont *)fontWithSize:(CGFloat)size;
/// 获取Icon图片，使用前请先确认fontName不为nil
- (UIImage *)iconWithText:(NSString *)text color:(UIColor *)color size:(CGFloat)size;

@end

NS_ASSUME_NONNULL_END
