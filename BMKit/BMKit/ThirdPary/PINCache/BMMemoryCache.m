//
//  BMMemoryCache.m
//  BMKit
//
//  Created by jiang deng on 2020/10/26.
//  Copyright © 2020 DennisDeng. All rights reserved.
//

#import "BMMemoryCache.h"
#import <UIKit/UIKit.h>
#import <pthread.h>
#import "BMCacheOperation.h"

static NSString * const BMMemoryCachePrefix = @"com.BMMemoryCache";
static NSString * const BMMemoryCacheSharedName = @"BMMemoryCacheSharedName";

@interface BMMemoryCache ()

@property (copy, nonatomic) NSString *name;
@property (strong, nonatomic) BMCacheOperationQueue *operationQueue;
@property (assign, nonatomic) pthread_mutex_t mutex;
@property (strong, nonatomic) NSMutableDictionary *dictionary;
@property (strong, nonatomic) NSMutableDictionary *createdDates;
@property (strong, nonatomic) NSMutableDictionary *accessDates;
@property (strong, nonatomic) NSMutableDictionary *costs;
@property (strong, nonatomic) NSMutableDictionary *ageLimits;

@end

@implementation BMMemoryCache
@synthesize name = _name;
@synthesize ageLimit = _ageLimit;
@synthesize costLimit = _costLimit;
@synthesize totalCost = _totalCost;
@synthesize ttlCache = _ttlCache;
@synthesize willAddObjectBlock = _willAddObjectBlock;
@synthesize willRemoveObjectBlock = _willRemoveObjectBlock;
@synthesize willRemoveAllObjectsBlock = _willRemoveAllObjectsBlock;
@synthesize didAddObjectBlock = _didAddObjectBlock;
@synthesize didRemoveObjectBlock = _didRemoveObjectBlock;
@synthesize didRemoveAllObjectsBlock = _didRemoveAllObjectsBlock;
@synthesize didReceiveMemoryWarningBlock = _didReceiveMemoryWarningBlock;
@synthesize didEnterBackgroundBlock = _didEnterBackgroundBlock;

#pragma mark - Initialization -

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    __unused int result = pthread_mutex_destroy(&_mutex);
    NSCAssert(result == 0, @"Failed to destroy lock in BMMemoryCache %p. Code: %d", (void *)self, result);
}

- (instancetype)init
{
    return [self initWithOperationQueue:[BMCacheOperationQueue sharedOperationQueue]];
}

- (instancetype)initWithOperationQueue:(BMCacheOperationQueue *)operationQueue
{
    return [self initWithName:BMMemoryCacheSharedName operationQueue:operationQueue];
}

- (instancetype)initWithName:(NSString *)name operationQueue:(BMCacheOperationQueue *)operationQueue
{
    return [self initWithName:name operationQueue:operationQueue ttlCache:NO];
}

- (instancetype)initWithName:(NSString *)name operationQueue:(BMCacheOperationQueue *)operationQueue ttlCache:(BOOL)ttlCache
{
    if (self = [super init]) {
        __unused int result = pthread_mutex_init(&_mutex, NULL);
        NSAssert(result == 0, @"Failed to init lock in PINMemoryCache %@. Code: %d", self, result);
        
        _name = [name copy];
        _operationQueue = operationQueue;
        _ttlCache = ttlCache;
        
        _dictionary = [[NSMutableDictionary alloc] init];
        _createdDates = [[NSMutableDictionary alloc] init];
        _accessDates = [[NSMutableDictionary alloc] init];
        _costs = [[NSMutableDictionary alloc] init];
        _ageLimits = [[NSMutableDictionary alloc] init];
        
        _willAddObjectBlock = nil;
        _willRemoveObjectBlock = nil;
        _willRemoveAllObjectsBlock = nil;
        
        _didAddObjectBlock = nil;
        _didRemoveObjectBlock = nil;
        _didRemoveAllObjectsBlock = nil;
        
        _didReceiveMemoryWarningBlock = nil;
        _didEnterBackgroundBlock = nil;
        
        _ageLimit = 0.0;
        // 内存使用最大开销限制是5M, 暂不限制
        _costLimit = 0;//5*1024*1024;
        _totalCost = 0;
        
        _removeAllObjectsOnMemoryWarning = YES;
        _removeAllObjectsOnEnteringBackground = YES;
        
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_4_0 && !TARGET_OS_WATCH
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didReceiveEnterBackgroundNotification:)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didReceiveMemoryWarningNotification:)
                                                     name:UIApplicationDidReceiveMemoryWarningNotification
                                                   object:nil];
        
