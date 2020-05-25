//
//  YSSkinManager.h
//  YSAll
//
//  Created by 马迪 on 2020/5/25.
//  Copyright © 2020 YS. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    YSSkinType_original,
    YSSkinType_black,
} YSSkinType;


NS_ASSUME_NONNULL_BEGIN

@interface YSSkinManager : NSObject

@property(nonatomic ,assign)YSSkinType skinType;

+ (instancetype)shareInstance;

- (UIColor *)getDefaultColorWithKey:(NSString *)key;
- (UIImage *)getDefaultImageWithKey:(NSString *)key;

- (UIColor *)getElementColorWithName:(NSString *)name andKey:(NSString *)key;
- (UIImage *)getElementImageWithName:(NSString *)name andKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
