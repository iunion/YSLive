/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "BMSDWebImageManager.h"
#import "BMSDImageCache.h"
#import "BMSDWebImageDownloader.h"
#import "UIImage+BMMetadata.h"
#import "BMSDAssociatedObject.h"
#import "BMSDWebImageError.h"
#import "BMSDInternalMacros.h"

static id<BMSDImageCache> _defaultBMImageCache;
static id<BMSDImageLoader> _defaultBMImageLoader;

@interface BMSDWebImageCombinedOperation ()

@property (assign, nonatomic, getter = isCancelled) BOOL cancelled;
@property (strong, nonatomic, readwrite, nullable) id<BMSDWebImageOperation> loaderOperation;
@property (strong, nonatomic, readwrite, nullable) id<BMSDWebImageOperation> cacheOperation;
@property (weak, nonatomic, nullable) BMSDWebImageManager *manager;

@end

@interface BMSDWebImageManager () {
    BMSD_LOCK_DECLARE(_failedURLsLock); // a lock to keep the access to `failedURLs` thread-safe
    BMSD_LOCK_DECLARE(_runningOperationsLock); // a lock to keep the access to `runningOperations` thread-safe
}

@property (strong, nonatomic, readwrite, nonnull) BMSDImageCache *imageCache;
@property (strong, nonatomic, readwrite, nonnull) id<BMSDImageLoader> imageLoader;
@property (strong, nonatomic, nonnull) NSMutableSet<NSURL *> *failedURLs;
@property (strong, nonatomic, nonnull) NSMutableSet<BMSDWebImageCombinedOperation *> *runningOperations;

@end

@implementation BMSDWebImageManager

+ (id<BMSDImageCache>)defaultImageCache {
    return _defaultBMImageCache;
}

+ (void)setDefaultImageCache:(id<BMSDImageCache>)defaultImageCache {
    if (defaultImageCache && ![defaultImageCache conformsToProtocol:@protocol(BMSDImageCache)]) {
        return;
    }
    _defaultBMImageCache = defaultImageCache;
}

+ (id<BMSDImageLoader>)defaultImageLoader {
    return _defaultBMImageLoader;
}

+ (void)setDefaultImageLoader:(id<BMSDImageLoader>)defaultImageLoader {
    if (defaultImageLoader && ![defaultImageLoader conformsToProtocol:@protocol(BMSDImageLoader)]) {
        return;
    }
    _defaultBMImageLoader = defaultImageLoader;
}

+ (nonnull instancetype)sharedManager {
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [self new];
    });
    return instance;
}

- (nonnull instancetype)init {
    id<BMSDImageCache> cache = [[self class] defaultImageCache];
    if (!cache) {
        cache = [BMSDImageCache sharedImageCache];
    }
    id<BMSDImageLoader> loader = [[self class] defaultImageLoader];
    if (!loader) {
        loader = [BMSDWebImageDownloader sharedDownloader];
    }
    return [self initWithCache:cache loader:loader];
}

- (nonnull instancetype)initWithCache:(nonnull id<BMSDImageCache>)cache loader:(nonnull id<BMSDImageLoader>)loader {
    if ((self = [super init])) {
        _imageCache = cache;
        _imageLoader = loader;
        _failedURLs = [NSMutableSet new];
        BMSD_LOCK_INIT(_failedURLsLock);
        _runningOperations = [NSMutableSet new];
        BMSD_LOCK_INIT(_runningOperationsLock);
    }
    return self;
}

- (nullable NSString *)cacheKeyForURL:(nullable NSURL *)url {
    if (!url) {
        return @"";
    }
    
    NSString *key;
    // Cache Key Filter
    id<BMSDWebImageCacheKeyFilter> cacheKeyFilter = self.cacheKeyFilter;
    if (cacheKeyFilter) {
        key = [cacheKeyFilter cacheKeyForURL:url];
    } else {
        key = url.absoluteString;
    }
    
    return key;
}

