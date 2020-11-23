//
//  BMCache.m
//  BMKit
//
//  Created by jiang deng on 2020/10/26.
//  Copyright © 2020 DennisDeng. All rights reserved.
//

#import "BMCache.h"
#import "BMCacheOperation.h"

static NSString * const BMCachePrefix = @"com.BMCache";
static NSString * const BMCacheSharedName = @"BMCacheShared";

@interface BMCache ()

@property (copy, nonatomic) NSString *name;
@property (strong, nonatomic) BMCacheOperationQueue *operationQueue;

@end

@implementation BMCache

#pragma mark - Initialization -

- (instancetype)init
{
    @throw [NSException exceptionWithName:@"Must initialize with a name" reason:@"PINCache must be initialized with a name. Call initWithName: instead." userInfo:nil];
    return [self initWithName:@""];
}

- (instancetype)initWithName:(NSString *)name
{
    return [self initWithName:name rootPath:[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject]];
}

- (instancetype)initWithName:(NSString *)name rootPath:(NSString *)rootPath
{
    return [self initWithName:name rootPath:rootPath serializer:nil deserializer:nil];
}

- (instancetype)initWithName:(NSString *)name rootPath:(NSString *)rootPath serializer:(BMDiskCacheSerializerBlock)serializer deserializer:(BMDiskCacheDeserializerBlock)deserializer {
    return [self initWithName:name rootPath:rootPath serializer:serializer deserializer:deserializer keyEncoder:nil keyDecoder:nil];
}

- (instancetype)initWithName:(NSString *)name
                    rootPath:(NSString *)rootPath
                  serializer:(BMDiskCacheSerializerBlock)serializer
                deserializer:(BMDiskCacheDeserializerBlock)deserializer
                  keyEncoder:(BMDiskCacheKeyEncoderBlock)keyEncoder
                  keyDecoder:(BMDiskCacheKeyDecoderBlock)keyDecoder
{
    return [self initWithName:name rootPath:rootPath serializer:serializer deserializer:deserializer keyEncoder:keyEncoder keyDecoder:keyDecoder ttlCache:NO];
}

- (instancetype)initWithName:(NSString *)name
                    rootPath:(NSString *)rootPath
                  serializer:(BMDiskCacheSerializerBlock)serializer
                deserializer:(BMDiskCacheDeserializerBlock)deserializer
                  keyEncoder:(BMDiskCacheKeyEncoderBlock)keyEncoder
                  keyDecoder:(BMDiskCacheKeyDecoderBlock)keyDecoder
                    ttlCache:(BOOL)ttlCache
{
    if (!name)
        return nil;
    
    if (self = [super init]) {
        _name = [name copy];
      
        //10 may actually be a bit high, but currently much of our threads are blocked on empyting the trash. Until we can resolve that, lets bump this up.
        _operationQueue = [[BMCacheOperationQueue alloc] initWithMaxConcurrentOperations:10];
        _diskCache = [[BMDiskCache alloc] initWithName:_name
                                                 prefix:BMDiskCachePrefix
                                               rootPath:rootPath
                                             serializer:serializer
                                           deserializer:deserializer
                                             keyEncoder:keyEncoder
                                             keyDecoder:keyDecoder
                                         operationQueue:_operationQueue
                                               ttlCache:ttlCache];
        _memoryCache = [[BMMemoryCache alloc] initWithName:_name operationQueue:_operationQueue ttlCache:ttlCache];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"%@.%@.%p", BMCachePrefix, _name, (void *)self];
}

+ (BMCache *)sharedCache
{
    static BMCache *cache;
    static dispatch_once_t predicate;
    
    dispatch_once(&predicate, ^{
        cache = [[BMCache alloc] initWithName:BMCacheSharedName];
    });
    
    return cache;
}

#pragma mark - Public Asynchronous Methods -

