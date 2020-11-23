//
//  BMCache.h
//  BMKit
//
//  Created by jiang deng on 2020/10/26.
//  Copyright © 2020 DennisDeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BMCacheMacros.h"
#import "BMCacheProtocol.h"
#import "BMCacheObjectSubscripting.h"

#import "BMDiskCache.h"
#import "BMMemoryCache.h"

NS_ASSUME_NONNULL_BEGIN

@class BMCache;


/**
 `BMCache` is a thread safe key/value store designed for persisting temporary objects that are expensive to
 reproduce, such as downloaded data or the results of slow processing. It is comprised of two self-similar
 stores, one in memory (<BMMemoryCache>) and one on disk (<BMDiskCache>).
 
 `PINCache` itself actually does very little; its main function is providing a front end for a common use case:
 a small, fast memory cache that asynchronously persists itself to a large, slow disk cache. When objects are
 removed from the memory cache in response to an "apocalyptic" event they remain in the disk cache and are
 repopulated in memory the next time they are accessed. `PINCache` also does the tedious work of creating a
 dispatch group to wait for both caches to finish their operations without blocking each other.
 
 The parallel caches are accessible as public properties (<memoryCache> and <diskCache>) and can be manipulated
 separately if necessary. See the docs for <BMMemoryCache> and <BMDiskCache> for more details.
  */

BMC_SUBCLASSING_RESTRICTED
@interface BMCache : NSObject <BMCacheProtocol, BMCacheObjectSubscripting>

#pragma mark -
/// @name Core

/**
 Synchronously retrieves the total byte count of the <diskCache> on the shared disk queue.
 */
@property (readonly) NSUInteger diskByteCount;

/**
 The underlying disk cache, see <PINDiskCache> for additional configuration and trimming options.
 */
@property (readonly) BMDiskCache *diskCache;

/**
 The underlying memory cache, see <PINMemoryCache> for additional configuration and trimming options.
 */
@property (readonly) BMMemoryCache *memoryCache;

#pragma mark - Lifecycle
/// @name Initialization

/**
 A shared cache.
 
 @result The shared singleton cache instance.
 */
@property (class, strong, readonly) BMCache *sharedCache;

- (instancetype)init NS_UNAVAILABLE;

/**
 Multiple instances with the same name are *not* allowed and can *not* safely
 access the same data on disk. Also used to create the <diskCache>.
 
 @see name
 @param name The name of the cache.
 @result A new cache with the specified name.
 */
- (instancetype)initWithName:(nonnull NSString *)name;

/**
 Multiple instances with the same name are *not* allowed and can *not* safely
 access the same data on disk. Also used to create the <diskCache>.
 
 @see name
 @param name The name of the cache.
 @param rootPath The path of the cache on disk.
 @result A new cache with the specified name.
 */
- (instancetype)initWithName:(nonnull NSString *)name rootPath:(nonnull NSString *)rootPath;

/**
 Multiple instances with the same name are *not* allowed and can *not* safely
 access the same data on disk.. Also used to create the <diskCache>.
 Initializer allows you to override default NSKeyedArchiver/NSKeyedUnarchiver serialization for <diskCache>.
 You must provide both serializer and deserializer, or opt-out to default implementation providing nil values.
 
 @see name
 @param name The name of the cache.
 @param rootPath The path of the cache on disk.
 @param serializer   A block used to serialize object before writing to disk. If nil provided, default NSKeyedArchiver serialized will be used.
 @param deserializer A block used to deserialize object read from disk. If nil provided, default NSKeyedUnarchiver serialized will be used.
 @result A new cache with the specified name.
 */
- (instancetype)initWithName:(NSString *)name
                    rootPath:(NSString *)rootPath
                  serializer:(nullable BMDiskCacheSerializerBlock)serializer
                deserializer:(nullable BMDiskCacheDeserializerBlock)deserializer;

