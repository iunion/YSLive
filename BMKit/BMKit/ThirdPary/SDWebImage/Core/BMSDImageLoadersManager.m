/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "BMSDImageLoadersManager.h"
#import "BMSDWebImageDownloader.h"
#import "BMSDInternalMacros.h"

@interface BMSDImageLoadersManager ()

@property (nonatomic, strong, nonnull) dispatch_semaphore_t loadersLock;

@end

@implementation BMSDImageLoadersManager
{
    NSMutableArray<id<BMSDImageLoader>>* _imageLoaders;
}

+ (BMSDImageLoadersManager *)sharedManager {
    static dispatch_once_t onceToken;
    static BMSDImageLoadersManager *manager;
    dispatch_once(&onceToken, ^{
        manager = [[BMSDImageLoadersManager alloc] init];
    });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        // initialize with default image loaders
        _imageLoaders = [NSMutableArray arrayWithObject:[BMSDWebImageDownloader sharedDownloader]];
        _loadersLock = dispatch_semaphore_create(1);
    }
    return self;
}

- (NSArray<id<BMSDImageLoader>> *)loaders {
    BMSD_LOCK(self.loadersLock);
    NSArray<id<BMSDImageLoader>>* loaders = [_imageLoaders copy];
    BMSD_UNLOCK(self.loadersLock);
    return loaders;
}

- (void)setLoaders:(NSArray<id<BMSDImageLoader>> *)loaders {
    BMSD_LOCK(self.loadersLock);
    [_imageLoaders removeAllObjects];
    if (loaders.count) {
        [_imageLoaders addObjectsFromArray:loaders];
    }
    BMSD_UNLOCK(self.loadersLock);
}

#pragma mark - Loader Property

- (void)addLoader:(id<BMSDImageLoader>)loader {
    if (![loader conformsToProtocol:@protocol(BMSDImageLoader)]) {
        return;
    }
    BMSD_LOCK(self.loadersLock);
    [_imageLoaders addObject:loader];
    BMSD_UNLOCK(self.loadersLock);
}

- (void)removeLoader:(id<BMSDImageLoader>)loader {
    if (![loader conformsToProtocol:@protocol(BMSDImageLoader)]) {
        return;
    }
    BMSD_LOCK(self.loadersLock);
    [_imageLoaders removeObject:loader];
    BMSD_UNLOCK(self.loadersLock);
}

#pragma mark - SDImageLoader

- (BOOL)canRequestImageForURL:(nullable NSURL *)url {
    NSArray<id<BMSDImageLoader>> *loaders = self.loaders;
    for (id<BMSDImageLoader> loader in loaders.reverseObjectEnumerator) {
        if ([loader canRequestImageForURL:url]) {
            return YES;
        }
    }
    return NO;
}

- (id<BMSDWebImageOperation>)requestImageWithURL:(NSURL *)url host:(NSString *)host options:(BMSDWebImageOptions)options context:(BMSDWebImageContext *)context progress:(BMSDImageLoaderProgressBlock)progressBlock completed:(BMSDImageLoaderCompletedBlock)completedBlock {
    if (!url) {
        return nil;
    }
    NSArray<id<BMSDImageLoader>> *loaders = self.loaders;
    for (id<BMSDImageLoader> loader in loaders.reverseObjectEnumerator) {
        if ([loader canRequestImageForURL:url]) {
            return [loader requestImageWithURL:url host:host options:options context:context progress:progressBlock completed:completedBlock];
        }
    }
    return nil;
}

- (BOOL)shouldBlockFailedURLWithURL:(NSURL *)url error:(NSError *)error {
    NSArray<id<BMSDImageLoader>> *loaders = self.loaders;
    for (id<BMSDImageLoader> loader in loaders.reverseObjectEnumerator) {
        if ([loader canRequestImageForURL:url]) {
            return [loader shouldBlockFailedURLWithURL:url error:error];
        }
    }
    return NO;
}

@end
