//
//  BMDiskCache.h
//  BMKit
//
//  Created by jiang deng on 2020/10/26.
//  Copyright © 2020 DennisDeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BMCacheMacros.h"
#import "BMCacheProtocol.h"
#import "BMCacheObjectSubscripting.h"

NS_ASSUME_NONNULL_BEGIN

@class BMDiskCache;
@class BMCacheOperationQueue;

extern NSString * const BMDiskCacheErrorDomain;
extern NSErrorUserInfoKey const BMDiskCacheErrorReadFailureCodeKey;
extern NSErrorUserInfoKey const BMDiskCacheErrorWriteFailureCodeKey;
extern NSString * const BMDiskCachePrefix;

typedef NS_ENUM(NSInteger, BMDiskCacheError) {
    BMDiskCacheErrorReadFailure = -1000,
    BMDiskCacheErrorWriteFailure = -1001,
};

/**
 A callback block which provides the cache, key and object as arguments
 */
typedef void (^BMDiskCacheObjectBlock)(BMDiskCache *cache, NSString *key, id <NSCoding> _Nullable object);

/**
 A callback block which provides the key and fileURL of the object
 */
typedef void (^BMDiskCacheFileURLBlock)(NSString *key, NSURL * _Nullable fileURL);

/**
 A callback block used for enumeration which provides the key and fileURL of the object plus a stop flag that
 may be flipped by the caller.
 */
typedef void (^BMDiskCacheFileURLEnumerationBlock)(NSString *key, NSURL * _Nullable fileURL, BOOL *stop);

/**
 A callback block which provides a BOOL value as argument
 */
typedef void (^BMDiskCacheContainsBlock)(BOOL containsObject);

/**
 *  A block used to serialize object before writing to disk
 *
 *  @param object Object to serialize
 *  @param key The key associated with the object
 *
 *  @return Serialized object representation
 */
typedef NSData* _Nonnull(^BMDiskCacheSerializerBlock)(id<NSCoding> object, NSString *key);

/**
 *  A block used to deserialize objects
 *
 *  @param data Serialized object data
 *  @param key The key associated with the object
 *
 *  @return Deserialized object
 */
typedef id<NSCoding> _Nonnull(^BMDiskCacheDeserializerBlock)(NSData* data, NSString *key);

/**
 *  A block used to encode keys
 *
 *  @param decodedKey Original/decoded key
 *
 *  @return encoded key
 */
typedef NSString *_Nonnull(^BMDiskCacheKeyEncoderBlock)(NSString *decodedKey);

/**
 *  A block used to decode keys
 *
 *  @param encodedKey An encoded key
 *
 *  @return decoded key
 */
typedef NSString *_Nonnull(^BMDiskCacheKeyDecoderBlock)(NSString *encodedKey);


/**
 `BMDiskCache` is a thread safe key/value store backed by the file system. It accepts any object conforming
 to the `NSCoding` protocol, which includes the basic Foundation data types and collection classes and also
 many UIKit classes, notably `UIImage`. All work is performed on a serial queue shared by all instances in
 the app, and archiving is handled by `NSKeyedArchiver`. This is a particular advantage for `UIImage` because
 it skips `UIImagePNGRepresentation()` and retains information like scale and orientation.
 
 The designated initializer for `BMDiskCache` is <initWithName:>. The <name> string is used to create a directory
 under Library/Caches that scopes disk access for this instance. Multiple instances with the same name are *not*
 allowed as they would conflict with each other.
 
 Unless otherwise noted, all properties and methods are safe to access from any thread at any time. All blocks
 will cause the queue to wait, making it safe to access and manipulate the actual cache files on disk for the
 duration of the block.
 
 Because this cache is bound by disk I/O it can be much slower than <BMMemoryCache>, although values stored in
 `BMDiskCache` persist after application relaunch. Using <PINCache> is recommended over using `BMDiskCache`
 by itself, as it adds a fast layer of additional memory caching while still writing to disk.
 
 All access to the cache is dated so the that the least-used objects can be trimmed first. Setting an optional
 <ageLimit> will trigger a GCD timer to periodically to trim the cache with <trimToDate:>.
 */

BMC_SUBCLASSING_RESTRICTED
@interface BMDiskCache : NSObject <BMCacheProtocol, BMCacheObjectSubscripting>

#pragma mark - Class