- (nullable NSString *)cacheKeyForURL:(nullable NSURL *)url context:(nullable BMSDWebImageContext *)context {
    if (!url) {
        return @"";
    }
    
    NSString *key;
    // Cache Key Filter
    id<BMSDWebImageCacheKeyFilter> cacheKeyFilter = self.cacheKeyFilter;
    if (context[BMSDWebImageContextCacheKeyFilter]) {
        cacheKeyFilter = context[BMSDWebImageContextCacheKeyFilter];
    }
    if (cacheKeyFilter) {
        key = [cacheKeyFilter cacheKeyForURL:url];
    } else {
        key = url.absoluteString;
    }
    
    // Thumbnail Key Appending
    NSValue *thumbnailSizeValue = context[BMSDWebImageContextImageThumbnailPixelSize];
    if (thumbnailSizeValue != nil) {
        CGSize thumbnailSize = CGSizeZero;
#if BMSD_MAC
        thumbnailSize = thumbnailSizeValue.sizeValue;
#else
        thumbnailSize = thumbnailSizeValue.CGSizeValue;
#endif
        BOOL preserveAspectRatio = YES;
        NSNumber *preserveAspectRatioValue = context[BMSDWebImageContextImagePreserveAspectRatio];
        if (preserveAspectRatioValue != nil) {
            preserveAspectRatio = preserveAspectRatioValue.boolValue;
        }
        key = BMSDThumbnailedKeyForKey(key, thumbnailSize, preserveAspectRatio);
    }
    
    // Transformer Key Appending
    id<BMSDImageTransformer> transformer = self.transformer;
    if (context[BMSDWebImageContextImageTransformer]) {
        transformer = context[BMSDWebImageContextImageTransformer];
        if (![transformer conformsToProtocol:@protocol(BMSDImageTransformer)]) {
            transformer = nil;
        }
    }
    if (transformer) {
        key = BMSDTransformedKeyForKey(key, transformer.transformerKey);
    }
    
    return key;
}

- (BMSDWebImageCombinedOperation *)loadImageWithURL:(NSURL *)url options:(BMSDWebImageOptions)options progress:(BMSDImageLoaderProgressBlock)progressBlock completed:(BMSDInternalCompletionBlock)completedBlock {
    return [self loadImageWithURL:url options:options context:nil progress:progressBlock completed:completedBlock];
}

// modified by Dennis
- (BMSDWebImageCombinedOperation *)loadImageWithURL:(NSURL *)url host:(nullable NSString *)host options:(BMSDWebImageOptions)options progress:(BMSDImageLoaderProgressBlock)progressBlock completed:(BMSDInternalCompletionBlock)completedBlock {
    return [self loadImageWithURL:url host:host options:options context:nil progress:progressBlock completed:completedBlock];
}

- (BMSDWebImageCombinedOperation *)loadImageWithURL:(nullable NSURL *)url
                                          options:(BMSDWebImageOptions)options
                                          context:(nullable BMSDWebImageContext *)context
                                         progress:(nullable BMSDImageLoaderProgressBlock)progressBlock
                                        completed:(nonnull BMSDInternalCompletionBlock)completedBlock {
    return [self loadImageWithURL:url host:nil options:options context:context progress:progressBlock completed:completedBlock];
}

// modified by Dennis
- (BMSDWebImageCombinedOperation *)loadImageWithURL:(nullable NSURL *)url
                                               host:(nullable NSString *)host
                                            options:(BMSDWebImageOptions)options
                                            context:(nullable BMSDWebImageContext *)context
                                           progress:(nullable BMSDImageLoaderProgressBlock)progressBlock
                                          completed:(nonnull BMSDInternalCompletionBlock)completedBlock {
    // Invoking this method without a completedBlock is pointless
    NSAssert(completedBlock != nil, @"If you mean to prefetch the image, use -[SDWebImagePrefetcher prefetchURLs] instead");

    // Very common mistake is to send the URL using NSString object instead of NSURL. For some strange reason, Xcode won't
    // throw any warning for this type mismatch. Here we failsafe this error by allowing URLs to be passed as NSString.
    if ([url isKindOfClass:NSString.class]) {
        url = [NSURL URLWithString:(NSString *)url];
    }

    // Prevents app crashing on argument type error like sending NSNull instead of NSURL
    if (![url isKindOfClass:NSURL.class]) {
        url = nil;
    }

    BMSDWebImageCombinedOperation *operation = [BMSDWebImageCombinedOperation new];
    operation.manager = self;

    BOOL isFailedUrl = NO;
    if (url) {
        BMSD_LOCK(_failedURLsLock);
        isFailedUrl = [self.failedURLs containsObject:url];
        BMSD_UNLOCK(_failedURLsLock);
    }

    if (url.absoluteString.length == 0 || (!(options & BMSDWebImageRetryFailed) && isFailedUrl)) {
        NSString *description = isFailedUrl ? @"Image url is blacklisted" : @"Image url is nil";
        NSInteger code = isFailedUrl ? BMSDWebImageErrorBlackListed : BMSDWebImageErrorInvalidURL;
        [self callCompletionBlockForOperation:operation completion:completedBlock error:[NSError errorWithDomain:BMSDWebImageErrorDomain code:code userInfo:@{NSLocalizedDescriptionKey : description}] url:url];
        return operation;
    }

    BMSD_LOCK(_runningOperationsLock);
    [self.runningOperations addObject:operation];
    BMSD_UNLOCK(_runningOperationsLock);
    
    // Preprocess the options and context arg to decide the final the result for manager
    BMSDWebImageOptionsResult *result = [self processedResultForURL:url options:options context:context];
    
    // Start the entry to load image from cache
    // modified by Dennis
    [self callCacheProcessForOperation:operation url:url host:host options:result.options context:result.context progress:progressBlock completed:completedBlock];

    return operation;
}