#endif
    }
    return self;
}

+ (BMMemoryCache *)sharedCache
{
    static BMMemoryCache *cache;
    static dispatch_once_t predicate;
    
    dispatch_once(&predicate, ^{
        cache = [[BMMemoryCache alloc] init];
    });
    
    return cache;
}

#pragma mark - Private Methods -

- (void)didReceiveMemoryWarningNotification:(NSNotification *)notification {
    if (self.removeAllObjectsOnMemoryWarning) {
        [self removeAllObjectsAsync:nil];
    } else {
        [self removeExpiredObjects];
    }
    
    [self.operationQueue scheduleOperation:^{
        [self lock];
        BMCacheBlock didReceiveMemoryWarningBlock = self->_didReceiveMemoryWarningBlock;
        [self unlock];
        
        if (didReceiveMemoryWarningBlock)
            didReceiveMemoryWarningBlock(self);
    } withPriority:BMCOperationQueuePriorityHigh];
}

- (void)didReceiveEnterBackgroundNotification:(NSNotification *)notification
{
    if (self.removeAllObjectsOnEnteringBackground)
        [self removeAllObjectsAsync:nil];
    
    [self.operationQueue scheduleOperation:^{
        [self lock];
        BMCacheBlock didEnterBackgroundBlock = self->_didEnterBackgroundBlock;
        [self unlock];
        
        if (didEnterBackgroundBlock)
            didEnterBackgroundBlock(self);
    } withPriority:BMCOperationQueuePriorityHigh];
}

- (void)removeObjectAndExecuteBlocksForKey:(NSString *)key
{
    [self lock];
    id object = _dictionary[key];
    NSNumber *cost = _costs[key];
    BMCacheObjectBlock willRemoveObjectBlock = _willRemoveObjectBlock;
    BMCacheObjectBlock didRemoveObjectBlock = _didRemoveObjectBlock;
    [self unlock];
    
    if (willRemoveObjectBlock)
        willRemoveObjectBlock(self, key, object);
    
    [self lock];
    if (cost)
        _totalCost -= [cost unsignedIntegerValue];
    
    [_dictionary removeObjectForKey:key];
    [_createdDates removeObjectForKey:key];
    [_accessDates removeObjectForKey:key];
    [_costs removeObjectForKey:key];
    [_ageLimits removeObjectForKey:key];
    [self unlock];
    
    if (didRemoveObjectBlock)
        didRemoveObjectBlock(self, key, nil);
}

- (void)trimMemoryToDate:(NSDate *)trimDate
{
    [self lock];
    NSDictionary *createdDates = [_createdDates copy];
    NSDictionary *ageLimits = [_ageLimits copy];
    [self unlock];
    
    [createdDates enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSDate * _Nonnull createdDate, BOOL * _Nonnull stop) {
        NSTimeInterval ageLimit = [ageLimits[key] doubleValue];
        if (!createdDate || ageLimit > 0.0) {
            return;
        }
        if ([createdDate compare:trimDate] == NSOrderedAscending) { // older than trim date
            [self removeObjectAndExecuteBlocksForKey:key];
        }
    }];
}

- (void)removeExpiredObjects
{
    [self lock];
    NSDictionary<NSString *, NSDate *> *createdDates = [_createdDates copy];
    NSDictionary<NSString *, NSNumber *> *ageLimits = [_ageLimits copy];
    NSTimeInterval globalAgeLimit = self->_ageLimit;
    [self unlock];
    
    NSDate *now = [NSDate date];
    for (NSString *key in ageLimits) {
        NSDate *createdDate = createdDates[key];
        NSTimeInterval ageLimit = [ageLimits[key] doubleValue] ?: globalAgeLimit;
        if (!createdDate)
            continue;
        
        NSDate *expirationDate = [createdDate dateByAddingTimeInterval:ageLimit];
        if ([expirationDate compare:now] == NSOrderedAscending) { // Expiration date has passed
            [self removeObjectAndExecuteBlocksForKey:key];
        }
    }
}

