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
        }
    }
    return skinManager;
}

/// 默认调用的皮肤bundle
- (NSBundle *)getDefaultBundle
{
    if (self.classOrOnline == CHSkinClassOrOnline_online)
    {
        NSString *skinBundleName = @"YSOnlineSchool.bundle";
        
        return [NSBundle bundleWithPath:[[NSBundle bm_mainResourcePath] stringByAppendingPathComponent:skinBundleName]];
    }
    else
    {
        NSString *skinBundleName = @"YSSkinDarkRsource.bundle";
        return [NSBundle bundleWithPath:[[NSBundle bm_mainResourcePath] stringByAppendingPathComponent:skinBundleName]];
    }
}

/// 获取默认plist文件中的数据
- (NSDictionary *)getDefaultPliatDictionaryWithType:(CHSkinClassOrOnline)classOrOnline
{
    NSString *path = [[self getDefaultBundle] pathForResource:@"SkinSource" ofType:@"plist"];
    self.plictDict = [NSDictionary dictionaryWithContentsOfFile:path];
    
    return self.plictDict;
}

/// 当前调用的皮肤bundle
- (NSBundle *)getCurrentBundle
{
    if (self.classOrOnline == CHSkinClassOrOnline_online)
    {
        NSString *skinBundleName = @"YSOnlineSchool.bundle";
        
        return [NSBundle bundleWithPath:[[NSBundle bm_mainResourcePath] stringByAppendingPathComponent:skinBundleName]];
    }
    else
    {
        if (![self.skinBundle bm_isNotEmpty] || !self.isSmallVC || ![[YSLiveManager sharedInstance].roomModel.skinModel.detailUrl bm_isNotEmpty] || [YSLiveManager sharedInstance].roomModel.skinModel.detailType == 1)
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
    NSString *path = [[self getCurrentBundle] pathForResource:@"SkinSource" ofType:@"plist"];
    self.plictDict = [NSDictionary dictionaryWithContentsOfFile:path];
    
    return self.plictDict;
}

/// 通用颜色
- (UIColor *)getCommonColorWithType:(CHSkinClassOrOnline)classOrOnline WithKey:(NSString *)key
{
    self.classOrOnline = classOrOnline;
    NSDictionary *colorDict = [[self getPliatDictionaryWithType:classOrOnline] bm_dictionaryForKey:@"CommonColor"];
    NSString *colorStr = [colorDict bm_stringForKey:key];
    if (![colorStr bm_isNotEmpty])
    {
        colorDict = [[self getDefaultPliatDictionaryWithType:classOrOnline] bm_dictionaryForKey:@"CommonColor"];
        colorStr = [colorDict bm_stringForKey:key];
    }

    UIColor *color = [UIColor bm_colorWithHexString:colorStr];
    
    return color;
}

/// 通用图片
- (UIImage *)getCommonImageWithType:(CHSkinClassOrOnline)classOrOnline WithKey:(NSString *)key
{
    self.classOrOnline = classOrOnline;
    NSDictionary *imageDict = [[self getPliatDictionaryWithType:classOrOnline] bm_dictionaryForKey:@"CommonImage"];
    NSString *imageName = [imageDict bm_stringForKey:key];
    if (![imageName bm_isNotEmpty])
    {
        imageDict = [[self getDefaultPliatDictionaryWithType:classOrOnline] bm_dictionaryForKey:@"CommonImage"];
        imageName = [imageDict bm_stringForKey:key];
    }

    UIImage *image = [self getBundleImageWithType:classOrOnline WithImageName:imageName];
    
    return image;
}

/// 控件颜色
- (UIColor *)getElementColorWithType:(CHSkinClassOrOnline)classOrOnline WithName:(NSString *)name andKey:(NSString *)key
{
    self.classOrOnline = classOrOnline;
    NSDictionary *elementDict = [[self getPliatDictionaryWithType:classOrOnline] bm_dictionaryForKey:name];
    NSString *colorStr = [elementDict bm_stringForKey:key];
    if (![colorStr bm_isNotEmpty])
    {
        elementDict = [[self getDefaultPliatDictionaryWithType:classOrOnline] bm_dictionaryForKey:name];
        colorStr = [elementDict bm_stringForKey:key];
    }

    if ([colorStr bm_isNotEmpty])
    {
        UIColor *color = [UIColor bm_colorWithHexString:colorStr];
        return color;
    }
    
    return nil;
}

/// 控件图片
- (UIImage *)getElementImageWithType:(CHSkinClassOrOnline)classOrOnline WithName:(NSString *)name andKey:(NSString *)key
{
    self.classOrOnline = classOrOnline;
    
    NSDictionary *elementDict = [[self getPliatDictionaryWithType:classOrOnline] bm_dictionaryForKey:name];
    NSString *imageName = [elementDict bm_stringForKey:key];
    if (![imageName bm_isNotEmpty])
    {
        elementDict = [[self getDefaultPliatDictionaryWithType:classOrOnline] bm_dictionaryForKey:name];
        imageName = [elementDict bm_stringForKey:key];
    }

    if ([imageName bm_isNotEmpty])
    {
        UIImage *image = [self getBundleImageWithType:classOrOnline  WithImageName:imageName];
        return image;
    }
    
    return nil;
}

- (UIImage *)getBundleImageWithType:(CHSkinClassOrOnline)classOrOnline WithImageName:(NSString *)imageName
{
    NSString *imageFolder = @"YSSkinImageSource";

    UIImage *image = [[self getCurrentBundle] bm_imageWithAssetsName:imageFolder imageName:imageName];
    if (!image)
    {
        image = [[self getDefaultBundle] bm_imageWithAssetsName:imageFolder imageName:imageName];
    }
    
    return image;
}

@end
