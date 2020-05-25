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


@implementation YSSkinManager

+ (instancetype)shareInstance
{
    @synchronized(self)
    {
        if (!skinManager)
        {
            skinManager = [[YSSkinManager alloc] init];
        }
    }
    return skinManager;
}


- (NSDictionary *)getPliatDictionary
{
    NSString *path = nil;
    if (self.skinType == YSSkinType_original)
    {
        path = [[NSBundle mainBundle] pathForResource:@"OriginalColor" ofType:@"plist"];
    }
    else if (self.skinType == YSSkinType_black)
    {
        path = [[NSBundle mainBundle] pathForResource:@"BlackColor" ofType:@"plist"];
    }
        
    NSDictionary * plictDict = [NSDictionary dictionaryWithContentsOfFile:path];
    
    return plictDict;
}

- (UIColor *)getDefaultColorWithKey:(NSString *)key
{
    NSString * colorStr = [[self getPliatDictionary] bm_stringForKey:key];
    
    UIColor * color = [UIColor bm_colorWithHexString:colorStr];
    
    return color;
}


- (UIColor *)getElementColorWithName:(NSString *)name andKey:(NSString *)key
{
    NSDictionary * elementDict = [[self getPliatDictionary] bm_dictionaryForKey:name];
    
    if ([elementDict bm_isNotEmpty])
    {
        NSString * colorStr = [[self getPliatDictionary] bm_stringForKey:key];
        
        UIColor * color = [UIColor bm_colorWithHexString:colorStr];
        
        return color;
    }
    return nil;
}

@end