- (void)trimToCostLimit:(NSUInteger)limit
{
    NSUInteger totalCost = 0;
    
    [self lock];
    totalCost = _totalCost;
    NSArray *keysSortedByCost = [_costs keysSortedByValueUsingSelector:@selector(compare:)];
    [self unlock];
    
    if (totalCost <= limit) {
        return;
    }
    
    for (NSString *key in [keysSortedByCost reverseObjectEnumerator]) { // costliest objects first
        [self removeObjectAndExecuteBlocksForKey:key];
        
        [self lock];
        totalCost = _totalCost;
        [self unlock];
        
        if (totalCost <= limit)
            break;
    }
}

- (void)trimToCostLimitByDate:(NSUInteger)limit
{
    if (self.isTTLCache) {
        [self removeExpiredObjects];
    }
    
    NSUInteger totalCost = 0;
    
    [self lock];
    totalCost = _totalCost;
    NSArray *keysSortedByAccessDate = [_accessDates keysSortedByValueUsingSelector:@selector(compare:)];
    [self unlock];
    
    if (totalCost <= limit)
        return;
    
    for (NSString *key in keysSortedByAccessDate) { // oldest objects first
        [self removeObjectAndExecuteBlocksForKey:key];
        
        [self lock];
        totalCost = _totalCost;
        [self unlock];
        if (totalCost <= limit)
            break;
    }
}

- (void)trimToAgeLimitRecursively
{
    [self lock];
    NSTimeInterval ageLimit = _ageLimit;
    [self unlock];
    
    if (ageLimit == 0.0)
        return;
    
    NSDate *date = [[NSDate alloc] initWithTimeIntervalSinceNow:-ageLimit];
    
    [self trimMemoryToDate:date];
    
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(ageLimit * NSEC_PER_SEC));
    dispatch_after(time, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        // Ensure that ageLimit is the same as when we were scheduled, otherwise, we've been
        // rescheduled (another dispatch_after was issued) and should cancel.
        BOOL shouldReschedule = YES;
        [self lock];
        if (ageLimit != self->_ageLimit) {
            shouldReschedule = NO;
        }
        [self unlock];
        
        if (shouldReschedule) {
            [self.operationQueue scheduleOperation:^{
                [self trimToAgeLimitRecursively];
            } withPriority:BMCOperationQueuePriorityLow];
        }
    });
}

#pragma mark - Public Asynchronous Methods -

- (void)containsObjectForKeyAsync:(NSString *)key completion:(BMCacheObjectContainmentBlock)block
{
    if (!key || !block)
        return;
    
    [self.operationQueue scheduleOperation:^{
        BOOL containsObject = [self containsObjectForKey:key];
        
        block(containsObject);
    } withPriority:BMCOperationQueuePriorityHigh];
}

- (void)objectForKeyAsync:(NSString *)key completion:(BMCacheObjectBlock)block
{
    if (block == nil) {
        return;
    }
    
    [self.operationQueue scheduleOperation:^{
        id object = [self objectForKey:key];
        
        block(self, key, object);
    } withPriority:BMCOperationQueuePriorityHigh];
}

- (void)setObjectAsync:(id)object forKey:(NSString *)key completion:(BMCacheObjectBlock)block
{
    [self setObjectAsync:object forKey:key withCost:0 completion:block];
}

- (void)setObjectAsync:(id)object forKey:(NSString *)key withAgeLimit:(NSTimeInterval)ageLimit completion:(BMCacheObjectBlock)block
{
    [self setObjectAsync:object forKey:key withCost:0 ageLimit:ageLimit completion:block];
}

- (void)setObjectAsync:(id)object forKey:(NSString *)key withCost:(NSUInteger)cost completion:(BMCacheObjectBlock)block
{
    [self setObjectAsync:object forKey:key withCost:cost ageLimit:0.0 completion:block];
}

