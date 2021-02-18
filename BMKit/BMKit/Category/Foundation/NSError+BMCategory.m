//
//  NSError+BMCategory.m
//  BMKit
//
//  Created by jiang deng on 2020/9/10.
//  Copyright © 2020 DennisDeng. All rights reserved.
//

#import "NSError+BMCategory.h"

@implementation NSError (BMCategory)

+ (instancetype)bm_errorWithDomain:(NSString *)anErrorDomain
                              code:(NSInteger)anErrorCode
              localizedDescription:(NSString *)aLocalizedDescription
{
    return [NSError bm_errorWithDomain:anErrorDomain code:anErrorCode localizedDescription:aLocalizedDescription localizedRecoverySuggestion:nil];
}

+ (instancetype)bm_errorWithDomain:(NSString *)anErrorDomain
                              code:(NSInteger)anErrorCode
              localizedDescription:(NSString *)aLocalizedDescription
       localizedRecoverySuggestion:(NSString *)recoverySuggestion
{
    return [NSError bm_errorWithDomain:anErrorDomain code:anErrorCode localizedDescription:aLocalizedDescription localizedRecoverySuggestion:recoverySuggestion underlyingError:nil];
}

+ (instancetype)bm_errorWithDomain:(NSString *)errorDomain
                              code:(NSInteger)errorCode
              localizedDescription:(NSString *)description
       localizedRecoverySuggestion:(NSString *)recoverySuggestion
                   underlyingError:(NSError *)underlyingError
{
    NSDictionary *userInfo = nil;
    if (underlyingError == nil)
    {
        userInfo = @{
            NSLocalizedDescriptionKey : description ? description : @"",
            NSLocalizedRecoverySuggestionErrorKey : recoverySuggestion ? recoverySuggestion : @""
        };
    }
    else
    {
        userInfo = @{
            NSLocalizedDescriptionKey : description ? description : @"",
            NSLocalizedRecoverySuggestionErrorKey : recoverySuggestion ? recoverySuggestion : @"",
            NSUnderlyingErrorKey : underlyingError
        };
    }
    
    NSError *result = [NSError errorWithDomain:errorDomain code:errorCode userInfo:userInfo];
    
    return result;
}

@end
