/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "BMSDImageCachesManager.h"
#import "BMSDImageCachesManagerOperation.h"
#import "BMSDImageCache.h"
#import "BMSDInternalMacros.h"

@interface BMSDImageCachesManager ()

@property (nonatomic, strong, nonnull) NSMutableArray<id<BMSDImageCache>> *imageCaches;

@end

@implementation BMSDImageCachesManager {
    BMSD_LOCK_DECLARE(_cachesLock);
}

+ (BMSDImageCachesManager *)sharedManager {
    static dispatch_once_t onceToken;
    static BMSDImageCachesManager *manager;
    dispatch_once(&onceToken, ^{
        manager = [[BMSDImageCachesManager alloc] init];
    });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.queryOperationPolicy = BMSDImageCachesManagerOperationPolicySerial;
        self.storeOperationPolicy = BMSDImageCachesManagerOperationPolicyHighestOnly;
        self.removeOperationPolicy = BMSDImageCachesManagerOperationPolicyConcurrent;
        self.containsOperationPolicy = BMSDImageCachesManagerOperationPolicySerial;
        self.clearOperationPolicy = BMSDImageCachesManagerOperationPolicyConcurrent;
        // initialize with default image caches
        _imageCaches = [NSMutableArray arrayWithObject:[BMSDImageCache sharedImageCache]];
        BMSD_LOCK_INIT(_cachesLock);
    }
    return self;
}

- (NSArray<id<BMSDImageCache>> *)caches {
    BMSD_LOCK(_cachesLock);
    NSArray<id<BMSDImageCache>> *caches = [_imageCaches copy];
    BMSD_UNLOCK(_cachesLock);
    return caches;
}

- (void)setCaches:(NSArray<id<BMSDImageCache>> *)caches {
    BMSD_LOCK(_cachesLock);
    [_imageCaches removeAllObjects];
    if (caches.count) {
        [_imageCaches addObjectsFromArray:caches];
    }
    BMSD_UNLOCK(_cachesLock);
}

#pragma mark - Cache IO operations

- (void)addCache:(id<BMSDImageCache>)cache {
    if (![cache conformsToProtocol:@protocol(BMSDImageCache)]) {
        return;
    }
    BMSD_LOCK(_cachesLock);
    [_imageCaches addObject:cache];
    BMSD_UNLOCK(_cachesLock);
}

- (void)removeCache:(id<BMSDImageCache>)cache {
    if (![cache conformsToProtocol:@protocol(BMSDImageCache)]) {
        return;
    }
    BMSD_LOCK(_cachesLock);
    [_imageCaches removeObject:cache];
    BMSD_UNLOCK(_cachesLock);
}

#pragma mark - SDImageCache

- (id<BMSDWebImageOperation>)queryImageForKey:(NSString *)key options:(BMSDWebImageOptions)options context:(BMSDWebImageContext *)context completion:(BMSDImageCacheQueryCompletionBlock)completionBlock {
    return [self queryImageForKey:key options:options context:context cacheType:BMSDImageCacheTypeAll completion:completionBlock];
}

- (id<BMSDWebImageOperation>)queryImageForKey:(NSString *)key options:(BMSDWebImageOptions)options context:(BMSDWebImageContext *)context cacheType:(BMSDImageCacheType)cacheType completion:(BMSDImageCacheQueryCompletionBlock)completionBlock {
    if (!key) {
        return nil;
    }
    NSArray<id<BMSDImageCache>> *caches = self.caches;
    NSUInteger count = caches.count;
    if (count == 0) {
        return nil;
    } else if (count == 1) {
        return [caches.firstObject queryImageForKey:key options:options context:context cacheType:cacheType completion:completionBlock];
    }
    switch (self.queryOperationPolicy) {
        case BMSDImageCachesManagerOperationPolicyHighestOnly: {
            id<BMSDImageCache> cache = caches.lastObject;
            return [cache queryImageForKey:key options:options context:context cacheType:cacheType completion:completionBlock];
        }
            break;
        case BMSDImageCachesManagerOperationPolicyLowestOnly: {
            id<BMSDImageCache> cache = caches.firstObject;
            return [cache queryImageForKey:key options:options context:context cacheType:cacheType completion:completionBlock];
        }
            break;
        case BMSDImageCachesManagerOperationPolicyConcurrent: {
            BMSDImageCachesManagerOperation *operation = [BMSDImageCachesManagerOperation new];
            [operation beginWithTotalCount:caches.count];
            [self concurrentQueryImageForKey:key options:options context:context cacheType:cacheType completion:completionBlock enumerator:caches.reverseObjectEnumerator operation:operation];
            return operation;
        }
            break;
        case BMSDImageCachesManagerOperationPolicySerial: {
            BMSDImageCachesManagerOperation *operation = [BMSDImageCachesManagerOperation new];
            [operation beginWithTotalCount:caches.count];
            [self serialQueryImageForKey:key options:options context:context cacheType:cacheType completion:completionBlock enumerator:caches.reverseObjectEnumerator operation:operation];
            return operation;
        }
            break;
        default:
            return nil;
            break;
    }
}