- (void)setObjectAsync:(id)object forKey:(NSString *)key withCost:(NSUInteger)cost ageLimit:(NSTimeInterval)ageLimit completion:(BMCacheObjectBlock)block
{
    [self.operationQueue scheduleOperation:^{
        [self setObject:object forKey:key withCost:cost ageLimit:ageLimit];
        
        if (block)
            block(self, key, object);
    } withPriority:BMCOperationQueuePriorityHigh];
}

- (void)removeObjectForKeyAsync:(NSString *)key completion:(BMCacheObjectBlock)block
{
    [self.operationQueue scheduleOperation:^{
        [self removeObjectForKey:key];
        
        if (block)
            block(self, key, nil);
    } withPriority:BMCOperationQueuePriorityLow];
}

- (void)trimToDateAsync:(NSDate *)trimDate completion:(BMCacheBlock)block
{
    [self.operationQueue scheduleOperation:^{
        [self trimToDate:trimDate];
        
        if (block)
            block(self);
    } withPriority:BMCOperationQueuePriorityLow];
}

- (void)trimToCostAsync:(NSUInteger)cost completion:(BMCacheBlock)block
{
    [self.operationQueue scheduleOperation:^{
        [self trimToCost:cost];
        
        if (block)
            block(self);
    } withPriority:BMCOperationQueuePriorityLow];
}

- (void)trimToCostByDateAsync:(NSUInteger)cost completion:(BMCacheBlock)block
{
    [self.operationQueue scheduleOperation:^{
        [self trimToCostByDate:cost];
        
        if (block)
            block(self);
    } withPriority:BMCOperationQueuePriorityLow];
}

- (void)removeExpiredObjectsAsync:(BMCacheBlock)block
{
    [self.operationQueue scheduleOperation:^{
        [self removeExpiredObjects];
        
        if (block)
            block(self);
    } withPriority:BMCOperationQueuePriorityLow];
}

- (void)removeAllObjectsAsync:(BMCacheBlock)block
{
    [self.operationQueue scheduleOperation:^{
        [self removeAllObjects];
        
        if (block)
            block(self);
    } withPriority:BMCOperationQueuePriorityLow];
}

- (void)enumerateObjectsWithBlockAsync:(BMCacheObjectEnumerationBlock)block completionBlock:(BMCacheBlock)completionBlock
{
    [self.operationQueue scheduleOperation:^{
        [self enumerateObjectsWithBlock:block];
        
        if (completionBlock)
            completionBlock(self);
    } withPriority:BMCOperationQueuePriorityLow];
}

#pragma mark - Public Synchronous Methods -

- (BOOL)containsObjectForKey:(NSString *)key
{
    if (!key)
        return NO;
    
    [self lock];
    BOOL containsObject = (_dictionary[key] != nil);
    [self unlock];
    return containsObject;
}

- (nullable id)objectForKey:(NSString *)key
{
    if (!key)
        return nil;
    
    NSDate *now = [NSDate date];
    [self lock];
    id object = nil;
    // If the cache should behave like a TTL cache, then only fetch the object if there's a valid ageLimit and  the object is still alive
    NSTimeInterval ageLimit = [_ageLimits[key] doubleValue] ?: self->_ageLimit;
    if (!self->_ttlCache || ageLimit <= 0 || fabs([[_createdDates objectForKey:key] timeIntervalSinceDate:now]) < ageLimit) {
        object = _dictionary[key];
    }
    [self unlock];
    
    if (object) {
        [self lock];
        _accessDates[key] = now;
        [self unlock];
    }
    
    return object;
}

- (id)objectForKeyedSubscript:(NSString *)key
{
    return [self objectForKey:key];
}

- (void)setObject:(id)object forKey:(NSString *)key
{
    [self setObject:object forKey:key withCost:0];
}

- (void)setObject:(id)object forKey:(NSString *)key withAgeLimit:(NSTimeInterval)ageLimit
{
    [self setObject:object forKey:key withCost:0 ageLimit:ageLimit];
}

- (void)setObject:(id)object forKeyedSubscript:(NSString *)key
{
    if (object == nil) {
        [self removeObjectForKey:key];
    } else {
        [self setObject:object forKey:key];
    }
}

- (void)setObject:(id)object forKey:(NSString *)key withCost:(NSUInteger)cost
{
    [self setObject:object forKey:key withCost:cost ageLimit:0.0];
}

