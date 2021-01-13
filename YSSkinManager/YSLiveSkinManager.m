//
//  YSSkinManager.m
//  YSAll
//
//  Created by 马迪 on 2020/5/25.
//  Copyright © 2020 YS. All rights reserved.
//

#import "YSLiveSkinManager.h"

static YSLiveSkinManager *skinManager = nil;

//#define YSSkinBundleName    (self.classOrOnline == CHSkinClassOrOnline_class)?@"YSSkinRsource.bundle": @"YSOnlineSchool.bundle"
//#define YSSkinBundle        [NSBundle bundleWithPath:[[NSBundle bm_mainResourcePath] stringByAppendingPathComponent:YSSkinBundleName]]

@interface YSLiveSkinManager ()

@property (nonatomic, assign) CHSkinDetailsType lastSkinType;

@property (nonatomic, assign) CHSkinClassOrOnline lastClassOrOnline;

@property (nonatomic, strong) NSDictionary *plictDict;

@end

@implementation YSLiveSkinManager

+ (instancetype)shareInstance
{
    @synchronized(self)
    {
        if (!skinManager)
        {
            skinManager = [[YSLiveSkinManager alloc] init];

            skinManager.roomDetailsType = CHSkinDetailsType_dark;
        }
    }
    return skinManager;
}

///当前调用的皮肤bundle
//- (NSBundle*)getCurrentBundle
//{
//    NSString *skinBundleName = @"YSSkinDarkRsource.bundle";
//
//    if (self.classOrOnline == CHSkinClassOrOnline_online)
//    {
//        skinBundleName = @"YSOnlineSchool.bundle";
//    }
//    else
//    {
//        if (self.roomDetailsType == CHSkinDetailsType_middle)
//        {
//            skinBundleName = @"YSSkinMiddleRsource.bundle";
//        }
//        else if (self.roomDetailsType == CHSkinDetailsType_light)
//        {
//            skinBundleName = @"YSSkinLightRsource.bundle";
//        }
//    }
//
//    return [NSBundle bundleWithPath:[[NSBundle bm_mainResourcePath] stringByAppendingPathComponent:skinBundleName]];
//}


///当前调用的皮肤bundle
- (NSBundle*)getCurrentBundle
{
    if (self.classOrOnline == CHSkinClassOrOnline_online)
    {
        NSString *skinBundleName = @"YSOnlineSchool.bundle";
        
        return [NSBundle bundleWithPath:[[NSBundle bm_mainResourcePath] stringByAppendingPathComponent:skinBundleName]];
    }
    else
    {
        if (self.roomDetailsType == CHSkinDetailsType_dark || !self.roomDetailsType  || ![self.skinBundle bm_isNotEmpty])
        {
            NSString *skinBundleName = @"YSSkinDarkRsource.bundle";
            return [NSBundle bundleWithPath:[[NSBundle bm_mainResourcePath] stringByAppendingPathComponent:skinBundleName]];
        }
        else
        {
            return self.skinBundle;
        }
    }
}

/// 获取plist文件中的数据
- (NSDictionary *)getPliatDictionaryWithType:(CHSkinClassOrOnline)classOrOnline
{
    
    if (self.lastClassOrOnline != self.classOrOnline || self.lastSkinType != self.roomDetailsType || ![self.plictDict bm_isNotEmpty])
    {
        NSString *path = [[self getCurrentBundle] pathForResource:@"SkinSource" ofType:@"plist"];
                    
        self.plictDict = [NSDictionary dictionaryWithContentsOfFile:path];
    }
    
    self.lastSkinType = self.roomDetailsType;
    self.lastClassOrOnline = self.classOrOnline;
    
    return self.plictDict;
}

///默认颜色
- (UIColor *)getDefaultColorWithType:(CHSkinClassOrOnline)classOrOnline WithKey:(NSString *)key
{
    self.classOrOnline = classOrOnline;
    NSDictionary *colorDict = [[self getPliatDictionaryWithType:classOrOnline] bm_dictionaryForKey:@"CommonColor"];
    NSString *colorStr = [colorDict bm_stringForKey:key];

    UIColor *color = [UIColor bm_colorWithHexString:colorStr];
    
    return color;
}

//默认图片
- (UIImage *)getDefaultImageWithType:(CHSkinClassOrOnline)classOrOnline WithKey:(NSString *)key
{
    self.classOrOnline = classOrOnline;
    NSDictionary *imageDict = [[self getPliatDictionaryWithType:classOrOnline] bm_dictionaryForKey:@"CommonImage"];
    NSString *imageName = [imageDict bm_stringForKey:key];
    
    UIImage *image = [self getBundleImageWithType:classOrOnline WithImageName:imageName];
    
    return image;
}

///控件颜色
- (UIColor *)getElementColorWithType:(CHSkinClassOrOnline)classOrOnline WithName:(NSString *)name andKey:(NSString *)key
{
    self.classOrOnline = classOrOnline;
    NSDictionary *elementDict = [[self getPliatDictionaryWithType:classOrOnline] bm_dictionaryForKey:name];
    
    if ([elementDict bm_isNotEmpty])
    {
        NSString *colorStr = [elementDict bm_stringForKey:key];
        
        UIColor *color = [UIColor bm_colorWithHexString:colorStr];
        return color;
    }
    
    return nil;
}

///控件图片
- (UIImage *)getElementImageWithType:(CHSkinClassOrOnline)classOrOnline WithName:(NSString *)name andKey:(NSString *)key
{
    self.classOrOnline = classOrOnline;
    
    NSDictionary *elementDict = [[self getPliatDictionaryWithType:classOrOnline] bm_dictionaryForKey:name];
    
    if ([elementDict bm_isNotEmpty])
    {
        NSString *imageName = [elementDict bm_stringForKey:key];
        
        UIImage *image =  [self getBundleImageWithType:classOrOnline  WithImageName:imageName];
        return image;
    }
    
    return nil;
}

- (UIImage *)getBundleImageWithType:(CHSkinClassOrOnline)classOrOnline WithImageName:(NSString *)imageName
{
    NSString * imageFolder = @"YSSkinImageSource";

    UIImage *image = [[self getCurrentBundle] bm_imageWithAssetsName:imageFolder imageName:imageName];
    return image;
}

@end