/**
 @param rootPath The path for where the cache should be stored.
 @param prefix The prefix for the cache name.
 @param name The name of the cache.
 @result The full URL of the cache.
 */
+ (NSURL *)cacheURLWithRootPath:(NSString *)rootPath prefix:(NSString *)prefix name:(NSString *)name;

#pragma mark - Properties
/// @name Core

/**
 The prefix to the name of this cache, used to create a directory under Library/Caches and also appearing in stack traces.
 */
@property (readonly) NSString *prefix;

/**
 The URL of the directory used by this cache, usually `Library/Caches/com.pinterest.PINDiskCache.(name)`
 
 @warning Do not interact with files under this URL except in <lockFileAccessWhileExecutingBlock:> or
 <synchronouslyLockFileAccessWhileExecutingBlock:>.
 */
@property (readonly) NSURL *cacheURL;
@property (readonly) NSString *cacheFilePath;

/**
 The total number of bytes used on disk, as reported by `NSURLTotalFileAllocatedSizeKey`.
 
 @warning This property should only be read from a call to <synchronouslyLockFileAccessWhileExecutingBlock:> or
 its asynchronous equivalent <lockFileAccessWhileExecutingBlock:>
 
 For example:
 
 // some background thread
 
 __block NSUInteger byteCount = 0;
 
 [_diskCache synchronouslyLockFileAccessWhileExecutingBlock:^(PINDiskCache *diskCache) {
 byteCount = diskCache.byteCount;
 }];
 */
@property (readonly) NSUInteger byteCount;

/**
 The maximum number of bytes allowed on disk. This value is checked every time an object is set, if the written
 size exceeds the limit a trim call is queued. Defaults to 50MB.
 
 */
@property (assign) NSUInteger byteLimit;

/**
 The maximum number of seconds an object is allowed to exist in the cache. Setting this to a value
 greater than `0.0` will start a recurring GCD timer with the same period that calls <trimToDate:>.
 Setting it back to `0.0` will stop the timer. Defaults to 30 days.
 
 */
@property (assign) NSTimeInterval ageLimit;

/**
 The writing protection option used when writing a file on disk. This value is used every time an object is set.
 NSDataWritingAtomic and NSDataWritingWithoutOverwriting are ignored if set
 Defaults to NSDataWritingFileProtectionNone.
 
 @warning Only new files are affected by the new writing protection. If you need all files to be affected,
 you'll have to purge and set the objects back to the cache
 
 Only available on iOS
 */
#if TARGET_OS_IPHONE
@property (assign) NSDataWritingOptions writingProtectionOption;
#endif

/**
 If ttlCache is YES, the cache behaves like a ttlCache. This means that once an object enters the
 cache, it only lives as long as self.ageLimit. This has the following implications:
 - Accessing an object in the cache does not extend that object's lifetime in the cache
 - When attempting to access an object in the cache that has lived longer than self.ageLimit,
 the cache will behave as if the object does not exist
 
 @note If an object-level age limit is set via one of the @c -setObject:forKey:withAgeLimit methods,
 that age limit overrides self.ageLimit. The overridden object age limit could be greater or less
 than self.agelimit but must be greater than zero.
 
 */
@property (nonatomic, readonly, getter=isTTLCache) BOOL ttlCache;

#pragma mark - Event Blocks
/// @name Event Blocks

/**
 A block to be executed just before an object is added to the cache. The queue waits during execution.
 */
@property (nullable, copy) BMDiskCacheObjectBlock willAddObjectBlock;

/**
 A block to be executed just before an object is removed from the cache. The queue waits during execution.
 */
@property (nullable, copy) BMDiskCacheObjectBlock willRemoveObjectBlock;

/**
 A block to be executed just before all objects are removed from the cache as a result of <removeAllObjects:>.
 The queue waits during execution.
 */
@property (nullable, copy) BMCacheBlock willRemoveAllObjectsBlock;

/**
 A block to be executed just after an object is added to the cache. The queue waits during execution.
 */
@property (nullable, copy) BMDiskCacheObjectBlock didAddObjectBlock;

/**
 A block to be executed just after an object is removed from the cache. The queue waits during execution.
 */
@property (nullable, copy) BMDiskCacheObjectBlock didRemoveObjectBlock;

/**
 A block to be executed just after all objects are removed from the cache as a result of <removeAllObjects:>.
 The queue waits during execution.
 */
@property (nullable, copy) BMCacheBlock didRemoveAllObjectsBlock;