- (void)setObject:(id)object forKey:(NSString *)key withCost:(NSUInteger)cost ageLimit:(NSTimeInterval)ageLimit
{
    NSAssert(ageLimit <= 0.0 || (ageLimit > 0.0 && _ttlCache), @"ttlCache must be set to YES if setting an object-level age limit.");
    
    if (!key || !object)
        return;
    
    [self lock];
    BMCacheObjectBlock willAddObjectBlock = _willAddObjectBlock;
    BMCacheObjectBlock didAddObjectBlock = _didAddObjectBlock;
    NSUInteger costLimit = _costLimit;
    [self unlock];
    
    if (willAddObjectBlock)
        willAddObjectBlock(self, key, object);
    
    [self lock];
    NSNumber* oldCost = _costs[key];
    if (oldCost)
        _totalCost -= [oldCost unsignedIntegerValue];
    
    NSDate *now = [NSDate date];
    _dictionary[key] = object;
    _createdDates[key] = now;
    _accessDates[key] = now;
    _costs[key] = @(cost);
    
    if (ageLimit > 0.0) {
        _ageLimits[key] = @(ageLimit);
    } else {
        [_ageLimits removeObjectForKey:key];
    }
    
    _totalCost += cost;
    [self unlock];
    
    if (didAddObjectBlock)
        didAddObjectBlock(self, key, object);
    
    if (costLimit > 0)
        [self trimToCostByDate:costLimit];
}

- (void)removeObjectForKey:(NSString *)key
{
    if (!key)
        return;
    
    [self removeObjectAndExecuteBlocksForKey:key];
}

- (void)trimToDate:(NSDate *)trimDate
{
    if (!trimDate)
        return;
    
    if ([trimDate isEqualToDate:[NSDate distantPast]]) {
        [self removeAllObjects];
        return;
    }
    
    [self trimMemoryToDate:trimDate];
}

- (void)trimToCost:(NSUInteger)cost
{
    [self trimToCostLimit:cost];
}

- (void)trimToCostByDate:(NSUInteger)cost
{
    [self trimToCostLimitByDate:cost];
}

- (void)removeAllObjects
{
    [self lock];
    BMCacheBlock willRemoveAllObjectsBlock = _willRemoveAllObjectsBlock;
    BMCacheBlock didRemoveAllObjectsBlock = _didRemoveAllObjectsBlock;
    [self unlock];
    
    if (willRemoveAllObjectsBlock)
        willRemoveAllObjectsBlock(self);
    
    [self lock];
    [_dictionary removeAllObjects];
    [_createdDates removeAllObjects];
    [_accessDates removeAllObjects];
    [_costs removeAllObjects];
    [_ageLimits removeAllObjects];
    
    _totalCost = 0;
    [self unlock];
    
    if (didRemoveAllObjectsBlock)
        didRemoveAllObjectsBlock(self);
    
}

- (void)enumerateObjectsWithBlock:(BMC_NOESCAPE BMCacheObjectEnumerationBlock)block
{
    if (!block)
        return;
    
    [self lock];
    NSDate *now = [NSDate date];
    NSArray *keysSortedByCreatedDate = [_createdDates keysSortedByValueUsingSelector:@selector(compare:)];
    
    for (NSString *key in keysSortedByCreatedDate) {
        // If the cache should behave like a TTL cache, then only fetch the object if there's a valid ageLimit and  the object is still alive
        NSTimeInterval ageLimit = [_ageLimits[key] doubleValue] ?: self->_ageLimit;
        if (!self->_ttlCache || ageLimit <= 0 || fabs([[_createdDates objectForKey:key] timeIntervalSinceDate:now]) < ageLimit) {
            BOOL stop = NO;
            block(self, key, _dictionary[key], &stop);
            if (stop)
                break;
        }
    }
    [self unlock];
}

#pragma mark - Public Thread Safe Accessors -

- (BMCacheObjectBlock)willAddObjectBlock
{
    [self lock];
    BMCacheObjectBlock block = _willAddObjectBlock;
    [self unlock];
    
    return block;
}