- (void)storeImage:(UIImage *)image imageData:(NSData *)imageData forKey:(NSString *)key cacheType:(BMSDImageCacheType)cacheType completion:(BMSDWebImageNoParamsBlock)completionBlock {
    if (!key) {
        return;
    }
    NSArray<id<BMSDImageCache>> *caches = self.caches;
    NSUInteger count = caches.count;
    if (count == 0) {
        return;
    } else if (count == 1) {
        [caches.firstObject storeImage:image imageData:imageData forKey:key cacheType:cacheType completion:completionBlock];
        return;
    }
    switch (self.storeOperationPolicy) {
        case BMSDImageCachesManagerOperationPolicyHighestOnly: {
            id<BMSDImageCache> cache = caches.lastObject;
            [cache storeImage:image imageData:imageData forKey:key cacheType:cacheType completion:completionBlock];
        }
            break;
        case BMSDImageCachesManagerOperationPolicyLowestOnly: {
            id<BMSDImageCache> cache = caches.firstObject;
            [cache storeImage:image imageData:imageData forKey:key cacheType:cacheType completion:completionBlock];
        }
            break;
        case BMSDImageCachesManagerOperationPolicyConcurrent: {
            BMSDImageCachesManagerOperation *operation = [BMSDImageCachesManagerOperation new];
            [operation beginWithTotalCount:caches.count];
            [self concurrentStoreImage:image imageData:imageData forKey:key cacheType:cacheType completion:completionBlock enumerator:caches.reverseObjectEnumerator operation:operation];
        }
            break;
        case BMSDImageCachesManagerOperationPolicySerial: {
            [self serialStoreImage:image imageData:imageData forKey:key cacheType:cacheType completion:completionBlock enumerator:caches.reverseObjectEnumerator];
        }
            break;
        default:
            break;
    }
}

- (void)removeImageForKey:(NSString *)key cacheType:(BMSDImageCacheType)cacheType completion:(BMSDWebImageNoParamsBlock)completionBlock {
    if (!key) {
        return;
    }
    NSArray<id<BMSDImageCache>> *caches = self.caches;
    NSUInteger count = caches.count;
    if (count == 0) {
        return;
    } else if (count == 1) {
        [caches.firstObject removeImageForKey:key cacheType:cacheType completion:completionBlock];
        return;
    }
    switch (self.removeOperationPolicy) {
        case BMSDImageCachesManagerOperationPolicyHighestOnly: {
            id<BMSDImageCache> cache = caches.lastObject;
            [cache removeImageForKey:key cacheType:cacheType completion:completionBlock];
        }
            break;
        case BMSDImageCachesManagerOperationPolicyLowestOnly: {
            id<BMSDImageCache> cache = caches.firstObject;
            [cache removeImageForKey:key cacheType:cacheType completion:completionBlock];
        }
            break;
        case BMSDImageCachesManagerOperationPolicyConcurrent: {
            BMSDImageCachesManagerOperation *operation = [BMSDImageCachesManagerOperation new];
            [operation beginWithTotalCount:caches.count];
            [self concurrentRemoveImageForKey:key cacheType:cacheType completion:completionBlock enumerator:caches.reverseObjectEnumerator operation:operation];
        }
            break;
        case BMSDImageCachesManagerOperationPolicySerial: {
            [self serialRemoveImageForKey:key cacheType:cacheType completion:completionBlock enumerator:caches.reverseObjectEnumerator];
        }
            break;
        default:
            break;
    }
}

