//
//  YSSessionError.h
//  YSSession
//
//  Created by jiang deng on 2020/6/15.
//  Copyright © 2020 YS. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YSSessionError : NSObject

+ (NSString *)errorDomain;

+ (NSError *)errorWithCode:(NSInteger)code message:(NSString *)message;

+ (NSError *)errorWithCode:(NSInteger)code message:(NSString *)message underlyingError:(nullable NSError *)underlyingError;

+ (NSError *)errorWithCode:(NSInteger)code message:(NSString *)message userInfo:(nullable NSDictionary *)userInfo underlyingError:(nullable NSError *)underlyingError;

@end

NS_ASSUME_NONNULL_END
