//
//  NSBundle+BMResource.h
//  Pods
//
//  Created by DennisDeng on 2018/3/29.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/*本地化字符串 （默认 Localizable.string ）*/
// NSLocalizedString(key, comment)
/*使用指定的 string 文件的本地化字符串*/
// NSLocalizedStringFromTable(key, tbl, comment)
/*使用某个包里的的本地化字符串*/
// NSLocalizedStringFromTableInBundle(key, tbl, bundle, comment)
/*用默认值得本地化字符串*/
// NSLocalizedStringWithDefaultValue(key, tbl, bundle, val, comment)

NS_ASSUME_NONNULL_BEGIN

@interface NSBundle (BMResource)

/// 获取main目录下的bundle，此函数只支持在静态下使用
+ (NSBundle *)resourceBundleWithBundleNamed:(NSString *)bundleName;

#pragma mark image

/// 从bundle文件中获取图片
+ (nullable UIImage *)bm_bundleImageFromBundleNamed:(NSString *)bundleName imageName:(NSString *)imageName;
/// 从bundle文件中的xcassets中获取图片(imageset与imageName同名)
+ (nullable UIImage *)bm_bundleAssetsImageFromeBundleName:(NSString *)bundleName assetsName:(NSString *)assetsName imageName:(NSString *)imageName;
+ (nullable UIImage *)bm_bundleAssetsImageFromeBundleName:(NSString *)bundleName assetsName:(NSString *)assetsName pathName:(nullable NSString *)pathName imageName:(NSString *)imageName;

/// 从app的resourcePath中获取图片
- (nullable UIImage *)bm_imageWithImageName:(NSString *)imageName;
/// 从xcassets中获取图片
- (nullable UIImage *)bm_imageWithAssetsName:(NSString *)assetsName imageName:(NSString *)imageName;
- (nullable UIImage *)bm_imageWithAssetsName:(NSString *)assetsName pathName:(nullable NSString *)pathName imageName:(NSString *)imageName;

#pragma mark localizedString

/// 指定语言获取文本
- (NSString *)bm_localizedLanguageStringForKey:(NSString *)key value:(nullable NSString *)value;
- (NSString *)bm_localizedLanguageStringForKey:(NSString *)key value:(nullable NSString *)value table:(nullable NSString *)table;
- (NSString *)bm_localizedLanguageStringForKey:(NSString *)key value:(nullable NSString *)value withLanguage:(nullable NSString *)language;
- (NSString *)bm_localizedLanguageStringForKey:(NSString *)key value:(nullable NSString *)value table:(nullable NSString *)table withLanguage:(nullable NSString *)language;

@end

@interface NSBundle (BMLocalized)

@end

NS_ASSUME_NONNULL_END

