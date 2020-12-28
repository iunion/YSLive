//
//  CHWhiteBoardSkinManager.h
//  CHWhiteBoard
//
//

#import <Foundation/Foundation.h>

// 换肤
#define CHSkinWhiteDefineColor(s) [[CHWhiteBoardSkinManager shareInstance] getDefaultColorWithKey:(s)]
#define CHSkinWhiteDefineImage(s) [[CHWhiteBoardSkinManager shareInstance] getDefaultImageWithKey:(s)]

#define CHSkinWhiteElementColor(z , s) [[CHWhiteBoardSkinManager shareInstance] getElementColorWithName:(z) andKey:(s)]
#define CHSkinWhiteElementImage(z , s) [[CHWhiteBoardSkinManager shareInstance] getElementImageWithName:(z) andKey:(s)]

//typedef NS_ENUM(NSUInteger, CHWhiteBoardSkinType)
//{
//    CHWhiteBoardSkinType_black,
//    CHWhiteBoardSkinType_original
//};

NS_ASSUME_NONNULL_BEGIN

@interface CHWhiteBoardSkinManager : NSObject

+ (instancetype)shareInstance;
+ (void)destroy;

- (UIColor *)getDefaultColorWithKey:(NSString *)key;
- (UIImage *)getDefaultImageWithKey:(NSString *)key;

- (UIColor *)getElementColorWithName:(NSString *)name andKey:(NSString *)key;
- (UIImage *)getElementImageWithName:(NSString *)name andKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