- (void)setWillAddObjectBlock:(BMCacheObjectBlock)block
{
    [self lock];
    _willAddObjectBlock = [block copy];
    [self unlock];
}

- (BMCacheObjectBlock)willRemoveObjectBlock
{
    [self lock];
    BMCacheObjectBlock block = _willRemoveObjectBlock;
    [self unlock];
    
    return block;
}

- (void)setWillRemoveObjectBlock:(BMCacheObjectBlock)block
{
    [self lock];
    _willRemoveObjectBlock = [block copy];
    [self unlock];
}

- (BMCacheBlock)willRemoveAllObjectsBlock
{
    [self lock];
    BMCacheBlock block = _willRemoveAllObjectsBlock;
    [self unlock];
    
    return block;
}

- (void)setWillRemoveAllObjectsBlock:(BMCacheBlock)block
{
    [self lock];
    _willRemoveAllObjectsBlock = [block copy];
    [self unlock];
}

- (BMCacheObjectBlock)didAddObjectBlock
{
    [self lock];
    BMCacheObjectBlock block = _didAddObjectBlock;
    [self unlock];
    
    return block;
}

- (void)setDidAddObjectBlock:(BMCacheObjectBlock)block
{
    [self lock];
    _didAddObjectBlock = [block copy];
    [self unlock];
}

- (BMCacheObjectBlock)didRemoveObjectBlock
{
    [self lock];
    BMCacheObjectBlock block = _didRemoveObjectBlock;
    [self unlock];
    
    return block;
}

- (void)setDidRemoveObjectBlock:(BMCacheObjectBlock)block
{
    [self lock];
    _didRemoveObjectBlock = [block copy];
    [self unlock];
}

- (BMCacheBlock)didRemoveAllObjectsBlock
{
    [self lock];
    BMCacheBlock block = _didRemoveAllObjectsBlock;
    [self unlock];
    
    return block;
}

- (void)setDidRemoveAllObjectsBlock:(BMCacheBlock)block
{
    [self lock];
    _didRemoveAllObjectsBlock = [block copy];
    [self unlock];
}

- (BMCacheBlock)didReceiveMemoryWarningBlock
{
    [self lock];
    BMCacheBlock block = _didReceiveMemoryWarningBlock;
    [self unlock];
    
    return block;
}

- (void)setDidReceiveMemoryWarningBlock:(BMCacheBlock)block
{
    [self lock];
    _didReceiveMemoryWarningBlock = [block copy];
    [self unlock];
}

- (BMCacheBlock)didEnterBackgroundBlock
{
    [self lock];
    BMCacheBlock block = _didEnterBackgroundBlock;
    [self unlock];
    
    return block;
}

- (void)setDidEnterBackgroundBlock:(BMCacheBlock)block
{
    [self lock];
    _didEnterBackgroundBlock = [block copy];
    [self unlock];
}

- (NSTimeInterval)ageLimit
{
    [self lock];
    NSTimeInterval ageLimit = _ageLimit;
    [self unlock];
    
    return ageLimit;
}

- (void)setAgeLimit:(NSTimeInterval)ageLimit
{
    [self lock];
    _ageLimit = ageLimit;
    [self unlock];
    
    [self trimToAgeLimitRecursively];
}

- (NSUInteger)costLimit
{
    [self lock];
    NSUInteger costLimit = _costLimit;
    [self unlock];
    
    return costLimit;
}

- (void)setCostLimit:(NSUInteger)costLimit
{
    [self lock];
    _costLimit = costLimit;
    [self unlock];
    
    if (costLimit > 0)
        [self trimToCostLimitByDate:costLimit];
}

- (NSUInteger)totalCost
{
    [self lock];
    NSUInteger cost = _totalCost;
    [self unlock];
    
    return cost;
}

- (BOOL)isTTLCache {
    BOOL isTTLCache;
    
    [self lock];
    isTTLCache = _ttlCache;
    [self unlock];
    
    return isTTLCache;
}

- (void)lock
{
    __unused int result = pthread_mutex_lock(&_mutex);
    NSAssert(result == 0, @"Failed to lock PINMemoryCache %@. Code: %d", self, result);
}