/**
 Multiple instances with the same name are *not* allowed and can *not* safely
 access the same data on disk. Also used to create the <diskCache>.
 Initializer allows you to override default NSKeyedArchiver/NSKeyedUnarchiver serialization for <diskCache>.
 You must provide both serializer and deserializer, or opt-out to default implementation providing nil values.

 @see name
 @param name The name of the cache.
 @param rootPath The path of the cache on disk.
 @param serializer   A block used to serialize object before writing to disk. If nil provided, default NSKeyedArchiver serialized will be used.
 @param deserializer A block used to deserialize object read from disk. If nil provided, default NSKeyedUnarchiver serialized will be used.
 @param keyEncoder A block used to encode key(filename). If nil provided, default url encoder will be used
 @param keyDecoder A block used to decode key(filename). If nil provided, default url decoder will be used
 @result A new cache with the specified name.
 */
- (instancetype)initWithName:(nonnull NSString *)name
                    rootPath:(nonnull NSString *)rootPath
                  serializer:(nullable BMDiskCacheSerializerBlock)serializer
                deserializer:(nullable BMDiskCacheDeserializerBlock)deserializer
                  keyEncoder:(nullable BMDiskCacheKeyEncoderBlock)keyEncoder
                  keyDecoder:(nullable BMDiskCacheKeyDecoderBlock)keyDecoder;

/**
 Multiple instances with the same name are *not* allowed and can *not* safely
 access the same data on disk. Also used to create the <diskCache>.
 Initializer allows you to override default NSKeyedArchiver/NSKeyedUnarchiver serialization for <diskCache>.
 You must provide both serializer and deserializer, or opt-out to default implementation providing nil values.
 
 @see name
 @param name The name of the cache.
 @param rootPath The path of the cache on disk.
 @param serializer   A block used to serialize object before writing to disk. If nil provided, default NSKeyedArchiver serialized will be used.
 @param deserializer A block used to deserialize object read from disk. If nil provided, default NSKeyedUnarchiver serialized will be used.
 @param keyEncoder A block used to encode key(filename). If nil provided, default url encoder will be used
 @param keyDecoder A block used to decode key(filename). If nil provided, default url decoder will be used
 @param ttlCache Whether or not the cache should behave as a TTL cache.
 @result A new cache with the specified name.
 */
- (instancetype)initWithName:(nonnull NSString *)name
                    rootPath:(nonnull NSString *)rootPath
                  serializer:(nullable BMDiskCacheSerializerBlock)serializer
                deserializer:(nullable BMDiskCacheDeserializerBlock)deserializer
                  keyEncoder:(nullable BMDiskCacheKeyEncoderBlock)keyEncoder
                  keyDecoder:(nullable BMDiskCacheKeyDecoderBlock)keyDecoder
                    ttlCache:(BOOL)ttlCache NS_DESIGNATED_INITIALIZER;

@end

#if 0
@interface BMCache (Deprecated)
- (void)containsObjectForKey:(NSString *)key block:(BMCacheObjectContainmentBlock)block __attribute__((deprecated));
- (void)objectForKey:(NSString *)key block:(BMCacheObjectBlock)block __attribute__((deprecated));
- (void)setObject:(id <NSCoding>)object forKey:(NSString *)key block:(nullable BMCacheObjectBlock)block __attribute__((deprecated));
- (void)setObject:(id <NSCoding>)object forKey:(NSString *)key withCost:(NSUInteger)cost block:(nullable BMCacheObjectBlock)block __attribute__((deprecated));
- (void)removeObjectForKey:(NSString *)key block:(nullable BMCacheObjectBlock)block __attribute__((deprecated));
- (void)trimToDate:(NSDate *)date block:(nullable BMCacheBlock)block __attribute__((deprecated));
- (void)removeAllObjects:(nullable BMCacheBlock)block __attribute__((deprecated));
@end
#endif

NS_ASSUME_NONNULL_END
