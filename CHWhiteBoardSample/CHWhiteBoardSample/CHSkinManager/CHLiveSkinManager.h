//
//  CHSkinManager.h
//  CHAll
//
//  Created by 马迪 on 2020/5/25.
//  Copyright © 2020 YS. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, CHSkinType)
{
    CHSkinType_black,
    CHSkinType_original,
};

typedef NS_ENUM(NSUInteger, CHSkinClassOrOnline)
{
    CHSkinClassOrOnline_class,
    CHSkinClassOrOnline_online,
};


NS_ASSUME_NONNULL_BEGIN

@interface CHLiveSkinManager : NSObject

@property (nonatomic, assign) CHSkinType skinType;

@property (nonatomic, assign) CHSkinClassOrOnline classOrOnline;

+ (instancetype)shareInstance;

- (UIColor *)getDefaultColorWithType:(CHSkinClassOrOnline)classOrOnline WithKey:(NSString *)key;
- (UIImage *)getDefaultImageWithType:(CHSkinClassOrOnline)classOrOnline WithKey:(NSString *)key;

- (UIColor *)getElementColorWithType:(CHSkinClassOrOnline)classOrOnline WithName:(NSString *)name andKey:(NSString *)key;
- (UIImage *)getElementImageWithType:(CHSkinClassOrOnline)classOrOnline WithName:(NSString *)name andKey:(NSString *)key;


@end

NS_ASSUME_NONNULL_END