- (void)cancelAll {
    BMSD_LOCK(_runningOperationsLock);
    NSSet<BMSDWebImageCombinedOperation *> *copiedOperations = [self.runningOperations copy];
    BMSD_UNLOCK(_runningOperationsLock);
    [copiedOperations makeObjectsPerformSelector:@selector(cancel)]; // This will call `safelyRemoveOperationFromRunning:` and remove from the array
}

- (BOOL)isRunning {
    BOOL isRunning = NO;
    BMSD_LOCK(_runningOperationsLock);
    isRunning = (self.runningOperations.count > 0);
    BMSD_UNLOCK(_runningOperationsLock);
    return isRunning;
}

- (void)removeFailedURL:(NSURL *)url {
    if (!url) {
        return;
    }
    BMSD_LOCK(_failedURLsLock);
    [self.failedURLs removeObject:url];
    BMSD_UNLOCK(_failedURLsLock);
}

- (void)removeAllFailedURLs {
    BMSD_LOCK(_failedURLsLock);
    [self.failedURLs removeAllObjects];
    BMSD_UNLOCK(_failedURLsLock);
}

#pragma mark - Private

// Query normal cache process
// modified by Dennis
- (void)callCacheProcessForOperation:(nonnull BMSDWebImageCombinedOperation *)operation
                                 url:(nonnull NSURL *)url
                                host:(nullable NSString *)host
                             options:(BMSDWebImageOptions)options
                             context:(nullable BMSDWebImageContext *)context
                            progress:(nullable BMSDImageLoaderProgressBlock)progressBlock
                           completed:(nullable BMSDInternalCompletionBlock)completedBlock {
    // Grab the image cache to use
    id<BMSDImageCache> imageCache;
    if ([context[BMSDWebImageContextImageCache] conformsToProtocol:@protocol(BMSDImageCache)]) {
        imageCache = context[BMSDWebImageContextImageCache];
    } else {
        imageCache = self.imageCache;
    }
    // Get the query cache type
    BMSDImageCacheType queryCacheType = BMSDImageCacheTypeAll;
    if (context[BMSDWebImageContextQueryCacheType]) {
        queryCacheType = [context[BMSDWebImageContextQueryCacheType] integerValue];
    }
    
    // Check whether we should query cache
    BOOL shouldQueryCache = !BMSD_OPTIONS_CONTAINS(options, BMSDWebImageFromLoaderOnly);
    if (shouldQueryCache) {
        NSString *key = [self cacheKeyForURL:url context:context];
        @bmweakify(operation);
        operation.cacheOperation = [imageCache queryImageForKey:key options:options context:context cacheType:queryCacheType completion:^(UIImage * _Nullable cachedImage, NSData * _Nullable cachedData, BMSDImageCacheType cacheType) {
            @bmstrongify(operation);
            if (!operation || operation.isCancelled) {
                // Image combined operation cancelled by user
                [self callCompletionBlockForOperation:operation completion:completedBlock error:[NSError errorWithDomain:BMSDWebImageErrorDomain code:BMSDWebImageErrorCancelled userInfo:@{NSLocalizedDescriptionKey : @"Operation cancelled by user during querying the cache"}] url:url];
                [self safelyRemoveOperationFromRunning:operation];
                return;
            } else if (context[BMSDWebImageContextImageTransformer] && !cachedImage) {
                // Have a chance to query original cache instead of downloading
                [self callOriginalCacheProcessForOperation:operation url:url host:host options:options context:context progress:progressBlock completed:completedBlock];
                return;
            }
            
            // Continue download process
            [self callDownloadProcessForOperation:operation url:url host:host options:options context:context cachedImage:cachedImage cachedData:cachedData cacheType:cacheType progress:progressBlock completed:completedBlock];
        }];
    } else {
        // Continue download process
        // modified by Dennis
        [self callDownloadProcessForOperation:operation url:url host:host options:options context:context cachedImage:nil cachedData:nil cacheType:BMSDImageCacheTypeNone progress:progressBlock completed:completedBlock];
    }
}