- (void)containsImageForKey:(NSString *)key cacheType:(BMSDImageCacheType)cacheType completion:(BMSDImageCacheContainsCompletionBlock)completionBlock {
    if (!key) {
        return;
    }
    NSArray<id<BMSDImageCache>> *caches = self.caches;
    NSUInteger count = caches.count;
    if (count == 0) {
        return;
    } else if (count == 1) {
        [caches.firstObject containsImageForKey:key cacheType:cacheType completion:completionBlock];
        return;
    }
    switch (self.clearOperationPolicy) {
        case BMSDImageCachesManagerOperationPolicyHighestOnly: {
            id<BMSDImageCache> cache = caches.lastObject;
            [cache containsImageForKey:key cacheType:cacheType completion:completionBlock];
        }
            break;
        case BMSDImageCachesManagerOperationPolicyLowestOnly: {
            id<BMSDImageCache> cache = caches.firstObject;
            [cache containsImageForKey:key cacheType:cacheType completion:completionBlock];
        }
            break;
        case BMSDImageCachesManagerOperationPolicyConcurrent: {
            BMSDImageCachesManagerOperation *operation = [BMSDImageCachesManagerOperation new];
            [operation beginWithTotalCount:caches.count];
            [self concurrentContainsImageForKey:key cacheType:cacheType completion:completionBlock enumerator:caches.reverseObjectEnumerator operation:operation];
        }
            break;
        case BMSDImageCachesManagerOperationPolicySerial: {
            BMSDImageCachesManagerOperation *operation = [BMSDImageCachesManagerOperation new];
            [operation beginWithTotalCount:caches.count];
            [self serialContainsImageForKey:key cacheType:cacheType completion:completionBlock enumerator:caches.reverseObjectEnumerator operation:operation];
        }
            break;
        default:
            break;
    }
}

- (void)clearWithCacheType:(BMSDImageCacheType)cacheType completion:(BMSDWebImageNoParamsBlock)completionBlock {
    NSArray<id<BMSDImageCache>> *caches = self.caches;
    NSUInteger count = caches.count;
    if (count == 0) {
        return;
    } else if (count == 1) {
        [caches.firstObject clearWithCacheType:cacheType completion:completionBlock];
        return;
    }
    switch (self.clearOperationPolicy) {
        case BMSDImageCachesManagerOperationPolicyHighestOnly: {
            id<BMSDImageCache> cache = caches.lastObject;
            [cache clearWithCacheType:cacheType completion:completionBlock];
        }
            break;
        case BMSDImageCachesManagerOperationPolicyLowestOnly: {
            id<BMSDImageCache> cache = caches.firstObject;
            [cache clearWithCacheType:cacheType completion:completionBlock];
        }
            break;
        case BMSDImageCachesManagerOperationPolicyConcurrent: {
            BMSDImageCachesManagerOperation *operation = [BMSDImageCachesManagerOperation new];
            [operation beginWithTotalCount:caches.count];
            [self concurrentClearWithCacheType:cacheType completion:completionBlock enumerator:caches.reverseObjectEnumerator operation:operation];
        }
            break;
        case BMSDImageCachesManagerOperationPolicySerial: {
            [self serialClearWithCacheType:cacheType completion:completionBlock enumerator:caches.reverseObjectEnumerator];
        }
            break;
        default:
            break;
    }
}

#pragma mark - Concurrent Operation

- (void)concurrentQueryImageForKey:(NSString *)key options:(BMSDWebImageOptions)options context:(BMSDWebImageContext *)context cacheType:(BMSDImageCacheType)queryCacheType completion:(BMSDImageCacheQueryCompletionBlock)completionBlock enumerator:(NSEnumerator<id<BMSDImageCache>> *)enumerator operation:(BMSDImageCachesManagerOperation *)operation {
    NSParameterAssert(enumerator);
    NSParameterAssert(operation);
    for (id<BMSDImageCache> cache in enumerator) {
        [cache queryImageForKey:key options:options context:context cacheType:queryCacheType completion:^(UIImage * _Nullable image, NSData * _Nullable data, BMSDImageCacheType cacheType) {
            if (operation.isCancelled) {
                // Cancelled
                return;
            }
            if (operation.isFinished) {
                // Finished
                return;
            }
            [operation completeOne];
            if (image) {
                // Success
                [operation done];
                if (completionBlock) {
                    completionBlock(image, data, cacheType);
                }
                return;
            }
            if (operation.pendingCount == 0) {
                // Complete
                [operation done];
                if (completionBlock) {
                    completionBlock(nil, nil, BMSDImageCacheTypeNone);
                }
            }
        }];
    }
}