#pragma mark - Lifecycle
/// @name Initialization

/**
 A shared cache.
 
 @result The shared singleton cache instance.
 */
@property (class, readonly, strong) BMDiskCache *sharedCache;

/**
 Empties the trash with `DISPATCH_QUEUE_PRIORITY_BACKGROUND`. Does not use lock.
 */
+ (void)emptyTrash;

- (instancetype)init NS_UNAVAILABLE;

/**
 Multiple instances with the same name are *not* allowed as they would conflict
 with each other.
 
 @see name
 @param name The name of the cache.
 @result A new cache with the specified name.
 */
- (instancetype)initWithName:(nonnull NSString *)name;

/**
 Multiple instances with the same name are *not* allowed as they would conflict
 with each other.
 
 @see name
 @param name The name of the cache.
 @param rootPath The path of the cache.
 @result A new cache with the specified name.
 */
- (instancetype)initWithName:(nonnull NSString *)name rootPath:(nonnull NSString *)rootPath;

/**
 @see name
 @param name The name of the cache.
 @param rootPath The path of the cache.
 @param serializer   A block used to serialize object. If nil provided, default NSKeyedArchiver serialized will be used.
 @param deserializer A block used to deserialize object. If nil provided, default NSKeyedUnarchiver serialized will be used.
 @result A new cache with the specified name.
 */
- (instancetype)initWithName:(nonnull NSString *)name rootPath:(nonnull NSString *)rootPath serializer:(nullable BMDiskCacheSerializerBlock)serializer deserializer:(nullable BMDiskCacheDeserializerBlock)deserializer;

/**
 @see name
 @param name The name of the cache.
 @param rootPath The path of the cache.
 @param serializer   A block used to serialize object. If nil provided, default NSKeyedArchiver serialized will be used.
 @param deserializer A block used to deserialize object. If nil provided, default NSKeyedUnarchiver serialized will be used.
 @param operationQueue A PINOperationQueue to run asynchronous operations
 @result A new cache with the specified name.
 */
- (instancetype)initWithName:(nonnull NSString *)name rootPath:(nonnull NSString *)rootPath serializer:(nullable BMDiskCacheSerializerBlock)serializer deserializer:(nullable BMDiskCacheDeserializerBlock)deserializer operationQueue:(nonnull BMCacheOperationQueue *)operationQueue __attribute__((deprecated));

/**
 @see name
 @param name The name of the cache.
 @param prefix The prefix for the cache name. Defaults to com.pinterest.PINDiskCache
 @param rootPath The path of the cache.
 @param serializer   A block used to serialize object. If nil provided, default NSKeyedArchiver serialized will be used.
 @param deserializer A block used to deserialize object. If nil provided, default NSKeyedUnarchiver serialized will be used.
 @param keyEncoder A block used to encode key(filename). If nil provided, default url encoder will be used
 @param keyDecoder A block used to decode key(filename). If nil provided, default url decoder will be used
 @param operationQueue A PINOperationQueue to run asynchronous operations
 @result A new cache with the specified name.
 */
- (instancetype)initWithName:(nonnull NSString *)name
                      prefix:(nonnull NSString *)prefix
                    rootPath:(nonnull NSString *)rootPath
                  serializer:(nullable BMDiskCacheSerializerBlock)serializer
                deserializer:(nullable BMDiskCacheDeserializerBlock)deserializer
                  keyEncoder:(nullable BMDiskCacheKeyEncoderBlock)keyEncoder
                  keyDecoder:(nullable BMDiskCacheKeyDecoderBlock)keyDecoder
              operationQueue:(nonnull BMCacheOperationQueue *)operationQueue;

/**
 The designated initializer allowing you to override default NSKeyedArchiver/NSKeyedUnarchiver serialization.
 
 @see name
 @param name The name of the cache.
 @param prefix The prefix for the cache name. Defaults to com.pinterest.PINDiskCache
 @param rootPath The path of the cache.
 @param serializer   A block used to serialize object. If nil provided, default NSKeyedArchiver serialized will be used.
 @param deserializer A block used to deserialize object. If nil provided, default NSKeyedUnarchiver serialized will be used.
 @param keyEncoder A block used to encode key(filename). If nil provided, default url encoder will be used
 @param keyDecoder A block used to decode key(filename). If nil provided, default url decoder will be used
 @param operationQueue A PINOperationQueue to run asynchronous operations
 @param ttlCache Whether or not the cache should behave as a TTL cache.
 @result A new cache with the specified name.
 */
