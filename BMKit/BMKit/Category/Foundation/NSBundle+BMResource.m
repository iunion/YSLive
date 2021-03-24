//
//  NSBundle+BMResource.m
//  Pods
//
//  Created by DennisDeng on 2018/3/29.
//
//

#import "NSBundle+BMResource.h"
#import "BMkitMacros.h"

@implementation NSBundle (BMResource)

+ (NSBundle *)bm_resourceBundleWithBundleNamed:(NSString *)bundleName
{
    NSBundle *mainBundle = [NSBundle mainBundle];
    //NSBundle *mainBundle = [NSBundle bundleForClass:[self class]];
    
    NSString *bundlePath = [mainBundle pathForResource:bundleName ofType:@"bundle"];
    
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    
    return bundle;
}


#pragma mark - image

+ (UIImage *)bm_bundleImageFromBundleNamed:(NSString *)bundleName imageName:(NSString *)imageName
{
    NSBundle *bundle = [NSBundle bm_resourceBundleWithBundleNamed:bundleName];

    UIImage *image = [bundle bm_imageWithImageName:imageName];
    return image;
}

+ (UIImage *)bm_bundleAssetsImageFromeBundleName:(NSString *)bundleName assetsName:(NSString *)assetsName imageName:(NSString *)imageName
{
    return [NSBundle bm_bundleAssetsImageFromeBundleName:bundleName assetsName:assetsName pathName:nil imageName:imageName];
}

+ (UIImage *)bm_bundleAssetsImageFromeBundleName:(NSString *)bundleName assetsName:(NSString *)assetsName pathName:(NSString *)pathName imageName:(NSString *)imageName
{
    NSBundle *bundle = [NSBundle bm_resourceBundleWithBundleNamed:bundleName];

    UIImage *image = [bundle bm_imageWithAssetsName:assetsName pathName:pathName imageName:imageName];

    return image;
}

- (UIImage *)bm_imageWithImageName:(NSString *)imageName
{
    UIImage *image = nil;
    if (@available(iOS 13.0, *))
    {
        image = [UIImage imageNamed:imageName inBundle:self withConfiguration:nil];
    }
    else
    {
        image = [UIImage imageNamed:imageName inBundle:self compatibleWithTraitCollection:nil];
    }
    
    return image;
}

- (UIImage *)bm_imageWithAssetsName:(NSString *)assetsName imageName:(NSString *)imageName
{
    return [self bm_imageWithAssetsName:assetsName pathName:nil imageName:imageName];
}

- (UIImage *)bm_imageWithAssetsName:(NSString *)assetsName pathName:(NSString *)pathName imageName:(NSString *)imageName
{
    if (![imageName bm_isNotEmpty] || ![assetsName bm_isNotEmpty])
    {
        return nil;
    }
    
    NSString *basePath = [self pathForResource:assetsName ofType:@"xcassets"];
    NSString *imagePathName = [imageName stringByAppendingPathExtension:@"imageset"];

    NSString *imageFilePath = [basePath stringByAppendingPathComponent:imagePathName];
    
    if ([pathName bm_isNotEmpty])
    {
        imageFilePath = [[basePath stringByAppendingPathComponent:pathName] stringByAppendingPathComponent:imagePathName];
    }

    NSBundle *imageBundle = [NSBundle bundleWithPath:imageFilePath];
    
    UIImage *image = [imageBundle bm_imageWithImageName:imageName];
    
    return image;
}

#pragma mark localizedString

+ (NSBundle *)bm_localizedBundleWithBundle:(NSBundle *)bundle
{
    return [NSBundle bm_localizedBundleWithBundle:bundle language:nil];
}

+ (NSBundle *)bm_localizedBundleWithBundle:(NSBundle *)bundle language:(NSString *)language
{
    NSString *systemLanguage = nil;
    if (language)
    {
        systemLanguage = language;
    }
    else
    {
        // 这里返回的是app优先语言环境，NSLocal返回的是系统设置
        NSArray *languages = [[NSBundle mainBundle] preferredLocalizations];
        systemLanguage = languages.firstObject;
        
        if ([systemLanguage hasPrefix:@"zh"])
        {
            if ([systemLanguage rangeOfString:@"CN"].location != NSNotFound || [systemLanguage rangeOfString:@"Hans"].location != NSNotFound)
            {
                systemLanguage = @"zh-Hans"; // 简体中文
            }
            else
            { // zh-Hant\zh-HK\zh-TW
                systemLanguage = @"zh-Hant"; // 繁體中文
            }
        }
        else
        {
            systemLanguage = @"en";
        }
    }
    
    NSString *basePath = [bundle pathForResource:systemLanguage ofType:@"lproj"];
    return [NSBundle bundleWithPath:basePath];
}

- (NSString *)bm_localizedLanguageStringForKey:(NSString *)key value:(NSString *)value
{
    return [self bm_localizedLanguageStringForKey:key value:value table:nil withLanguage:nil];
}

- (NSString *)bm_localizedLanguageStringForKey:(NSString *)key value:(NSString *)value table:(NSString *)table
{
    return [self bm_localizedLanguageStringForKey:key value:value table:table withLanguage:nil];
}

- (NSString *)bm_localizedLanguageStringForKey:(NSString *)key value:(NSString *)value withLanguage:(NSString *)language
{
    return [self bm_localizedLanguageStringForKey:key value:value table:nil withLanguage:language];
}

- (NSString *)bm_localizedLanguageStringForKey:(NSString *)key value:(NSString *)value table:(NSString *)table withLanguage:(NSString *)language
{
    NSBundle *localizedBundle = [NSBundle bm_localizedBundleWithBundle:self language:language];
    return [localizedBundle localizedStringForKey:key value:value table:table];
}

@end


@implementation NSBundle (BMLocalized)



@end
