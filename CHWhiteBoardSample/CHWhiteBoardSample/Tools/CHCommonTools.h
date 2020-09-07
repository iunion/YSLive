//
//  CHCommonTools.h
//  CHLiveSample
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CHCommonTools : NSObject

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