- (void)unlock
{
    __unused int result = pthread_mutex_unlock(&_mutex);
    NSAssert(result == 0, @"Failed to unlock PINMemoryCache %@. Code: %d", self, result);
}

@end


#pragma mark - Deprecated

#if 0

@implementation BMMemoryCache (Deprecated)

- (void)containsObjectForKey:(NSString *)key block:(BMMemoryCacheContainmentBlock)block
{
    [self containsObjectForKeyAsync:key completion:block];
}

- (void)objectForKey:(NSString *)key block:(nullable BMMemoryCacheObjectBlock)block
{
    [self objectForKeyAsync:key completion:^(id<BMCacheProtocol> memoryCache, NSString *memoryCacheKey, id memoryCacheObject) {
        if (block) {
            block((BMMemoryCache *)memoryCache, memoryCacheKey, memoryCacheObject);
        }
    }];
}

- (void)setObject:(id)object forKey:(NSString *)key block:(nullable BMMemoryCacheObjectBlock)block
{
    [self setObjectAsync:object forKey:key completion:^(id<BMCacheProtocol> memoryCache, NSString *memoryCacheKey, id memoryCacheObject) {
        if (block) {
            block((BMMemoryCache *)memoryCache, memoryCacheKey, memoryCacheObject);
        }
    }];
}

- (void)setObject:(id)object forKey:(NSString *)key withCost:(NSUInteger)cost block:(nullable BMMemoryCacheObjectBlock)block
{
    [self setObjectAsync:object forKey:key withCost:cost completion:^(id<BMCacheProtocol> memoryCache, NSString *memoryCacheKey, id memoryCacheObject) {
        if (block) {
            block((BMMemoryCache *)memoryCache, memoryCacheKey, memoryCacheObject);
        }
    }];
}

- (void)removeObjectForKey:(NSString *)key block:(nullable BMMemoryCacheObjectBlock)block
{
    [self removeObjectForKeyAsync:key completion:^(id<BMCacheProtocol> memoryCache, NSString *memoryCacheKey, id memoryCacheObject) {
        if (block) {
            block((BMMemoryCache *)memoryCache, memoryCacheKey, memoryCacheObject);
        }
    }];
}

- (void)trimToDate:(NSDate *)date block:(nullable BMMemoryCacheBlock)block
{
    [self trimToDateAsync:date completion:^(id<BMCacheProtocol> memoryCache) {
        if (block) {
            block((BMMemoryCache *)memoryCache);
        }
    }];
}

- (void)trimToCost:(NSUInteger)cost block:(nullable BMMemoryCacheBlock)block
{
    [self trimToCostAsync:cost completion:^(id<BMCacheProtocol> memoryCache) {
        if (block) {
            block((BMMemoryCache *)memoryCache);
        }
    }];
}

- (void)trimToCostByDate:(NSUInteger)cost block:(nullable BMMemoryCacheBlock)block
{
    [self trimToCostByDateAsync:cost completion:^(id<BMCacheProtocol> memoryCache) {
        if (block) {
            block((BMMemoryCache *)memoryCache);
        }
    }];
}

- (void)removeAllObjects:(nullable BMMemoryCacheBlock)block
{
    [self removeAllObjectsAsync:^(id<BMCacheProtocol> memoryCache) {
        if (block) {
            block((BMMemoryCache *)memoryCache);
        }
    }];
}

- (void)enumerateObjectsWithBlock:(BMMemoryCacheObjectBlock)block completionBlock:(nullable BMMemoryCacheBlock)completionBlock
{
    [self enumerateObjectsWithBlockAsync:^(id<BMCacheProtocol> _Nonnull cache, NSString * _Nonnull key, id _Nullable object, BOOL * _Nonnull stop) {
        if ([cache isKindOfClass:[BMMemoryCache class]]) {
            BMMemoryCache *memoryCache = (BMMemoryCache *)cache;
            block(memoryCache, key, object);
        }
    } completionBlock:^(id<BMCacheProtocol> memoryCache) {
        if (completionBlock) {
            completionBlock((BMMemoryCache *)memoryCache);
        }
    }];
}

- (void)setTtlCache:(BOOL)ttlCache
{
    [self lock];
    _ttlCache = ttlCache;
    [self unlock];
}

@end

#endif
