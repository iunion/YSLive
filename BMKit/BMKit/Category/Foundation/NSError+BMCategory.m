//
//  NSError+BMCategory.m
//  BMKit
//
//  Created by jiang deng on 2020/9/10.
//  Copyright © 2020 DennisDeng. All rights reserved.
//

#import "NSError+BMCategory.h"

@implementation NSError (BMCategory)

+ (instancetype)errorWithDomain:(NSString *)anErrorDomain
                           code:(NSInteger)anErrorCode
           localizedDescription:(NSString *)aLocalizedDescription
{
    return [NSError errorWithDomain:anErrorDomain code:anErrorCode localizedDescription:aLocalizedDescription localizedRecoverySuggestion:nil];
}

+ (instancetype)errorWithDomain:(NSString *)anErrorDomain
                           code:(NSInteger)anErrorCode
           localizedDescription:(NSString *)aLocalizedDescription
    localizedRecoverySuggestion:(NSString *)recoverySuggestion
{
    return [NSError errorWithDomain:anErrorDomain code:anErrorCode localizedDescription:aLocalizedDescription localizedRecoverySuggestion:recoverySuggestion underlyingError:nil];
}

+ (instancetype)errorWithDomain:(NSString *)errorDomain
                           code:(NSInteger)errorCode
           localizedDescription:(NSString *)description
    localizedRecoverySuggestion:(NSString *)recoverySuggestion
                underlyingError:(NSError *)underlyingError
{
    NSDictionary *userInfo = nil;
    if (underlyingError)
    {
        userInfo = @{
            NSLocalizedDescriptionKey : description ? description : @"",
            NSLocalizedRecoverySuggestionErrorKey : recoverySuggestion ? recoverySuggestion : @"",
            NSUnderlyingErrorKey : underlyingError
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