- (void)containsObjectForKeyAsync:(NSString *)key completion:(BMCacheObjectContainmentBlock)block
{
    if (!key || !block) {
        return;
    }
  
    [self.operationQueue scheduleOperation:^{
        BOOL containsObject = [self containsObjectForKey:key];
        block(containsObject);
    }];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wshadow"

- (void)objectForKeyAsync:(NSString *)key completion:(BMCacheObjectBlock)block
{
    if (!key || !block)
        return;
    
    [self.operationQueue scheduleOperation:^{
        [self->_memoryCache objectForKeyAsync:key completion:^(id<BMCacheProtocol> memoryCache, NSString *memoryCacheKey, id memoryCacheObject) {
            if (memoryCacheObject) {
                // Update file modification date. TODO: make this a separate method?
                [self->_diskCache fileURLForKeyAsync:memoryCacheKey completion:^(NSString * _Nonnull key, NSURL * _Nullable fileURL) {}];
                [self->_operationQueue scheduleOperation:^{
                    block(self, memoryCacheKey, memoryCacheObject);
                }];
            } else {
                [self->_diskCache objectForKeyAsync:memoryCacheKey completion:^(BMDiskCache *diskCache, NSString *diskCacheKey, id <NSCoding> diskCacheObject) {
                    
                    [self->_memoryCache setObjectAsync:diskCacheObject forKey:diskCacheKey completion:nil];
                    
                    [self->_operationQueue scheduleOperation:^{
                        block(self, diskCacheKey, diskCacheObject);
                    }];
                }];
            }
        }];
    }];
}

#pragma clang diagnostic pop

- (void)setObjectAsync:(id <NSCoding>)object forKey:(NSString *)key completion:(BMCacheObjectBlock)block
{
    [self setObjectAsync:object forKey:key withCost:0 completion:block];
}

- (void)setObjectAsync:(id <NSCoding>)object forKey:(NSString *)key withAgeLimit:(NSTimeInterval)ageLimit completion:(BMCacheObjectBlock)block
{
    [self setObjectAsync:object forKey:key withCost:0 ageLimit:ageLimit completion:block];
}

- (void)setObjectAsync:(id <NSCoding>)object forKey:(NSString *)key withCost:(NSUInteger)cost completion:(BMCacheObjectBlock)block
{
    [self setObjectAsync:object forKey:key withCost:cost ageLimit:0.0 completion:block];
}

- (void)setObjectAsync:(nonnull id)object forKey:(nonnull NSString *)key withCost:(NSUInteger)cost ageLimit:(NSTimeInterval)ageLimit completion:(nullable BMCacheObjectBlock)block
{
    if (!key || !object)
        return;
  
    BMCacheOperationGroup *group = [BMCacheOperationGroup asyncOperationGroupWithQueue:_operationQueue];
    
    [group addOperation:^{
        [self->_memoryCache setObject:object forKey:key withCost:cost ageLimit:ageLimit];
    }];
    [group addOperation:^{
        [self->_diskCache setObject:object forKey:key withAgeLimit:ageLimit];
    }];
  
    if (block) {
        [group setCompletion:^{
            block(self, key, object);
        }];
    }
    
    [group start];
}

- (void)removeObjectForKeyAsync:(NSString *)key completion:(BMCacheObjectBlock)block
{
    if (!key)
        return;
    
    BMCacheOperationGroup *group = [BMCacheOperationGroup asyncOperationGroupWithQueue:_operationQueue];
    
    [group addOperation:^{
        [self->_memoryCache removeObjectForKey:key];
    }];
    [group addOperation:^{
        [self->_diskCache removeObjectForKey:key];
    }];

    if (block) {
        [group setCompletion:^{
            block(self, key, nil);
        }];
    }
    
    [group start];
}

- (void)removeAllObjectsAsync:(BMCacheBlock)block
{
    BMCacheOperationGroup *group = [BMCacheOperationGroup asyncOperationGroupWithQueue:_operationQueue];
    
    [group addOperation:^{
        [self->_memoryCache removeAllObjects];
    }];
    [group addOperation:^{
        [self->_diskCache removeAllObjects];
    }];

    if (block) {
        [group setCompletion:^{
            block(self);
        }];
    }
    
    [group start];
}

- (void)trimToDateAsync:(NSDate *)date completion:(BMCacheBlock)block
{
    if (!date)
        return;
    
    BMCacheOperationGroup *group = [BMCacheOperationGroup asyncOperationGroupWithQueue:_operationQueue];
    
    [group addOperation:^{
        [self->_memoryCache trimToDate:date];
    }];
    [group addOperation:^{
        [self->_diskCache trimToDate:date];
    }];
  
    if (block) {
        [group setCompletion:^{
            block(self);
        }];
    }
    
    [group start];
}

- (void)removeExpiredObjectsAsync:(BMCacheBlock)block
{
    BMCacheOperationGroup *group = [BMCacheOperationGroup asyncOperationGroupWithQueue:_operationQueue];

    [group addOperation:^{
        [self->_memoryCache removeExpiredObjects];
    }];
    [group addOperation:^{
        [self->_diskCache removeExpiredObjects];
    }];

    if (block) {
        [group setCompletion:^{
            block(self);
        }];
    }

    [group start];
}

#pragma mark - Public Synchronous Accessors -

- (NSUInteger)diskByteCount
{
    __block NSUInteger byteCount = 0;
    
    [_diskCache synchronouslyLockFileAccessWhileExecutingBlock:^(id<BMCacheProtocol> diskCache) {
        byteCount = ((BMDiskCache *)diskCache).byteCount;
    }];
    
    return byteCount;
}

- (BOOL)containsObjectForKey:(NSString *)key
{
    if (!key)
        return NO;
    
    return [_memoryCache containsObjectForKey:key] || [_diskCache containsObjectForKey:key];
}

- (nullable id)objectForKey:(NSString *)key
{
    if (!key)
        return nil;
    
    __block id object = nil;

    object = [_memoryCache objectForKey:key];
    
    if (object) {
        // Update file modification date. TODO: make this a separate method?
        [_diskCache fileURLForKeyAsync:key completion:^(NSString * _Nonnull key, NSURL * _Nullable fileURL) {}];
    } else {
        object = [_diskCache objectForKey:key];
        [_memoryCache setObject:object forKey:key];
    }
    
    return object;
}

- (void)setObject:(id <NSCoding>)object forKey:(NSString *)key
{
    [self setObject:object forKey:key withCost:0];
}

- (void)setObject:(id <NSCoding>)object forKey:(NSString *)key withAgeLimit:(NSTimeInterval)ageLimit
{
    [self setObject:object forKey:key withCost:0 ageLimit:ageLimit];
}

- (void)setObject:(id <NSCoding>)object forKey:(NSString *)key withCost:(NSUInteger)cost
{
    [self setObject:object forKey:key withCost:cost ageLimit:0.0];
}

- (void)setObject:(nullable id)object forKey:(nonnull NSString *)key withCost:(NSUInteger)cost ageLimit:(NSTimeInterval)ageLimit
{
    if (!key || !object)
        return;
    
    [_memoryCache setObject:object forKey:key withCost:cost ageLimit:ageLimit];
    [_diskCache setObject:object forKey:key withAgeLimit:ageLimit];
}

- (nullable id)objectForKeyedSubscript:(NSString *)key
{
    return [self objectForKey:key];
}

- (void)setObject:(nullable id)obj forKeyedSubscript:(NSString *)key
{
    if (obj == nil) {
        [self removeObjectForKey:key];
    } else {
        [self setObject:obj forKey:key];
    }
}

- (void)removeObjectForKey:(NSString *)key
{
    if (!key)
        return;
    
    [_memoryCache removeObjectForKey:key];
    [_diskCache removeObjectForKey:key];
}

- (void)trimToDate:(NSDate *)date
{
    if (!date)
        return;
    
    [_memoryCache trimToDate:date];
    [_diskCache trimToDate:date];
}

- (void)removeExpiredObjects
{
    [_memoryCache removeExpiredObjects];
    [_diskCache removeExpiredObjects];
}

- (void)removeAllObjects
{
    [_memoryCache removeAllObjects];
    [_diskCache removeAllObjects];
}

@end

#if 0
@implementation BMCache (Deprecated)

- (void)containsObjectForKey:(NSString *)key block:(BMCacheObjectContainmentBlock)block
{
    [self containsObjectForKeyAsync:key completion:block];
}

- (void)objectForKey:(NSString *)key block:(BMCacheObjectBlock)block
{
    [self objectForKeyAsync:key completion:block];
}

- (void)setObject:(id <NSCoding>)object forKey:(NSString *)key block:(nullable BMCacheObjectBlock)block
{
    [self setObjectAsync:object forKey:key completion:block];
}

- (void)setObject:(id <NSCoding>)object forKey:(NSString *)key withCost:(NSUInteger)cost block:(nullable BMCacheObjectBlock)block
{
    [self setObjectAsync:object forKey:key withCost:cost completion:block];
}

- (void)removeObjectForKey:(NSString *)key block:(nullable BMCacheObjectBlock)block
{
    [self removeObjectForKeyAsync:key completion:block];
}

- (void)trimToDate:(NSDate *)date block:(nullable BMCacheBlock)block
{
    [self trimToDateAsync:date completion:block];
}

- (void)removeAllObjects:(nullable BMCacheBlock)block
{
    [self removeAllObjectsAsync:block];
}

@end

#endif