- (void)concurrentStoreImage:(UIImage *)image imageData:(NSData *)imageData forKey:(NSString *)key cacheType:(BMSDImageCacheType)cacheType completion:(BMSDWebImageNoParamsBlock)completionBlock enumerator:(NSEnumerator<id<BMSDImageCache>> *)enumerator operation:(BMSDImageCachesManagerOperation *)operation {
    NSParameterAssert(enumerator);
    NSParameterAssert(operation);
    for (id<BMSDImageCache> cache in enumerator) {
        [cache storeImage:image imageData:imageData forKey:key cacheType:cacheType completion:^{
            if (operation.isCancelled) {
                // Cancelled
                return;
            }
            if (operation.isFinished) {
                // Finished
                return;
            }
            [operation completeOne];
            if (operation.pendingCount == 0) {
                // Complete
                [operation done];
                if (completionBlock) {
                    completionBlock();
                }
            }
        }];
    }
}

- (void)concurrentRemoveImageForKey:(NSString *)key cacheType:(BMSDImageCacheType)cacheType completion:(BMSDWebImageNoParamsBlock)completionBlock enumerator:(NSEnumerator<id<BMSDImageCache>> *)enumerator operation:(BMSDImageCachesManagerOperation *)operation {
    NSParameterAssert(enumerator);
    NSParameterAssert(operation);
    for (id<BMSDImageCache> cache in enumerator) {
        [cache removeImageForKey:key cacheType:cacheType completion:^{
            if (operation.isCancelled) {
                // Cancelled
                return;
            }
            if (operation.isFinished) {
                // Finished
                return;
            }
            [operation completeOne];
            if (operation.pendingCount == 0) {
                // Complete
                [operation done];
                if (completionBlock) {
                    completionBlock();
                }
            }
        }];
    }
}

- (void)concurrentContainsImageForKey:(NSString *)key cacheType:(BMSDImageCacheType)cacheType completion:(BMSDImageCacheContainsCompletionBlock)completionBlock enumerator:(NSEnumerator<id<BMSDImageCache>> *)enumerator operation:(BMSDImageCachesManagerOperation *)operation {
    NSParameterAssert(enumerator);
    NSParameterAssert(operation);
    for (id<BMSDImageCache> cache in enumerator) {
        [cache containsImageForKey:key cacheType:cacheType completion:^(BMSDImageCacheType containsCacheType) {
            if (operation.isCancelled) {
                // Cancelled
                return;
            }
            if (operation.isFinished) {
                // Finished
                return;
            }
            [operation completeOne];
            if (containsCacheType != BMSDImageCacheTypeNone) {
                // Success
                [operation done];
                if (completionBlock) {
                    completionBlock(containsCacheType);
                }
                return;
            }
            if (operation.pendingCount == 0) {
                // Complete
                [operation done];
                if (completionBlock) {
                    completionBlock(BMSDImageCacheTypeNone);
                }
            }
        }];
    }
}

- (void)concurrentClearWithCacheType:(BMSDImageCacheType)cacheType completion:(BMSDWebImageNoParamsBlock)completionBlock enumerator:(NSEnumerator<id<BMSDImageCache>> *)enumerator operation:(BMSDImageCachesManagerOperation *)operation {
    NSParameterAssert(enumerator);
    NSParameterAssert(operation);
    for (id<BMSDImageCache> cache in enumerator) {
        [cache clearWithCacheType:cacheType completion:^{
            if (operation.isCancelled) {
                // Cancelled
                return;
            }
            if (operation.isFinished) {
                // Finished
                return;
            }
            [operation completeOne];
            if (operation.pendingCount == 0) {
                // Complete
                [operation done];
                if (completionBlock) {
                    completionBlock();
                }
            }
        }];
    }
}

#pragma mark - Serial Operation