// Query original cache process
// modified by Dennis
- (void)callOriginalCacheProcessForOperation:(nonnull BMSDWebImageCombinedOperation *)operation
                                         url:(nonnull NSURL *)url
                                        host:(nullable NSString *)host
                                     options:(BMSDWebImageOptions)options
                                     context:(nullable BMSDWebImageContext *)context
                                    progress:(nullable BMSDImageLoaderProgressBlock)progressBlock
                                   completed:(nullable BMSDInternalCompletionBlock)completedBlock {
    // Grab the image cache to use, choose standalone original cache firstly
    id<BMSDImageCache> imageCache;
    if ([context[BMSDWebImageContextOriginalImageCache] conformsToProtocol:@protocol(BMSDImageCache)]) {
        imageCache = context[BMSDWebImageContextOriginalImageCache];
    } else {
        // if no standalone cache available, use default cache
        if ([context[BMSDWebImageContextImageCache] conformsToProtocol:@protocol(BMSDImageCache)]) {
            imageCache = context[BMSDWebImageContextImageCache];
        } else {
            imageCache = self.imageCache;
        }
    }
    // Get the original query cache type
    BMSDImageCacheType originalQueryCacheType = BMSDImageCacheTypeDisk;
    if (context[BMSDWebImageContextOriginalQueryCacheType]) {
        originalQueryCacheType = [context[BMSDWebImageContextOriginalQueryCacheType] integerValue];
    }
    
    // Check whether we should query original cache
    BOOL shouldQueryOriginalCache = (originalQueryCacheType != BMSDImageCacheTypeNone);
    if (shouldQueryOriginalCache) {
        // Disable transformer for original cache key generation
        BMSDWebImageMutableContext *tempContext = [context mutableCopy];
        tempContext[BMSDWebImageContextImageTransformer] = [NSNull null];
        NSString *key = [self cacheKeyForURL:url context:tempContext];
        @bmweakify(operation);
        operation.cacheOperation = [imageCache queryImageForKey:key options:options context:context cacheType:originalQueryCacheType completion:^(UIImage * _Nullable cachedImage, NSData * _Nullable cachedData, BMSDImageCacheType cacheType) {
            @bmstrongify(operation);
            if (!operation || operation.isCancelled) {
                // Image combined operation cancelled by user
                [self callCompletionBlockForOperation:operation completion:completedBlock error:[NSError errorWithDomain:BMSDWebImageErrorDomain code:BMSDWebImageErrorCancelled userInfo:@{NSLocalizedDescriptionKey : @"Operation cancelled by user during querying the cache"}] url:url];
                [self safelyRemoveOperationFromRunning:operation];
                return;
            } else if (context[BMSDWebImageContextImageTransformer] && !cachedImage) {
                // Original image cache miss. Continue download process
                // modified by Dennis
                [self callDownloadProcessForOperation:operation url:url host:host options:options context:context cachedImage:nil cachedData:nil cacheType:originalQueryCacheType progress:progressBlock completed:completedBlock];
                return;
            }
                        
            // Use the store cache process instead of downloading, and ignore .refreshCached option for now
            [self callStoreCacheProcessForOperation:operation url:url options:options context:context downloadedImage:cachedImage downloadedData:cachedData finished:YES progress:progressBlock completed:completedBlock];
            
            [self safelyRemoveOperationFromRunning:operation];
        }];
    } else {
        // Continue download process
        // modified by Dennis
        [self callDownloadProcessForOperation:operation url:url host:host options:options context:context cachedImage:nil cachedData:nil cacheType:originalQueryCacheType progress:progressBlock completed:completedBlock];
    }
}

