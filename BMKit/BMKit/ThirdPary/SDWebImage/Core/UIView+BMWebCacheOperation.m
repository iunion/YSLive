/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "UIView+BMWebCacheOperation.h"
#import "objc/runtime.h"

static char loadOperationKey;

// key is strong, value is weak because operation instance is retained by SDWebImageManager's runningOperations property
// we should use lock to keep thread-safe because these method may not be accessed from main queue
typedef NSMapTable<NSString *, id<BMSDWebImageOperation>> BMSDOperationsDictionary;

@implementation UIView (BMWebCacheOperation)

- (BMSDOperationsDictionary *)bmsd_operationDictionary {
    @synchronized(self) {
        BMSDOperationsDictionary *operations = objc_getAssociatedObject(self, &loadOperationKey);
        if (operations) {
            return operations;
        }
        operations = [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsWeakMemory capacity:0];
        objc_setAssociatedObject(self, &loadOperationKey, operations, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        return operations;
    }
}

- (nullable id<BMSDWebImageOperation>)bmsd_imageLoadOperationForKey:(nullable NSString *)key  {
    id<BMSDWebImageOperation> operation;
    if (key) {
        BMSDOperationsDictionary *operationDictionary = [self bmsd_operationDictionary];
        @synchronized (self) {
            operation = [operationDictionary objectForKey:key];
        }
    }
    return operation;
}

- (void)bmsd_setImageLoadOperation:(nullable id<BMSDWebImageOperation>)operation forKey:(nullable NSString *)key {
    if (key) {
        [self bmsd_cancelImageLoadOperationWithKey:key];
        if (operation) {
            BMSDOperationsDictionary *operationDictionary = [self bmsd_operationDictionary];
            @synchronized (self) {
                [operationDictionary setObject:operation forKey:key];
            }
        }
    }
}

- (void)bmsd_cancelImageLoadOperationWithKey:(nullable NSString *)key {
    if (key) {
        // Cancel in progress downloader from queue
        BMSDOperationsDictionary *operationDictionary = [self bmsd_operationDictionary];
        id<BMSDWebImageOperation> operation;
        
        @synchronized (self) {
            operation = [operationDictionary objectForKey:key];
        }
        if (operation) {
            if ([operation conformsToProtocol:@protocol(BMSDWebImageOperation)]) {
                [operation cancel];
            }
            @synchronized (self) {
                [operationDictionary removeObjectForKey:key];
            }
        }
    }
}

- (void)bmsd_removeImageLoadOperationWithKey:(nullable NSString *)key {
    if (key) {
        BMSDOperationsDictionary *operationDictionary = [self bmsd_operationDictionary];
        @synchronized (self) {
            [operationDictionary removeObjectForKey:key];
        }
    }
}

@end