- (instancetype)initWithName:(nonnull NSString *)name
                      prefix:(nonnull NSString *)prefix
                    rootPath:(nonnull NSString *)rootPath
                  serializer:(nullable BMDiskCacheSerializerBlock)serializer
                deserializer:(nullable BMDiskCacheDeserializerBlock)deserializer
                  keyEncoder:(nullable BMDiskCacheKeyEncoderBlock)keyEncoder
                  keyDecoder:(nullable BMDiskCacheKeyDecoderBlock)keyDecoder
              operationQueue:(nonnull BMCacheOperationQueue *)operationQueue
                    ttlCache:(BOOL)ttlCache NS_DESIGNATED_INITIALIZER;

#pragma mark - Asynchronous Methods
/// @name Asynchronous Methods
/**
 Locks access to ivars and allows safe interaction with files on disk. This method returns immediately.
 
 @warning Calling synchronous methods on the diskCache inside this block will likely cause a deadlock.
 
 @param block A block to be executed when a lock is available.
 */
- (void)lockFileAccessWhileExecutingBlockAsync:(BMCacheBlock)block;

/**
 Retrieves the object for the specified key. This method returns immediately and executes the passed
 block as soon as the object is available.
 
 @param key The key associated with the requested object.
 @param block A block to be executed serially when the object is available.
 */
- (void)objectForKeyAsync:(NSString *)key completion:(nullable BMDiskCacheObjectBlock)block;

/**
 Retrieves the fileURL for the specified key without actually reading the data from disk. This method
 returns immediately and executes the passed block as soon as the object is available.
 
 @warning Access is protected for the duration of the block, but to maintain safe disk access do not
 access this fileURL after the block has ended.
 
 @warning The PINDiskCache lock is held while block is executed. Any synchronous calls to the diskcache
 or a cache which owns the instance of the disk cache are likely to cause a deadlock. This is why the block is
 *not* passed the instance of the disk cache. You should also avoid doing extensive work while this
 lock is held.
 
 @param key The key associated with the requested object.
 @param block A block to be executed serially when the file URL is available.
 */
- (void)fileURLForKeyAsync:(NSString *)key completion:(BMDiskCacheFileURLBlock)block;

/**
 Stores an object in the cache for the specified key. This method returns immediately and executes the
 passed block as soon as the object has been stored.
 
 @param object An object to store in the cache.
 @param key A key to associate with the object. This string will be copied.
 @param block A block to be executed serially after the object has been stored, or nil.
 */
- (void)setObjectAsync:(id <NSCoding>)object forKey:(NSString *)key completion:(nullable BMDiskCacheObjectBlock)block;

/**
 Stores an object in the cache for the specified key and age limit. This method returns immediately and executes the
 passed block as soon as the object has been stored.
 
 @param object An object to store in the cache.
 @param key A key to associate with the object. This string will be copied.
 @param ageLimit The age limit (in seconds) to associate with the object. An age limit <= 0 means there is no object-level age limit and the cache-level TTL
 will be used for this object.
 @param block A block to be executed serially after the object has been stored, or nil.
 */
- (void)setObjectAsync:(id <NSCoding>)object forKey:(NSString *)key withAgeLimit:(NSTimeInterval)ageLimit completion:(nullable BMDiskCacheObjectBlock)block;

/**
 Stores an object in the cache for the specified key and the specified memory cost. If the cost causes the total
 to go over the <memoryCache.costLimit> the cache is trimmed (oldest objects first). This method returns immediately
 and executes the passed block after the object has been stored, potentially in parallel with other blocks
 on the <concurrentQueue>.
 
 @param object An object to store in the cache.
 @param key A key to associate with the object. This string will be copied.
 @param cost An amount to add to the <memoryCache.totalCost>.
 @param block A block to be executed concurrently after the object has been stored, or nil.
 */
- (void)setObjectAsync:(id <NSCoding>)object forKey:(NSString *)key withCost:(NSUInteger)cost completion:(nullable BMCacheObjectBlock)block;

