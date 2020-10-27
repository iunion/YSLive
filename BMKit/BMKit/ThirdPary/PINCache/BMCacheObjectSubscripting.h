//
//  BMCacheObjectSubscripting.h
//  BMKit
//
//  Created by jiang deng on 2020/10/26.
//  Copyright © 2020 DennisDeng. All rights reserved.
//

#ifndef BMCacheObjectSubscripting_h
#define BMCacheObjectSubscripting_h

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol BMCacheObjectSubscripting <NSObject>

@required

/**
 This method enables using literals on the receiving object, such as `id object = cache[@"key"];`.
 
 @param key The key associated with the object.
 @result The object for the specified key.
 */
- (nullable id)objectForKeyedSubscript:(NSString *)key;

/**
 This method enables using literals on the receiving object, such as `cache[@"key"] = object;`.
 
 @param object An object to be assigned for the key. Pass `nil` to remove the existing object for this key.
 @param key A key to associate with the object. This string will be copied.
 */
- (void)setObject:(nullable id)object forKeyedSubscript:(NSString *)key;

@end

NS_ASSUME_NONNULL_END

#endif /* BMCacheObjectSubscripting_h */