// Download process
// modified by Dennis
- (void)callDownloadProcessForOperation:(nonnull BMSDWebImageCombinedOperation *)operation
                                    url:(nonnull NSURL *)url
                                   host:(nullable NSString *)host
                                options:(BMSDWebImageOptions)options
                                context:(BMSDWebImageContext *)context
                            cachedImage:(nullable UIImage *)cachedImage
                             cachedData:(nullable NSData *)cachedData
                              cacheType:(BMSDImageCacheType)cacheType
                               progress:(nullable BMSDImageLoaderProgressBlock)progressBlock
                              completed:(nullable BMSDInternalCompletionBlock)completedBlock {
    // Grab the image loader to use
    id<BMSDImageLoader> imageLoader;
    if ([context[BMSDWebImageContextImageLoader] conformsToProtocol:@protocol(BMSDImageLoader)]) {
        imageLoader = context[BMSDWebImageContextImageLoader];
    } else {
        imageLoader = self.imageLoader;
    }
    
    // Check whether we should download image from network
    BOOL shouldDownload = !BMSD_OPTIONS_CONTAINS(options, BMSDWebImageFromCacheOnly);
    shouldDownload &= (!cachedImage || options & BMSDWebImageRefreshCached);
    shouldDownload &= (![self.delegate respondsToSelector:@selector(imageManager:shouldDownloadImageForURL:)] || [self.delegate imageManager:self shouldDownloadImageForURL:url]);
    if ([imageLoader respondsToSelector:@selector(canRequestImageForURL:options:context:)]) {
        shouldDownload &= [imageLoader canRequestImageForURL:url options:options context:context];
    } else {
        shouldDownload &= [imageLoader canRequestImageForURL:url];
    }
    if (shouldDownload) {
        if (cachedImage && options & BMSDWebImageRefreshCached) {
            // If image was found in the cache but SDWebImageRefreshCached is provided, notify about the cached image
            // AND try to re-download it in order to let a chance to NSURLCache to refresh it from server.
            [self callCompletionBlockForOperation:operation completion:completedBlock image:cachedImage data:cachedData error:nil cacheType:cacheType finished:YES url:url];
            // Pass the cached image to the image loader. The image loader should check whether the remote image is equal to the cached image.
            BMSDWebImageMutableContext *mutableContext;
            if (context) {
                mutableContext = [context mutableCopy];
            } else {
                mutableContext = [NSMutableDictionary dictionary];
            }
            mutableContext[BMSDWebImageContextLoaderCachedImage] = cachedImage;
            context = [mutableContext copy];
        }
        
        @bmweakify(operation);
        // modified by Dennis
        operation.loaderOperation = [imageLoader requestImageWithURL:url host:host options:options context:context progress:progressBlock completed:^(NSURL *imageUrl, UIImage *downloadedImage, NSData *downloadedData, NSError *error, BOOL finished) {
            @bmstrongify(operation);
            // modified by Dennis
            if (!imageUrl) {
                imageUrl = url;
            }
            if (!operation || operation.isCancelled) {
                // Image combined operation cancelled by user
                [self callCompletionBlockForOperation:operation completion:completedBlock error:[NSError errorWithDomain:BMSDWebImageErrorDomain code:BMSDWebImageErrorCancelled userInfo:@{NSLocalizedDescriptionKey : @"Operation cancelled by user during sending the request"}] url:imageUrl];
            } else if (cachedImage && options & BMSDWebImageRefreshCached && [error.domain isEqualToString:BMSDWebImageErrorDomain] && error.code == BMSDWebImageErrorCacheNotModified) {
                // Image refresh hit the NSURLCache cache, do not call the completion block
            } else if ([error.domain isEqualToString:BMSDWebImageErrorDomain] && error.code == BMSDWebImageErrorCancelled) {
                // Download operation cancelled by user before sending the request, don't block failed URL
                [self callCompletionBlockForOperation:operation completion:completedBlock error:error url:imageUrl];
            } else if (error) {
                [self callCompletionBlockForOperation:operation completion:completedBlock error:error url:imageUrl];
                BOOL shouldBlockFailedURL = [self shouldBlockFailedURLWithURL:imageUrl error:error options:options context:context];
                
                if (shouldBlockFailedURL && imageUrl) {
                    BMSD_LOCK(self->_failedURLsLock);
                    [self.failedURLs addObject:imageUrl];
                    BMSD_UNLOCK(self->_failedURLsLock);
                }
            } else {
                if ((options & BMSDWebImageRetryFailed) && imageUrl) {
                    BMSD_LOCK(self->_failedURLsLock);
                    [self.failedURLs removeObject:imageUrl];
                    BMSD_UNLOCK(self->_failedURLsLock);
                }
                // Continue store cache process
                [self callStoreCacheProcessForOperation:operation url:imageUrl options:options context:context downloadedImage:downloadedImage downloadedData:downloadedData finished:finished progress:progressBlock completed:completedBlock];
            }
            
            if (finished) {
                [self safelyRemoveOperationFromRunning:operation];
            }
        }];
    } else if (cachedImage) {
        [self callCompletionBlockForOperation:operation completion:completedBlock image:cachedImage data:cachedData error:nil cacheType:cacheType finished:YES url:url];
        [self safelyRemoveOperationFromRunning:operation];
    } else {
        // Image not in cache and download disallowed by delegate
        [self callCompletionBlockForOperation:operation completion:completedBlock image:nil data:nil error:nil cacheType:BMSDImageCacheTypeNone finished:YES url:url];
        [self safelyRemoveOperationFromRunning:operation];
    }
}

