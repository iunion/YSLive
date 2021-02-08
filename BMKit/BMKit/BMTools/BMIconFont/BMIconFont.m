//
//  BMIconFont.m
//  BMKit
//
//  Created by jiang deng on 2021/2/8.
//  Copyright © 2021 DennisDeng. All rights reserved.
//

#import "BMIconFont.h"
#import <CoreText/CoreText.h>

@interface BMIconFont ()

@property (nonatomic, strong) NSString *fontName;

@end


@implementation BMIconFont

+ (NSString *)registerFontWithFontFileName:(NSString *)fontFileName
{
    return [BMIconFont registerFontWithFontFileName:fontFileName extension:@"ttf"];
}

+ (NSString *)registerFontWithFontFileName:(NSString *)fontFileName extension:(NSString *)extension
{
    UIFont *font = [UIFont fontWithName:fontFileName size:10.0f];
    if (font != nil)
    {
        return fontFileName;
    }

    NSURL *fontFileUrl = [[NSBundle mainBundle] URLForResource:fontFileName withExtension:extension];
    return [BMIconFont registerFontWithURL:fontFileUrl];
}

+ (NSString *)registerFontWithURL:(NSURL *)url
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:[url path]])
    {
        NSLog(@"Font file doesn't exist");
        
        return nil;
    }
    
    CGDataProviderRef fontDataProvider = CGDataProviderCreateWithURL((__bridge CFURLRef)url);
    CGFontRef newFontRef = CGFontCreateWithDataProvider(fontDataProvider);
    CGDataProviderRelease(fontDataProvider);
    CTFontManagerRegisterGraphicsFont(newFontRef, nil);
    NSString *fontName = CFBridgingRelease(CGFontCopyPostScriptName(newFontRef));
    CGFontRelease(newFontRef);
    
    return fontName;
}

- (instancetype)initWithFontFileName:(NSString *)fontFileName
{
    return [self initWithFontFileName:fontFileName extension:@"ttf"];
}

- (instancetype)initWithFontFileName:(NSString *)fontFileName extension:(NSString *)extension
{
    self = [super init];
    if (self)
    {
        NSString *fontName = [BMIconFont registerFontWithFontFileName:fontFileName extension:extension];
        UIFont *font = [UIFont fontWithName:fontName size:10.0f];
        if (font)
        {
            self.fontName = fontName;
        }
    }
    
    return self;
}

- (UIFont *)fontWithSize:(CGFloat)size
{
    NSAssert(self.fontName, @"UIFont object should not be nil, check if the font file is added to the application bundle and you're using the correct font name.");

    UIFont *font = [UIFont fontWithName:self.fontName size:size];
    return font;
}

// [self iconWithText:@"\U0000e601" color:UIColor.blueColor size:30.0f];
- (UIImage *)iconWithText:(NSString *)text color:(UIColor *)color size:(CGFloat)size
{
    NSAssert(self.fontName, @"UIFont object should not be nil, check if the font file is added to the application bundle and you're using the correct font name.");

    if (!color)
    {
        color = UIColor.blackColor;
    }
    
    CGFloat scale = [UIScreen mainScreen].scale;
    CGFloat realSize = size * scale;
    UIFont *font = [self fontWithSize:realSize];
    UIGraphicsBeginImageContext(CGSizeMake(realSize, realSize));
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if ([text respondsToSelector:@selector(drawAtPoint:withAttributes:)])
    {
        /**
         * 如果这里抛出异常，请打开断点列表，右击All Exceptions -> Edit Breakpoint -> All修改为Objective-C
         * See: http://stackoverflow.com/questions/1163981/how-to-add-a-breakpoint-to-objc-exception-throw/14767076#14767076
         */
        [text drawAtPoint:CGPointZero withAttributes:@{NSFontAttributeName:font, NSForegroundColorAttributeName:color}];
    }
    else
    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        CGContextSetFillColorWithColor(context, color.CGColor);
        [text drawAtPoint:CGPointMake(0, 0) withFont:font];
#pragma clang pop
    }
    
    UIImage *image = [UIImage imageWithCGImage:UIGraphicsGetImageFromCurrentImageContext().CGImage scale:scale orientation:UIImageOrientationUp];
    UIGraphicsEndImageContext();
    
    return image;
}

@end
