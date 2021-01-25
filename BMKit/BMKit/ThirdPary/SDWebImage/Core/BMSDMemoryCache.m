/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "BMSDMemoryCache.h"
#import "BMSDImageCacheConfig.h"
#import "UIImage+BMMemoryCacheCost.h"
#import "BMSDInternalMacros.h"

static void * BMSDMemoryCacheContext = &BMSDMemoryCacheContext;

@interface BMSDMemoryCache <KeyType, ObjectType> () {
#if BMSD_UIKIT
    BMSD_LOCK_DECLARE(_weakCacheLock); // a lock to keep the access to `weakCache` thread-safe
#endif
}

@property (nonatomic, strong, nullable) BMSDImageCacheConfig *config;
#if BMSD_UIKIT
@property (nonatomic, strong, nonnull) NSMapTable<KeyType, ObjectType> *weakCache; // strong-weak cache
#endif
@end

@implementation BMSDMemoryCache

- (void)dealloc {
    [_config removeObserver:self forKeyPath:NSStringFromSelector(@selector(maxMemoryCost)) context:BMSDMemoryCacheContext];
    [_config removeObserver:self forKeyPath:NSStringFromSelector(@selector(maxMemoryCount)) context:BMSDMemoryCacheContext];
#if BMSD_UIKIT
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
#endif
    self.delegate = nil;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _config = [[BMSDImageCacheConfig alloc] init];
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithConfig:(BMSDImageCacheConfig *)config {
    self = [super init];
    if (self) {
        _config = config;
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    BMSDImageCacheConfig *config = self.config;
    self.totalCostLimit = config.maxMemoryCost;
    self.countLimit = config.maxMemoryCount;

    [config addObserver:self forKeyPath:NSStringFromSelector(@selector(maxMemoryCost)) options:0 context:BMSDMemoryCacheContext];
    [config addObserver:self forKeyPath:NSStringFromSelector(@selector(maxMemoryCount)) options:0 context:BMSDMemoryCacheContext];

#if BMSD_UIKIT
    self.weakCache = [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsWeakMemory capacity:0];
    BMSD_LOCK_INIT(_weakCacheLock);

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveMemoryWarning:)
                                                 name:UIApplicationDidReceiveMemoryWarningNotification
                                               object:nil];
#endif
}

// Current this seems no use on macOS (macOS use virtual memory and do not clear cache when memory warning). So we only override on iOS/tvOS platform.
#if BMSD_UIKIT
- (void)didReceiveMemoryWarning:(NSNotification *)notification {
    // Only remove cache, but keep weak cache
    [super removeAllObjects];
}

// `setObject:forKey:` just call this with 0 cost. Override this is enough
- (void)setObject:(id)obj forKey:(id)key cost:(NSUInteger)g {
    [super setObject:obj forKey:key cost:g];
    if (!self.config.shouldUseWeakMemoryCache) {
        return;
    }
    if (key && obj) {
        // Store weak cache
        BMSD_LOCK(_weakCacheLock);
        [self.weakCache setObject:obj forKey:key];
        BMSD_UNLOCK(_weakCacheLock);
    }
}

- (id)objectForKey:(id)key {
    id obj = [super objectForKey:key];
    if (!self.config.shouldUseWeakMemoryCache) {
        return obj;
    }
    if (key && !obj) {
        // Check weak cache
        BMSD_LOCK(_weakCacheLock);
        obj = [self.weakCache objectForKey:key];
        BMSD_UNLOCK(_weakCacheLock);
        if (obj) {
            // Sync cache
            NSUInteger cost = 0;
            if ([obj isKindOfClass:[UIImage class]]) {
                cost = [(UIImage *)obj bmsd_memoryCost];
            }
            [super setObject:obj forKey:key cost:cost];
        }
    }
    return obj;
}

- (void)removeObjectForKey:(id)key {
    [super removeObjectForKey:key];
    if (!self.config.shouldUseWeakMemoryCache) {
        return;
    }
    if (key) {
        // Remove weak cache
        BMSD_LOCK(_weakCacheLock);
        [self.weakCache removeObjectForKey:key];
        BMSD_UNLOCK(_weakCacheLock);
    }
}

- (void)removeAllObjects {
    [super removeAllObjects];
    if (!self.config.shouldUseWeakMemoryCache) {
        return;
    }
    // Manually remove should also remove weak cache
    BMSD_LOCK(_weakCacheLock);
    [self.weakCache removeAllObjects];
    BMSD_UNLOCK(_weakCacheLock);
}
#endif

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (context == BMSDMemoryCacheContext) {
        if ([keyPath isEqualToString:NSStringFromSelector(@selector(maxMemoryCost))]) {
            self.totalCostLimit = self.config.maxMemoryCost;
        } else if ([keyPath isEqualToString:NSStringFromSelector(@selector(maxMemoryCount))]) {
            self.countLimit = self.config.maxMemoryCount;
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end