// Store cache process
- (void)callStoreCacheProcessForOperation:(nonnull BMSDWebImageCombinedOperation *)operation
                                      url:(nonnull NSURL *)url
                                  options:(BMSDWebImageOptions)options
                                  context:(BMSDWebImageContext *)context
                          downloadedImage:(nullable UIImage *)downloadedImage
                           downloadedData:(nullable NSData *)downloadedData
                                 finished:(BOOL)finished
                                 progress:(nullable BMSDImageLoaderProgressBlock)progressBlock
                                completed:(nullable BMSDInternalCompletionBlock)completedBlock {
    // Grab the image cache to use, choose standalone original cache firstly
    id<BMSDImageCache> imageCache;
    if ([context[BMSDWebImageContextOriginalImageCache] conformsToProtocol:@protocol(BMSDImageCache)]) {
        imageCache = context[BMSDWebImageContextOriginalImageCache];
    } else {
        // if no standalone cache available, use default cache
        if ([context[BMSDWebImageContextImageCache] conformsToProtocol:@protocol(BMSDImageCache)]) {
            imageCache = context[BMSDWebImageContextImageCache];
        } else {
            imageCache = self.imageCache;
        }
    }
    // the target image store cache type
    BMSDImageCacheType storeCacheType = BMSDImageCacheTypeAll;
    if (context[BMSDWebImageContextStoreCacheType]) {
        storeCacheType = [context[BMSDWebImageContextStoreCacheType] integerValue];
    }
    // the original store image cache type
    BMSDImageCacheType originalStoreCacheType = BMSDImageCacheTypeDisk;
    if (context[BMSDWebImageContextOriginalStoreCacheType]) {
        originalStoreCacheType = [context[BMSDWebImageContextOriginalStoreCacheType] integerValue];
    }
    // Disable transformer for original cache key generation
    BMSDWebImageMutableContext *tempContext = [context mutableCopy];
    tempContext[BMSDWebImageContextImageTransformer] = [NSNull null];
    NSString *key = [self cacheKeyForURL:url context:tempContext];
    id<BMSDImageTransformer> transformer = context[BMSDWebImageContextImageTransformer];
    if (![transformer conformsToProtocol:@protocol(BMSDImageTransformer)]) {
        transformer = nil;
    }
    id<BMSDWebImageCacheSerializer> cacheSerializer = context[BMSDWebImageContextCacheSerializer];
    
    BOOL shouldTransformImage = downloadedImage && transformer;
    shouldTransformImage = shouldTransformImage && (!downloadedImage.bmsd_isAnimated || (options & BMSDWebImageTransformAnimatedImage));
    shouldTransformImage = shouldTransformImage && (!downloadedImage.bmsd_isVector || (options & BMSDWebImageTransformVectorImage));
    BOOL shouldCacheOriginal = downloadedImage && finished;
    
    // if available, store original image to cache
    if (shouldCacheOriginal) {
        // normally use the store cache type, but if target image is transformed, use original store cache type instead
        BMSDImageCacheType targetStoreCacheType = shouldTransformImage ? originalStoreCacheType : storeCacheType;
        if (cacheSerializer && (targetStoreCacheType == BMSDImageCacheTypeDisk || targetStoreCacheType == BMSDImageCacheTypeAll)) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                @autoreleasepool {
                    NSData *cacheData = [cacheSerializer cacheDataWithImage:downloadedImage originalData:downloadedData imageURL:url];
                    [self storeImage:downloadedImage imageData:cacheData forKey:key imageCache:imageCache cacheType:targetStoreCacheType options:options context:context completion:^{
                        // Continue transform process
                        [self callTransformProcessForOperation:operation url:url options:options context:context originalImage:downloadedImage originalData:downloadedData finished:finished progress:progressBlock completed:completedBlock];
                    }];
                }
            });
        } else {
            [self storeImage:downloadedImage imageData:downloadedData forKey:key imageCache:imageCache cacheType:targetStoreCacheType options:options context:context completion:^{
                // Continue transform process
                [self callTransformProcessForOperation:operation url:url options:options context:context originalImage:downloadedImage originalData:downloadedData finished:finished progress:progressBlock completed:completedBlock];
            }];
        }
    } else {
        // Continue transform process
        [self callTransformProcessForOperation:operation url:url options:options context:context originalImage:downloadedImage originalData:downloadedData finished:finished progress:progressBlock completed:completedBlock];
    }
}

