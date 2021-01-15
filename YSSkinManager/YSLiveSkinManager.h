//
//  YSSkinManager.h
//  YSAll
//
//  Created by 马迪 on 2020/5/25.
//  Copyright © 2020 YS. All rights reserved.
//

#import <Foundation/Foundation.h>

//typedef NS_ENUM(NSUInteger, YSSkinType)
//{
//    YSSkinType_dark,
//    YSSkinType_middle,
//    YSSkinType_light,
//    YSSkinType_original,
//};

typedef NS_ENUM(NSUInteger, CHSkinClassOrOnline)
{
    CHSkinClassOrOnline_class,
    CHSkinClassOrOnline_online,
};


NS_ASSUME_NONNULL_BEGIN

@interface YSLiveSkinManager : NSObject

//@property (nonatomic, assign)CHSkinDetailsType roomDetailsType;
@property (nonatomic, assign)BOOL isSmallVC;

@property (nonatomic, assign)CHSkinClassOrOnline classOrOnline;

///换皮肤资源bundle
@property (nonatomic, strong,nullable)NSBundle *skinBundle;


+ (instancetype)shareInstance;

- (UIColor *)getDefaultColorWithType:(CHSkinClassOrOnline)classOrOnline WithKey:(NSString *)key;
- (UIImage *)getDefaultImageWithType:(CHSkinClassOrOnline)classOrOnline WithKey:(NSString *)key;

- (UIColor *)getElementColorWithType:(CHSkinClassOrOnline)classOrOnline WithName:(NSString *)name andKey:(NSString *)key;
- (UIImage *)getElementImageWithType:(CHSkinClassOrOnline)classOrOnline WithName:(NSString *)name andKey:(NSString *)key;


@end

NS_ASSUME_NONNULL_END
