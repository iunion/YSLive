//
//  YSCommonTools.h
//  YSLiveSample
//
//  Created by 马迪 on 2020/9/4.
//  Copyright © 2020 yunshuxunlian. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YSCommonTools : NSObject

+ (BOOL)deviceIsIPad;

+ (NSDictionary *)dictionary:(NSDictionary*)dict ForKey:(id)key;

+ (NSString *)stringForKey:(id)key byDictionary:(NSDictionary*)dict;

+ (UIColor *)colorWithHexString:(NSString *)stringToConvert;

+ (UIColor *)colorWithHex:(UInt32)hex;


+ (UIImage *)imageWithAssetsName:(NSString *)assetsName imageName:(NSString *)imageName fromBundle:(NSBundle*)bundle;

+ (BOOL)isNotEmpty:(id)obc;

+ (BOOL)isNotEmptyDictionary:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END
