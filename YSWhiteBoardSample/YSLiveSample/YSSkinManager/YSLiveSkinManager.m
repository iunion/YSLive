//
//  YSSkinManager.m
//  YSAll
//
//  Created by 马迪 on 2020/5/25.
//  Copyright © 2020 YS. All rights reserved.
//

#import "YSLiveSkinManager.h"

static YSLiveSkinManager *skinManager = nil;

#define YSSkinBundleName    (self.classOrOnline == YSSkinClassOrOnline_class)?@"YSSkinRsource.bundle": @"YSOnlineSchool.bundle"
#define YSSkinBundle        [NSBundle bundleWithPath:[[NSBundle mainBundle].resourcePath stringByAppendingPathComponent:YSSkinBundleName]]

@interface YSLiveSkinManager ()

@property (nonatomic, assign) YSSkinType lastSkinType;

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
            
            skinManager.skinType = YSSkinType_black;
        }
    }
    return skinManager;
}

/// 获取plist文件中的数据
- (NSDictionary *)getPliatDictionaryWithType:(YSSkinClassOrOnline)classOrOnline
{
    
    if (self.lastClassOrOnline != self.classOrOnline || self.lastSkinType != self.skinType || ![YSCommonTools isNotEmpty:self.plictDict])
    {
        NSString *path = nil;
        
        if (classOrOnline == YSSkinClassOrOnline_class)
        {
            //        if (self.skinType == YSSkinType_original)
            //        {//原始颜色背景 （蓝）
            //            path = [YSSkinBundle pathForResource:@"OriginalColor" ofType:@"plist"];
            //        }
            //        else if (self.skinType == YSSkinType_black)
                    {//黑色背景
                        path = [YSSkinBundle pathForResource:@"BlackColor" ofType:@"plist"];
                    }
        }
        else
        {
            //黑色背景
            path = [YSSkinBundle pathForResource:@"onlineBlackColor" ofType:@"plist"];
        }
            
        NSString * sss = YSSkinBundleName;
        
        self.plictDict = [NSDictionary dictionaryWithContentsOfFile:path];
    }
    
    self.lastSkinType = self.skinType;
    self.lastClassOrOnline = self.classOrOnline;
    
    return self.plictDict;
}

///默认颜色
- (UIColor *)getDefaultColorWithType:(YSSkinClassOrOnline)classOrOnline WithKey:(NSString *)key
{
    self.classOrOnline = classOrOnline;
    NSDictionary *colorDict = [YSCommonTools dictionary:[self getPliatDictionaryWithType:classOrOnline] ForKey:@"CommonColor"];
    NSString *colorStr = [YSCommonTools stringForKey:key byDictionary:colorDict];

    UIColor *color = [YSCommonTools colorWithHexString:colorStr];
    
    return color;
}

//默认图片
- (UIImage *)getDefaultImageWithType:(YSSkinClassOrOnline)classOrOnline WithKey:(NSString *)key
{
    self.classOrOnline = classOrOnline;
//    NSDictionary *imageDict = [[self getPliatDictionaryWithType:classOrOnline] bm_dictionaryForKey:@"CommonImage"];
    NSDictionary *imageDict = [YSCommonTools dictionary:[self getPliatDictionaryWithType:classOrOnline] ForKey:@"CommonImage"];
    NSString *imageName = [YSCommonTools stringForKey:key byDictionary:imageDict];
    
    UIImage *image = [self getBundleImageWithType:classOrOnline WithImageName:imageName];
    
    return image;
}

///控件颜色
- (UIColor *)getElementColorWithType:(YSSkinClassOrOnline)classOrOnline WithName:(NSString *)name andKey:(NSString *)key
{
    self.classOrOnline = classOrOnline;
    NSDictionary *elementDict = [YSCommonTools dictionary:[self getPliatDictionaryWithType:classOrOnline] ForKey:name];
    
    if ([YSCommonTools isNotEmpty:elementDict])
    {
        NSString *colorStr = [YSCommonTools stringForKey:key byDictionary:elementDict];
        
        UIColor *color = [YSCommonTools colorWithHexString:colorStr];
        return color;
    }
    
    return nil;
}

///控件图片
- (UIImage *)getElementImageWithType:(YSSkinClassOrOnline)classOrOnline WithName:(NSString *)name andKey:(NSString *)key
{
    self.classOrOnline = classOrOnline;
        
    NSDictionary *elementDict = [YSCommonTools dictionary:[self getPliatDictionaryWithType:classOrOnline] ForKey:name];
    
    
    if ([YSCommonTools isNotEmpty:elementDict])
    {
        NSString *imageName = [YSCommonTools stringForKey:key byDictionary:elementDict];
        
        UIImage *image =  [self getBundleImageWithType:classOrOnline  WithImageName:imageName];
        return image;
    }
    
    return nil;
}

- (UIImage *)getBundleImageWithType:(YSSkinClassOrOnline)classOrOnline WithImageName:(NSString *)imageName
{
    NSString *imageFolder = nil;
    
    if (classOrOnline == YSSkinClassOrOnline_class)
    {
        //    if (self.skinType == YSSkinType_original)
        //    {//原始颜色背景 （蓝）
        //        imageFolder = @"YSSkinOriginal";
        //    }
        //    else if (self.skinType == YSSkinType_black)
            {//黑色背景
                imageFolder = @"YSSkinBlack";
            }
    }
    else
    {
        //黑色背景
        imageFolder = @"onLineSkinBlack";
    }
        
    UIImage *image = [YSCommonTools imageWithAssetsName:imageFolder imageName:imageName fromBundle:YSSkinBundle];
    return image;
}

@end
