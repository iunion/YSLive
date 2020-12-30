//
//  YSSkinManager.m
//  YSAll
//
//  Created by 马迪 on 2020/5/25.
//  Copyright © 2020 YS. All rights reserved.
//

#import "YSLiveSkinManager.h"

static YSLiveSkinManager *skinManager = nil;

//#define YSSkinBundleName    (self.classOrOnline == YSSkinClassOrOnline_class)?@"YSSkinRsource.bundle": @"YSOnlineSchool.bundle"
//#define YSSkinBundle        [NSBundle bundleWithPath:[[NSBundle bm_mainResourcePath] stringByAppendingPathComponent:YSSkinBundleName]]

@interface YSLiveSkinManager ()

@property (nonatomic, assign) YSSkinDetailsType lastSkinType;

@property (nonatomic, assign) YSSkinClassOrOnline lastClassOrOnline;

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

            skinManager.roomDetailsType = YSSkinDetailsType_dark;
        }
    }
    return skinManager;
}

///当前调用的皮肤bundle
- (NSBundle*)getCurrentBundle
{
    NSString *skinBundleName = @"YSSkinDarkRsource.bundle";
    
    if (self.classOrOnline == YSSkinClassOrOnline_online)
    {
        skinBundleName = @"YSOnlineSchool.bundle";
    }
    else
    {
        if (self.roomDetailsType == YSSkinDetailsType_middle)
        {
            skinBundleName = @"YSSkinMiddleRsource.bundle";
        }
        else if (self.roomDetailsType == YSSkinDetailsType_light)
        {
            skinBundleName = @"YSSkinLightRsource.bundle";
        }
    }
    
    return [NSBundle bundleWithPath:[[NSBundle bm_mainResourcePath] stringByAppendingPathComponent:skinBundleName]];
}

/*
///当前调用的皮肤bundle
- (NSBundle*)getCurrentBundle
{
    if (self.classOrOnline == YSSkinClassOrOnline_online)
    {
        NSString *skinBundleName = @"YSOnlineSchool.bundle";
        
        return [NSBundle bundleWithPath:[[NSBundle bm_mainResourcePath] stringByAppendingPathComponent:skinBundleName]];
    }
    else
    {
        
        if (self.roomDetailsType == YSSkinDetailsType_dark || ![self.skinBundle bm_isNotEmpty])
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
*/


/// 获取plist文件中的数据
- (NSDictionary *)getPliatDictionaryWithType:(YSSkinClassOrOnline)classOrOnline
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
- (UIColor *)getDefaultColorWithType:(YSSkinClassOrOnline)classOrOnline WithKey:(NSString *)key
{
    self.classOrOnline = classOrOnline;
    NSDictionary *colorDict = [[self getPliatDictionaryWithType:classOrOnline] bm_dictionaryForKey:@"CommonColor"];
    NSString *colorStr = [colorDict bm_stringForKey:key];

    UIColor *color = [UIColor bm_colorWithHexString:colorStr];
    
    return color;
}

//默认图片
- (UIImage *)getDefaultImageWithType:(YSSkinClassOrOnline)classOrOnline WithKey:(NSString *)key
{
    self.classOrOnline = classOrOnline;
    NSDictionary *imageDict = [[self getPliatDictionaryWithType:classOrOnline] bm_dictionaryForKey:@"CommonImage"];
    NSString *imageName = [imageDict bm_stringForKey:key];
    
    UIImage *image = [self getBundleImageWithType:classOrOnline WithImageName:imageName];
    
    return image;
}

///控件颜色
- (UIColor *)getElementColorWithType:(YSSkinClassOrOnline)classOrOnline WithName:(NSString *)name andKey:(NSString *)key
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
- (UIImage *)getElementImageWithType:(YSSkinClassOrOnline)classOrOnline WithName:(NSString *)name andKey:(NSString *)key
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

- (UIImage *)getBundleImageWithType:(YSSkinClassOrOnline)classOrOnline WithImageName:(NSString *)imageName
{
    NSString * imageFolder = @"YSSkinImageSource";

    UIImage *image = [[self getCurrentBundle] bm_imageWithAssetsName:imageFolder imageName:imageName];
    return image;
}

@end
