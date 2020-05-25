//
//  YSSkinManager.m
//  YSAll
//
//  Created by 马迪 on 2020/5/25.
//  Copyright © 2020 YS. All rights reserved.
//

#import "YSSkinManager.h"

static YSSkinManager *skinManager = nil;

#define YSSkinBundleName  @"YSSkinRsource.bundle"

#define YSSkinBundle                 [NSBundle bundleWithPath:[[NSBundle bm_mainResourcePath] stringByAppendingPathComponent:YSSkinBundleName]]

@interface YSSkinManager ()

@property(nonatomic ,assign)YSSkinType lastSkinType;

@property(nonatomic ,strong) NSDictionary * plictDict;

@end


@implementation YSSkinManager

+ (instancetype)shareInstance
{
    @synchronized(self)
    {
        if (!skinManager)
        {
            skinManager = [[YSSkinManager alloc] init];
            
            skinManager.skinType = YSSkinType_original;
        }
    }
    return skinManager;
}

///获取plist文件中的数据
- (NSDictionary *)getPliatDictionary
{
    if (self.lastSkinType != self.skinType || ![self.plictDict bm_isNotEmpty])
    {
        NSString *path = nil;
        if (self.skinType == YSSkinType_original)
        {//原始颜色背景 （蓝）
            path = [YSSkinBundle pathForResource:@"OriginalColor" ofType:@"plist"];
        }
        else if (self.skinType == YSSkinType_black)
        {//黑色背景
            path = [YSSkinBundle pathForResource:@"BlackColor" ofType:@"plist"];
        }
            
        self.plictDict = [NSDictionary dictionaryWithContentsOfFile:path];
    }
    self.lastSkinType = self.skinType;
    
    return self.plictDict;
}


- (UIColor *)getDefaultColorWithKey:(NSString *)key
{
    NSDictionary * colorDict = [[self getPliatDictionary] bm_dictionaryForKey:@"CommonColor"];
    
    NSString * colorStr = [colorDict bm_stringForKey:key];
    
    UIColor * color = [UIColor bm_colorWithHexString:colorStr];
    
    return color;
}

- (UIImage *)getDefaultImageWithKey:(NSString *)key
{
    NSDictionary * imageDict = [[self getPliatDictionary] bm_dictionaryForKey:@"CommonImage"];
    NSString * imageName = [imageDict bm_stringForKey:key];
    
    UIImage * image =  [self getBundleImageWithImageName:imageName];
    
    return image;
}


- (UIColor *)getElementColorWithName:(NSString *)name andKey:(NSString *)key
{
    NSDictionary * elementDict = [[self getPliatDictionary] bm_dictionaryForKey:name];
    
    if ([elementDict bm_isNotEmpty])
    {
        NSString * colorStr = [elementDict bm_stringForKey:key];
        
        UIColor * color = [UIColor bm_colorWithHexString:colorStr];
        
        return color;
    }
    return nil;
}

- (UIImage *)getElementImageWithName:(NSString *)name andKey:(NSString *)key
{
    NSDictionary * elementDict = [[self getPliatDictionary] bm_dictionaryForKey:name];
    
    if ([elementDict bm_isNotEmpty])
    {
        NSString * imageName = [elementDict bm_stringForKey:key];
        
        UIImage * image =  [self getBundleImageWithImageName:imageName];
        return image;
    }
    return nil;
}

- (UIImage *)getBundleImageWithImageName:(NSString *)imageName
{
    NSString *imageFolder = nil;
    if (self.skinType == YSSkinType_original)
    {//原始颜色背景 （蓝）
        imageFolder = @"YSSkinOriginal";
    }
    else if (self.skinType == YSSkinType_black)
    {//黑色背景
        imageFolder = @"YSSkinBlack";
    }
    
    
    UIImage * image = [YSSkinBundle bm_imageWithAssetsName:imageFolder imageName:imageName];
    return image;
}


@end