- (void)serialQueryImageForKey:(NSString *)key options:(BMSDWebImageOptions)options context:(BMSDWebImageContext *)context cacheType:(BMSDImageCacheType)queryCacheType completion:(BMSDImageCacheQueryCompletionBlock)completionBlock enumerator:(NSEnumerator<id<BMSDImageCache>> *)enumerator operation:(BMSDImageCachesManagerOperation *)operation {
    NSParameterAssert(enumerator);
    NSParameterAssert(operation);
    id<BMSDImageCache> cache = enumerator.nextObject;
    if (!cache) {
        // Complete
        [operation done];
        if (completionBlock) {
            completionBlock(nil, nil, BMSDImageCacheTypeNone);
        }
        return;
    }
    @bmweakify(self);
    [cache queryImageForKey:key options:options context:context cacheType:queryCacheType completion:^(UIImage * _Nullable image, NSData * _Nullable data, BMSDImageCacheType cacheType) {
        @bmstrongify(self);
        if (operation.isCancelled) {
            // Cancelled
            return;
        }
        if (operation.isFinished) {
            // Finished
            return;
        }
        [operation completeOne];
        if (image) {
            // Success
            [operation done];
            if (completionBlock) {
                completionBlock(image, data, cacheType);
            }
            return;
        }
        // Next
        [self serialQueryImageForKey:key options:options context:context cacheType:queryCacheType completion:completionBlock enumerator:enumerator operation:operation];
    }];
}

- (void)serialStoreImage:(UIImage *)image imageData:(NSData *)imageData forKey:(NSString *)key cacheType:(BMSDImageCacheType)cacheType completion:(BMSDWebImageNoParamsBlock)completionBlock enumerator:(NSEnumerator<id<BMSDImageCache>> *)enumerator {
    NSParameterAssert(enumerator);
    id<BMSDImageCache> cache = enumerator.nextObject;
    if (!cache) {
        // Complete
        if (completionBlock) {
            completionBlock();
        }
        return;
    }
    @bmweakify(self);
    [cache storeImage:image imageData:imageData forKey:key cacheType:cacheType completion:^{
        @bmstrongify(self);
        // Next
        [self serialStoreImage:image imageData:imageData forKey:key cacheType:cacheType completion:completionBlock enumerator:enumerator];
    }];
}

- (void)serialRemoveImageForKey:(NSString *)key cacheType:(BMSDImageCacheType)cacheType completion:(BMSDWebImageNoParamsBlock)completionBlock enumerator:(NSEnumerator<id<BMSDImageCache>> *)enumerator {
    NSParameterAssert(enumerator);
    id<BMSDImageCache> cache = enumerator.nextObject;
    if (!cache) {
        // Complete
        if (completionBlock) {
            completionBlock();
        }
        return;
    }
    @bmweakify(self);
    [cache removeImageForKey:key cacheType:cacheType completion:^{
        @bmstrongify(self);
        // Next
        [self serialRemoveImageForKey:key cacheType:cacheType completion:completionBlock enumerator:enumerator];
    }];
}

- (void)serialContainsImageForKey:(NSString *)key cacheType:(BMSDImageCacheType)cacheType completion:(BMSDImageCacheContainsCompletionBlock)completionBlock enumerator:(NSEnumerator<id<BMSDImageCache>> *)enumerator operation:(BMSDImageCachesManagerOperation *)operation {
    NSParameterAssert(enumerator);
    NSParameterAssert(operation);
    id<BMSDImageCache> cache = enumerator.nextObject;
    if (!cache) {
        // Complete
        [operation done];
        if (completionBlock) {
            completionBlock(BMSDImageCacheTypeNone);
        }
        return;
    }
    @bmweakify(self);
    [cache containsImageForKey:key cacheType:cacheType completion:^(BMSDImageCacheType containsCacheType) {
        @bmstrongify(self);
        if (operation.isCancelled) {
            // Cancelled
            return;
        }
        if (operation.isFinished) {
            // Finished
            return;
        }
        [operation completeOne];
        if (containsCacheType != BMSDImageCacheTypeNone) {
            // Success
            [operation done];
            if (completionBlock) {
                completionBlock(containsCacheType);
            }
            return;
        }
        // Next
        [self serialContainsImageForKey:key cacheType:cacheType completion:completionBlock enumerator:enumerator operation:operation];
    }];
}

- (void)serialClearWithCacheType:(BMSDImageCacheType)cacheType completion:(BMSDWebImageNoParamsBlock)completionBlock enumerator:(NSEnumerator<id<BMSDImageCache>> *)enumerator {
    NSParameterAssert(enumerator);
    id<BMSDImageCache> cache = enumerator.nextObject;
    if (!cache) {
        // Complete
        if (completionBlock) {
            completionBlock();
        }
        return;
    }
    @bmweakify(self);
    [cache clearWithCacheType:cacheType completion:^{
        @bmstrongify(self);
        // Next
        [self serialClearWithCacheType:cacheType completion:completionBlock enumerator:enumerator];
    }];
}

@end