// Transform process
- (void)callTransformProcessForOperation:(nonnull BMSDWebImageCombinedOperation *)operation
                                     url:(nonnull NSURL *)url
                                 options:(BMSDWebImageOptions)options
                                 context:(BMSDWebImageContext *)context
                           originalImage:(nullable UIImage *)originalImage
                            originalData:(nullable NSData *)originalData
                                finished:(BOOL)finished
                                progress:(nullable BMSDImageLoaderProgressBlock)progressBlock
                               completed:(nullable BMSDInternalCompletionBlock)completedBlock {
    // Grab the image cache to use
    id<BMSDImageCache> imageCache;
    if ([context[BMSDWebImageContextImageCache] conformsToProtocol:@protocol(BMSDImageCache)]) {
        imageCache = context[BMSDWebImageContextImageCache];
    } else {
        imageCache = self.imageCache;
    }
    // the target image store cache type
    BMSDImageCacheType storeCacheType = BMSDImageCacheTypeAll;
    if (context[BMSDWebImageContextStoreCacheType]) {
        storeCacheType = [context[BMSDWebImageContextStoreCacheType] integerValue];
    }
    // transformed cache key
    NSString *key = [self cacheKeyForURL:url context:context];
    id<BMSDImageTransformer> transformer = context[BMSDWebImageContextImageTransformer];
    if (![transformer conformsToProtocol:@protocol(BMSDImageTransformer)]) {
        transformer = nil;
    }
    id<BMSDWebImageCacheSerializer> cacheSerializer = context[BMSDWebImageContextCacheSerializer];
    
    BOOL shouldTransformImage = originalImage && transformer;
    shouldTransformImage = shouldTransformImage && (!originalImage.bmsd_isAnimated || (options & BMSDWebImageTransformAnimatedImage));
    shouldTransformImage = shouldTransformImage && (!originalImage.bmsd_isVector || (options & BMSDWebImageTransformVectorImage));
    // if available, store transformed image to cache
    if (shouldTransformImage) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            @autoreleasepool {
                UIImage *transformedImage = [transformer transformedImageWithImage:originalImage forKey:key];
                if (transformedImage && finished) {
                    BOOL imageWasTransformed = ![transformedImage isEqual:originalImage];
                    NSData *cacheData;
                    // pass nil if the image was transformed, so we can recalculate the data from the image
                    if (cacheSerializer && (storeCacheType == BMSDImageCacheTypeDisk || storeCacheType == BMSDImageCacheTypeAll)) {
                        cacheData = [cacheSerializer cacheDataWithImage:transformedImage originalData:(imageWasTransformed ? nil : originalData) imageURL:url];
                    } else {
                        cacheData = (imageWasTransformed ? nil : originalData);
                    }
                    [self storeImage:transformedImage imageData:cacheData forKey:key imageCache:imageCache cacheType:storeCacheType options:options context:context completion:^{
                        [self callCompletionBlockForOperation:operation completion:completedBlock image:transformedImage data:originalData error:nil cacheType:BMSDImageCacheTypeNone finished:finished url:url];
                    }];
                } else {
                    [self callCompletionBlockForOperation:operation completion:completedBlock image:transformedImage data:originalData error:nil cacheType:BMSDImageCacheTypeNone finished:finished url:url];
                }
            }
        });
    } else {
        [self callCompletionBlockForOperation:operation completion:completedBlock image:originalImage data:originalData error:nil cacheType:BMSDImageCacheTypeNone finished:finished url:url];
    }
}

#pragma mark - Helper

- (void)safelyRemoveOperationFromRunning:(nullable BMSDWebImageCombinedOperation*)operation {
    if (!operation) {
        return;
    }
    BMSD_LOCK(_runningOperationsLock);
    [self.runningOperations removeObject:operation];
    BMSD_UNLOCK(_runningOperationsLock);
}

- (void)storeImage:(nullable UIImage *)image
         imageData:(nullable NSData *)data
            forKey:(nullable NSString *)key
        imageCache:(nonnull id<BMSDImageCache>)imageCache
         cacheType:(BMSDImageCacheType)cacheType
           options:(BMSDWebImageOptions)options
           context:(nullable BMSDWebImageContext *)context
        completion:(nullable BMSDWebImageNoParamsBlock)completion {
    BOOL waitStoreCache = BMSD_OPTIONS_CONTAINS(options, BMSDWebImageWaitStoreCache);
    // Check whether we should wait the store cache finished. If not, callback immediately
    [imageCache storeImage:image imageData:data forKey:key cacheType:cacheType completion:^{
        if (waitStoreCache) {
            if (completion) {
                completion();
            }
        }
    }];
    if (!waitStoreCache) {
        if (completion) {
            completion();
        }
    }
}