/**
 Stores an object in the cache for the specified key and the specified memory cost and age limit. If the cost causes the total
 to go over the <memoryCache.costLimit> the cache is trimmed (oldest objects first). This method returns immediately
 and executes the passed block after the object has been stored, potentially in parallel with other blocks
 on the <concurrentQueue>.
 
 @param object An object to store in the cache.
 @param key A key to associate with the object. This string will be copied.
 @param cost An amount to add to the <memoryCache.totalCost>.
 @param ageLimit The age limit (in seconds) to associate with the object. An age limit <= 0 means there is no object-level age limit and the cache-level TTL will be used for
 this object.
 @param block A block to be executed concurrently after the object has been stored, or nil.
 */
- (void)setObjectAsync:(id <NSCoding>)object forKey:(NSString *)key withCost:(NSUInteger)cost ageLimit:(NSTimeInterval)ageLimit completion:(nullable BMCacheObjectBlock)block;

/**
 Removes the object for the specified key. This method returns immediately and executes the passed block
 as soon as the object has been removed.
 
 @param key The key associated with the object to be removed.
 @param block A block to be executed serially after the object has been removed, or nil.
 */
- (void)removeObjectForKeyAsync:(NSString *)key completion:(nullable BMDiskCacheObjectBlock)block;

/**
 Removes objects from the cache, largest first, until the cache is equal to or smaller than the specified byteCount.
 This method returns immediately and executes the passed block as soon as the cache has been trimmed.
 
 @param byteCount The cache will be trimmed equal to or smaller than this size.
 @param block A block to be executed serially after the cache has been trimmed, or nil.
 */
- (void)trimToSizeAsync:(NSUInteger)byteCount completion:(nullable BMCacheBlock)block;

/**
 Removes objects from the cache, ordered by date (least recently used first), until the cache is equal to or smaller
 than the specified byteCount. This method returns immediately and executes the passed block as soon as the cache has
 been trimmed.
 
 @param byteCount The cache will be trimmed equal to or smaller than this size.
 @param block A block to be executed serially after the cache has been trimmed, or nil.
 
 @note This will not remove objects that have been added via one of the @c -setObject:forKey:withAgeLimit methods.
 */
- (void)trimToSizeByDateAsync:(NSUInteger)byteCount completion:(nullable BMCacheBlock)block;

/**
 Loops through all objects in the cache (reads and writes are suspended during the enumeration). Data is not actually
 read from disk, the `object` parameter of the block will be `nil` but the `fileURL` will be available.
 This method returns immediately.
 
 @param block A block to be executed for every object in the cache.
 @param completionBlock An optional block to be executed after the enumeration is complete.
 
 @warning The PINDiskCache lock is held while block is executed. Any synchronous calls to the diskcache
 or a cache which owns the instance of the disk cache are likely to cause a deadlock. This is why the block is
 *not* passed the instance of the disk cache. You should also avoid doing extensive work while this
 lock is held.
 
 */
- (void)enumerateObjectsWithBlockAsync:(BMDiskCacheFileURLEnumerationBlock)block completionBlock:(nullable BMCacheBlock)completionBlock;

#pragma mark - Synchronous Methods
/// @name Synchronous Methods

/**
 Locks access to ivars and allows safe interaction with files on disk. This method only returns once the block
 has been run.
 
 @warning Calling synchronous methods on the diskCache inside this block will likely cause a deadlock.
 
 @param block A block to be executed when a lock is available.
 */
- (void)synchronouslyLockFileAccessWhileExecutingBlock:(BMC_NOESCAPE BMCacheBlock)block;

/**
 Retrieves the object for the specified key. This method blocks the calling thread until the
 object is available.
 
 @see objectForKeyAsync:completion:
 @param key The key associated with the object.
 @result The object for the specified key.
 */
- (nullable id <NSCoding>)objectForKey:(NSString *)key;

/**
 Retrieves the file URL for the specified key. This method blocks the calling thread until the
 url is available. Do not use this URL anywhere except with <lockFileAccessWhileExecutingBlock:>. This method probably
 shouldn't even exist, just use the asynchronous one.
 
 @see fileURLForKeyAsync:completion:
 @param key The key associated with the object.
 @result The file URL for the specified key.
 */
- (nullable NSURL *)fileURLForKey:(nullable NSString *)key;

/**
 Stores an object in the cache for the specified key. This method blocks the calling thread until
 the object has been stored.
 
 @see setObjectAsync:forKey:completion:
 @param object An object to store in the cache.
 @param key A key to associate with the object. This string will be copied.
 */
- (void)setObject:(nullable id <NSCoding>)object forKey:(NSString *)key;

