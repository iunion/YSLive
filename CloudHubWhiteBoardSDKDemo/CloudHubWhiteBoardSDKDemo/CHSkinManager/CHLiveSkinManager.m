//
//  CHSkinManager.m
//  CHAll
//
//

#import "CHLiveSkinManager.h"

static CHLiveSkinManager *skinManager = nil;

#define CHSkinBundleName    @"CHSkinRsource.bundle"
#define CHSkinBundle        [NSBundle bundleWithPath:[[NSBundle mainBundle].resourcePath stringByAppendingPathComponent:CHSkinBundleName]]

@interface CHLiveSkinManager ()

@property (nonatomic, assign) CHSkinType lastSkinType;

@property (nonatomic, assign) CHSkinClassOrOnline lastClassOrOnline;

@property (nonatomic, strong) NSDictionary *plictDict;

@end

@implementation CHLiveSkinManager

+ (instancetype)shareInstance
{
    @synchronized(self)
    {
        if (!skinManager)
        {
            skinManager = [[CHLiveSkinManager alloc] init];
            
            skinManager.skinType = CHSkinType_black;
        }
    }
    return skinManager;
}

/// 获取plist文件中的数据
- (NSDictionary *)getPliatDictionaryWithType:(CHSkinClassOrOnline)classOrOnline
{
    
    if (self.lastClassOrOnline != self.classOrOnline || self.lastSkinType != self.skinType || ![CHCommonTools isNotEmpty:self.plictDict])
    {
        NSString *path = nil;
        
        if (classOrOnline == CHSkinClassOrOnline_class)
        {
                path = [CHSkinBundle pathForResource:@"BlackColor" ofType:@"plist"];
        }
            
        self.plictDict = [NSDictionary dictionaryWithContentsOfFile:path];
    }
    
    self.lastSkinType = self.skinType;
    self.lastClassOrOnline = self.classOrOnline;
    
    return self.plictDict;
}

///默认颜色
- (UIColor *)getDefaultColorWithType:(CHSkinClassOrOnline)classOrOnline WithKey:(NSString *)key
{
    self.classOrOnline = classOrOnline;
    NSDictionary *colorDict = [CHCommonTools dictionary:[self getPliatDictionaryWithType:classOrOnline] ForKey:@"CommonColor"];
    NSString *colorStr = [CHCommonTools stringForKey:key byDictionary:colorDict];

    UIColor *color = [CHCommonTools colorWithHexString:colorStr];
    
    return color;
}

//默认图片
- (UIImage *)getDefaultImageWithType:(CHSkinClassOrOnline)classOrOnline WithKey:(NSString *)key
{
    self.classOrOnline = classOrOnline;
//    NSDictionary *imageDict = [[self getPliatDictionaryWithType:classOrOnline] bm_dictionaryForKey:@"CommonImage"];
    NSDictionary *imageDict = [CHCommonTools dictionary:[self getPliatDictionaryWithType:classOrOnline] ForKey:@"CommonImage"];
    NSString *imageName = [CHCommonTools stringForKey:key byDictionary:imageDict];
    
    UIImage *image = [self getBundleImageWithType:classOrOnline WithImageName:imageName];
    
    return image;
}

///控件颜色
- (UIColor *)getElementColorWithType:(CHSkinClassOrOnline)classOrOnline WithName:(NSString *)name andKey:(NSString *)key
{
    self.classOrOnline = classOrOnline;
    NSDictionary *elementDict = [CHCommonTools dictionary:[self getPliatDictionaryWithType:classOrOnline] ForKey:name];
    
    if ([CHCommonTools isNotEmpty:elementDict])
    {
        NSString *colorStr = [CHCommonTools stringForKey:key byDictionary:elementDict];
        
        UIColor *color = [CHCommonTools colorWithHexString:colorStr];
        return color;
    }
    
    return nil;
}

///控件图片
- (UIImage *)getElementImageWithType:(CHSkinClassOrOnline)classOrOnline WithName:(NSString *)name andKey:(NSString *)key
{
    self.classOrOnline = classOrOnline;
        
    NSDictionary *elementDict = [CHCommonTools dictionary:[self getPliatDictionaryWithType:classOrOnline] ForKey:name];
    
    
    if ([CHCommonTools isNotEmpty:elementDict])
    {
        NSString *imageName = [CHCommonTools stringForKey:key byDictionary:elementDict];
        
        UIImage *image =  [self getBundleImageWithType:classOrOnline  WithImageName:imageName];
        return image;
    }
    
    return nil;
}

- (UIImage *)getBundleImageWithType:(CHSkinClassOrOnline)classOrOnline WithImageName:(NSString *)imageName
{
    NSString *imageFolder = nil;
    
    if (classOrOnline == CHSkinClassOrOnline_class)
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
        
    UIImage *image = [CHCommonTools imageWithAssetsName:imageFolder imageName:imageName fromBundle:CHSkinBundle];
    return image;
}

@end
