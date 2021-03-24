//
//  NSError+BMCategory.h
//  BMKit
//
//  Created by jiang deng on 2020/9/10.
//  Copyright © 2020 DennisDeng. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSError (BMCategory)

+ (instancetype)bm_errorWithDomain:(NSString *)anErrorDomain
                              code:(NSInteger)anErrorCode
              localizedDescription:(nullable NSString *)aLocalizedDescription;

+ (instancetype)bm_errorWithDomain:(NSString *)anErrorDomain
                              code:(NSInteger)anErrorCode
              localizedDescription:(nullable NSString *)aLocalizedDescription
       localizedRecoverySuggestion:(nullable NSString *)recoverySuggestion;

+ (instancetype)bm_errorWithDomain:(NSString *)errorDomain
                              code:(NSInteger)errorCode
              localizedDescription:(nullable NSString *)description
       localizedRecoverySuggestion:(nullable NSString *)recoverySuggestion
                   underlyingError:(nullable NSError *)underlyingError;

@end

NS_ASSUME_NONNULL_END