/**
 Stores an object in the cache for the specified key and age limit. This method blocks the calling thread until
 the object has been stored.
 
 @see setObjectAsync:forKey:completion:
 @param object An object to store in the cache.
 @param key A key to associate with the object. This string will be copied.
 @param ageLimit The age limit (in seconds) to associate with the object. An age limit <= 0 means there is
 no object-level age limit and the cache-level TTL will be used for this object.
 */
- (void)setObject:(nullable id <NSCoding>)object forKey:(NSString *)key withAgeLimit:(NSTimeInterval)ageLimit;

/**
 Removes objects from the cache, largest first, until the cache is equal to or smaller than the
 specified byteCount. This method blocks the calling thread until the cache has been trimmed.
 
 @see trimToSizeAsync:
 @param byteCount The cache will be trimmed equal to or smaller than this size.
 */
- (void)trimToSize:(NSUInteger)byteCount;

/**
 Removes objects from the cache, ordered by date (least recently used first), until the cache is equal to or
 smaller than the specified byteCount. This method blocks the calling thread until the cache has been trimmed.
 
 @see trimToSizeByDateAsync:
 @param byteCount The cache will be trimmed equal to or smaller than this size.
 
 @note This will not remove objects that have been added via one of the @c -setObject:forKey:withAgeLimit methods.
 */
- (void)trimToSizeByDate:(NSUInteger)byteCount;

/**
 Loops through all objects in the cache (reads and writes are suspended during the enumeration). Data is not actually
 read from disk, the `object` parameter of the block will be `nil` but the `fileURL` will be available.
 This method blocks the calling thread until all objects have been enumerated.
 
 @see enumerateObjectsWithBlockAsync:completionBlock
 @param block A block to be executed for every object in the cache.
 
 @warning Do not call this method within the event blocks (<didRemoveObjectBlock>, etc.)
 Instead use the asynchronous version, <enumerateObjectsWithBlock:completionBlock:>.
 
 @warning The PINDiskCache lock is held while block is executed. Any synchronous calls to the diskcache
 or a cache which owns the instance of the disk cache are likely to cause a deadlock. This is why the block is
 *not* passed the instance of the disk cache. You should also avoid doing extensive work while this
 lock is held.
 
 */
- (void)enumerateObjectsWithBlock:(BMC_NOESCAPE BMDiskCacheFileURLEnumerationBlock)block;

@end


#pragma mark - Deprecated

#if 0
/**
 A callback block which provides only the cache as an argument
 */
typedef void (^BMDiskCacheBlock)(BMDiskCache *cache);

@interface BMDiskCache (Deprecated)
- (void)lockFileAccessWhileExecutingBlock:(nullable BMCacheBlock)block __attribute__((deprecated));
- (void)containsObjectForKey:(NSString *)key block:(BMDiskCacheContainsBlock)block __attribute__((deprecated));
- (void)objectForKey:(NSString *)key block:(nullable BMDiskCacheObjectBlock)block __attribute__((deprecated));
- (void)fileURLForKey:(NSString *)key block:(nullable BMDiskCacheFileURLBlock)block __attribute__((deprecated));
- (void)setObject:(id <NSCoding>)object forKey:(NSString *)key block:(nullable BMDiskCacheObjectBlock)block __attribute__((deprecated));
- (void)removeObjectForKey:(NSString *)key block:(nullable BMDiskCacheObjectBlock)block __attribute__((deprecated));
- (void)trimToDate:(NSDate *)date block:(nullable BMDiskCacheBlock)block __attribute__((deprecated));
- (void)trimToSize:(NSUInteger)byteCount block:(nullable BMDiskCacheBlock)block __attribute__((deprecated));
- (void)trimToSizeByDate:(NSUInteger)byteCount block:(nullable BMDiskCacheBlock)block __attribute__((deprecated));
- (void)removeAllObjects:(nullable BMDiskCacheBlock)block __attribute__((deprecated));
- (void)enumerateObjectsWithBlock:(BMDiskCacheFileURLBlock)block completionBlock:(nullable BMDiskCacheBlock)completionBlock __attribute__((deprecated));
- (void)setTtlCache:(BOOL)ttlCache DEPRECATED_MSG_ATTRIBUTE("ttlCache is no longer a settable property and must now be set via initializer.");

@end
#endif

NS_ASSUME_NONNULL_END