- (void)callCompletionBlockForOperation:(nullable BMSDWebImageCombinedOperation*)operation
                             completion:(nullable BMSDInternalCompletionBlock)completionBlock
                                  error:(nullable NSError *)error
                                    url:(nullable NSURL *)url {
    [self callCompletionBlockForOperation:operation completion:completionBlock image:nil data:nil error:error cacheType:BMSDImageCacheTypeNone finished:YES url:url];
}

- (void)callCompletionBlockForOperation:(nullable BMSDWebImageCombinedOperation*)operation
                             completion:(nullable BMSDInternalCompletionBlock)completionBlock
                                  image:(nullable UIImage *)image
                                   data:(nullable NSData *)data
                                  error:(nullable NSError *)error
                              cacheType:(BMSDImageCacheType)cacheType
                               finished:(BOOL)finished
                                    url:(nullable NSURL *)url {
    dispatch_main_async_bmsafe(^{
        if (completionBlock) {
            completionBlock(image, data, error, cacheType, finished, url);
        }
    });
}

- (BOOL)shouldBlockFailedURLWithURL:(nonnull NSURL *)url
                              error:(nonnull NSError *)error
                            options:(BMSDWebImageOptions)options
                            context:(nullable BMSDWebImageContext *)context {
    id<BMSDImageLoader> imageLoader;
    if ([context[BMSDWebImageContextImageLoader] conformsToProtocol:@protocol(BMSDImageLoader)]) {
        imageLoader = context[BMSDWebImageContextImageLoader];
    } else {
        imageLoader = self.imageLoader;
    }
    // Check whether we should block failed url
    BOOL shouldBlockFailedURL;
    if ([self.delegate respondsToSelector:@selector(imageManager:shouldBlockFailedURL:withError:)]) {
        shouldBlockFailedURL = [self.delegate imageManager:self shouldBlockFailedURL:url withError:error];
    } else {
        if ([imageLoader respondsToSelector:@selector(shouldBlockFailedURLWithURL:error:options:context:)]) {
            shouldBlockFailedURL = [imageLoader shouldBlockFailedURLWithURL:url error:error options:options context:context];
        } else {
            shouldBlockFailedURL = [imageLoader shouldBlockFailedURLWithURL:url error:error];
        }
    }
    
    return shouldBlockFailedURL;
}

- (BMSDWebImageOptionsResult *)processedResultForURL:(NSURL *)url options:(BMSDWebImageOptions)options context:(BMSDWebImageContext *)context {
    BMSDWebImageOptionsResult *result;
    BMSDWebImageMutableContext *mutableContext = [BMSDWebImageMutableContext dictionary];
    
    // Image Transformer from manager
    if (!context[BMSDWebImageContextImageTransformer]) {
        id<BMSDImageTransformer> transformer = self.transformer;
        [mutableContext setValue:transformer forKey:BMSDWebImageContextImageTransformer];
    }
    // Cache key filter from manager
    if (!context[BMSDWebImageContextCacheKeyFilter]) {
        id<BMSDWebImageCacheKeyFilter> cacheKeyFilter = self.cacheKeyFilter;
        [mutableContext setValue:cacheKeyFilter forKey:BMSDWebImageContextCacheKeyFilter];
    }
    // Cache serializer from manager
    if (!context[BMSDWebImageContextCacheSerializer]) {
        id<BMSDWebImageCacheSerializer> cacheSerializer = self.cacheSerializer;
        [mutableContext setValue:cacheSerializer forKey:BMSDWebImageContextCacheSerializer];
    }
    
    if (mutableContext.count > 0) {
        if (context) {
            [mutableContext addEntriesFromDictionary:context];
        }
        context = [mutableContext copy];
    }
    
    // Apply options processor
    if (self.optionsProcessor) {
        result = [self.optionsProcessor processedResultForURL:url options:options context:context];
    }
    if (!result) {
        // Use default options result
        result = [[BMSDWebImageOptionsResult alloc] initWithOptions:options context:context];
    }
    
    return result;
}

@end


@implementation BMSDWebImageCombinedOperation

- (void)cancel {
    @synchronized(self) {
        if (self.isCancelled) {
            return;
        }
        self.cancelled = YES;
        if (self.cacheOperation) {
            [self.cacheOperation cancel];
            self.cacheOperation = nil;
        }
        if (self.loaderOperation) {
            [self.loaderOperation cancel];
            self.loaderOperation = nil;
        }
        [self.manager safelyRemoveOperationFromRunning:self];
    }
}

@end
