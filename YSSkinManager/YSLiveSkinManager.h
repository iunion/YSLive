//
//  YSSkinManager.h
//  YSAll
//
//  Created by 马迪 on 2020/5/25.
//  Copyright © 2020 YS. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, YSSkinType)
{
    YSSkinType_black,
    YSSkinType_original,
};

typedef NS_ENUM(NSUInteger, YSSkinClassOrOnline)
{
    YSSkinClassOrOnline_class,
    YSSkinClassOrOnline_online,
};


NS_ASSUME_NONNULL_BEGIN

@interface YSLiveSkinManager : NSObject

@property (nonatomic, assign)YSSkinType skinType;

@property (nonatomic, assign)YSSkinClassOrOnline classOrOnline;

+ (instancetype)shareInstance;

- (UIColor *)getDefaultColorWithType:(YSSkinClassOrOnline)classOrOnline WithKey:(NSString *)key;
- (UIImage *)getDefaultImageWithType:(YSSkinClassOrOnline)classOrOnline WithKey:(NSString *)key;

- (UIColor *)getElementColorWithType:(YSSkinClassOrOnline)classOrOnline WithName:(NSString *)name andKey:(NSString *)key;
- (UIImage *)getElementImageWithType:(YSSkinClassOrOnline)classOrOnline WithName:(NSString *)name andKey:(NSString *)key;


@end

NS_ASSUME_NONNULL_END