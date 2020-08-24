/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "BMSDImageCache.h"
#import "NSImage+BMCompatibility.h"
#import "BMSDImageCodersManager.h"
#import "BMSDImageCoderHelper.h"
#import "BMSDAnimatedImage.h"
#import "UIImage+BMMemoryCacheCost.h"
#import "UIImage+BMMetadata.h"
#import "UIImage+BMExtendedCacheData.h"

static NSString * _defaultBMDiskCacheDirectory;

@interface BMSDImageCache ()

#pragma mark - Properties
@property (nonatomic, strong, readwrite, nonnull) id<BMSDMemoryCache> memoryCache;
@property (nonatomic, strong, readwrite, nonnull) id<BMSDDiskCache> diskCache;
@property (nonatomic, copy, readwrite, nonnull) BMSDImageCacheConfig *config;
@property (nonatomic, copy, readwrite, nonnull) NSString *diskCachePath;
@property (nonatomic, strong, nullable) dispatch_queue_t ioQueue;

@end


@implementation BMSDImageCache

#pragma mark - Singleton, init, dealloc

+ (nonnull instancetype)sharedImageCache {
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [self new];
    });
    return instance;
}

+ (NSString *)defaultDiskCacheDirectory {
    if (!_defaultBMDiskCacheDirectory) {
        _defaultBMDiskCacheDirectory = [[self userCacheDirectory] stringByAppendingPathComponent:@"com.hackemist.SDImageCache"];
    }
    return _defaultBMDiskCacheDirectory;
}

+ (void)setDefaultDiskCacheDirectory:(NSString *)defaultDiskCacheDirectory {
    _defaultBMDiskCacheDirectory = [defaultDiskCacheDirectory copy];
}

- (instancetype)init {
    return [self initWithNamespace:@"default"];
}

- (nonnull instancetype)initWithNamespace:(nonnull NSString *)ns {
    return [self initWithNamespace:ns diskCacheDirectory:nil];
}

- (nonnull instancetype)initWithNamespace:(nonnull NSString *)ns
                       diskCacheDirectory:(nullable NSString *)directory {
    return [self initWithNamespace:ns diskCacheDirectory:directory config:BMSDImageCacheConfig.defaultCacheConfig];
}

- (nonnull instancetype)initWithNamespace:(nonnull NSString *)ns
                       diskCacheDirectory:(nullable NSString *)directory
                                   config:(nullable BMSDImageCacheConfig *)config {
    if ((self = [super init])) {
        NSAssert(ns, @"Cache namespace should not be nil");
        
        // Create IO serial queue
        _ioQueue = dispatch_queue_create("com.hackemist.SDImageCache", DISPATCH_QUEUE_SERIAL);
        
        if (!config) {
            config = BMSDImageCacheConfig.defaultCacheConfig;
        }
        _config = [config copy];
        
        // Init the memory cache
        NSAssert([config.memoryCacheClass conformsToProtocol:@protocol(BMSDMemoryCache)], @"Custom memory cache class must conform to `SDMemoryCache` protocol");
        _memoryCache = [[config.memoryCacheClass alloc] initWithConfig:_config];
        
        // Init the disk cache
        if (!directory) {
            // Use default disk cache directory
            directory = [self.class defaultDiskCacheDirectory];
        }
        _diskCachePath = [directory stringByAppendingPathComponent:ns];
        
        NSAssert([config.diskCacheClass conformsToProtocol:@protocol(BMSDDiskCache)], @"Custom disk cache class must conform to `SDDiskCache` protocol");
        _diskCache = [[config.diskCacheClass alloc] initWithCachePath:_diskCachePath config:_config];
        
        // Check and migrate disk cache directory if need
        [self migrateDiskCacheDirectory];

#if BMSD_UIKIT
        // Subscribe to app events
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationWillTerminate:)
                                                     name:UIApplicationWillTerminateNotification
                                                   object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidEnterBackground:)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
#endif
#if BMSD_MAC
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationWillTerminate:)
                                                     name:NSApplicationWillTerminateNotification
                                                   object:nil];
#endif
    }

    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Cache paths

- (nullable NSString *)cachePathForKey:(nullable NSString *)key {
    if (!key) {
        return nil;
    }
    return [self.diskCache cachePathForKey:key];
}

+ (nullable NSString *)userCacheDirectory {
    NSArray<NSString *> *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    return paths.firstObject;
}

- (void)migrateDiskCacheDirectory {
    if ([self.diskCache isKindOfClass:[BMSDDiskCache class]]) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            // ~/Library/Caches/com.hackemist.SDImageCache/default/
            NSString *newDefaultPath = [[[self.class userCacheDirectory] stringByAppendingPathComponent:@"com.hackemist.SDImageCache"] stringByAppendingPathComponent:@"default"];
            // ~/Library/Caches/default/com.hackemist.SDWebImageCache.default/
            NSString *oldDefaultPath = [[[self.class userCacheDirectory] stringByAppendingPathComponent:@"default"] stringByAppendingPathComponent:@"com.hackemist.SDWebImageCache.default"];
            dispatch_async(self.ioQueue, ^{
                [((BMSDDiskCache *)self.diskCache) moveCacheDirectoryFromPath:oldDefaultPath toPath:newDefaultPath];
            });
        });
    }
}

#pragma mark - Store Ops

- (void)storeImage:(nullable UIImage *)image
            forKey:(nullable NSString *)key
        completion:(nullable BMSDWebImageNoParamsBlock)completionBlock {
    [self storeImage:image imageData:nil forKey:key toDisk:YES completion:completionBlock];
}

- (void)storeImage:(nullable UIImage *)image
            forKey:(nullable NSString *)key
            toDisk:(BOOL)toDisk
        completion:(nullable BMSDWebImageNoParamsBlock)completionBlock {
    [self storeImage:image imageData:nil forKey:key toDisk:toDisk completion:completionBlock];
}

- (void)storeImage:(nullable UIImage *)image
         imageData:(nullable NSData *)imageData
            forKey:(nullable NSString *)key
            toDisk:(BOOL)toDisk
        completion:(nullable BMSDWebImageNoParamsBlock)completionBlock {
    return [self storeImage:image imageData:imageData forKey:key toMemory:YES toDisk:toDisk completion:completionBlock];
}

- (void)storeImage:(nullable UIImage *)image
         imageData:(nullable NSData *)imageData
            forKey:(nullable NSString *)key
          toMemory:(BOOL)toMemory
            toDisk:(BOOL)toDisk
        completion:(nullable BMSDWebImageNoParamsBlock)completionBlock {
    if (!image || !key) {
        if (completionBlock) {
            completionBlock();
        }
        return;
    }
    // if memory cache is enabled
    if (toMemory && self.config.shouldCacheImagesInMemory) {
        NSUInteger cost = image.bmsd_memoryCost;
        [self.memoryCache setObject:image forKey:key cost:cost];
    }
    
    if (toDisk) {
        dispatch_async(self.ioQueue, ^{
            @autoreleasepool {
                NSData *data = imageData;
                if (!data && [image conformsToProtocol:@protocol(BMSDAnimatedImage)]) {
                    // If image is custom animated image class, prefer its original animated data
                    data = [((id<BMSDAnimatedImage>)image) animatedImageData];
                }
                if (!data && image) {
                    // Check image's associated image format, may return .undefined
                    BMSDImageFormat format = image.bmsd_imageFormat;
                    if (format == BMSDImageFormatUndefined) {
                        // If image is animated, use GIF (APNG may be better, but has bugs before macOS 10.14)
                        if (image.bmsd_isAnimated) {
                            format = BMSDImageFormatGIF;
                        } else {
                            // If we do not have any data to detect image format, check whether it contains alpha channel to use PNG or JPEG format
                            if ([BMSDImageCoderHelper CGImageContainsAlpha:image.CGImage]) {
                                format = BMSDImageFormatPNG;
                            } else {
                                format = BMSDImageFormatJPEG;
                            }
                        }
                    }
                    data = [[BMSDImageCodersManager sharedManager] encodedDataWithImage:image format:format options:nil];
                }
                [self _storeImageDataToDisk:data forKey:key];
                if (image) {
                    // Check extended data
                    id extendedObject = image.bmsd_extendedObject;
                    if ([extendedObject conformsToProtocol:@protocol(NSCoding)]) {
                        NSData *extendedData;
                        if (@available(iOS 11, tvOS 11, macOS 10.13, watchOS 4, *)) {
                            NSError *error;
                            extendedData = [NSKeyedArchiver archivedDataWithRootObject:extendedObject requiringSecureCoding:NO error:&error];
                            if (error) {
                                NSLog(@"NSKeyedArchiver archive failed with error: %@", error);
                            }
                        } else {
                            @try {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                                extendedData = [NSKeyedArchiver archivedDataWithRootObject:extendedObject];
#pragma clang diagnostic pop
                            } @catch (NSException *exception) {
                                NSLog(@"NSKeyedArchiver archive failed with exception: %@", exception);
                            }
                        }
                        if (extendedData) {
                            [self.diskCache setExtendedData:extendedData forKey:key];
                        }
                    }
                }
            }
            
            if (completionBlock) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completionBlock();
                });
            }
        });
    } else {
        if (completionBlock) {
            completionBlock();
        }
    }
}

- (void)storeImageToMemory:(UIImage *)image forKey:(NSString *)key {
    if (!image || !key) {
        return;
    }
    NSUInteger cost = image.bmsd_memoryCost;
    [self.memoryCache setObject:image forKey:key cost:cost];
}

- (void)storeImageDataToDisk:(nullable NSData *)imageData
                      forKey:(nullable NSString *)key {
    if (!imageData || !key) {
        return;
    }
    
    dispatch_sync(self.ioQueue, ^{
        [self _storeImageDataToDisk:imageData forKey:key];
    });
}

// Make sure to call form io queue by caller
- (void)_storeImageDataToDisk:(nullable NSData *)imageData forKey:(nullable NSString *)key {
    if (!imageData || !key) {
        return;
    }
    
    [self.diskCache setData:imageData forKey:key];
}

#pragma mark - Query and Retrieve Ops

- (void)diskImageExistsWithKey:(nullable NSString *)key completion:(nullable BMSDImageCacheCheckCompletionBlock)completionBlock {
    dispatch_async(self.ioQueue, ^{
        BOOL exists = [self _diskImageDataExistsWithKey:key];
        if (completionBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(exists);
            });
        }
    });
}

- (BOOL)diskImageDataExistsWithKey:(nullable NSString *)key {
    if (!key) {
        return NO;
    }
    
    __block BOOL exists = NO;
    dispatch_sync(self.ioQueue, ^{
        exists = [self _diskImageDataExistsWithKey:key];
    });
    
    return exists;
}

// Make sure to call form io queue by caller
- (BOOL)_diskImageDataExistsWithKey:(nullable NSString *)key {
    if (!key) {
        return NO;
    }
    
    return [self.diskCache containsDataForKey:key];
}

- (void)diskImageDataQueryForKey:(NSString *)key completion:(BMSDImageCacheQueryDataCompletionBlock)completionBlock {
    dispatch_async(self.ioQueue, ^{
        NSData *imageData = [self diskImageDataBySearchingAllPathsForKey:key];
        if (completionBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(imageData);
            });
        }
    });
}

- (nullable NSData *)diskImageDataForKey:(nullable NSString *)key {
    if (!key) {
        return nil;
    }
    __block NSData *imageData = nil;
    dispatch_sync(self.ioQueue, ^{
        imageData = [self diskImageDataBySearchingAllPathsForKey:key];
    });
    
    return imageData;
}

- (nullable UIImage *)imageFromMemoryCacheForKey:(nullable NSString *)key {
    return [self.memoryCache objectForKey:key];
}

- (nullable UIImage *)imageFromDiskCacheForKey:(nullable NSString *)key {
    return [self imageFromDiskCacheForKey:key options:0 context:nil];
}

- (nullable UIImage *)imageFromDiskCacheForKey:(nullable NSString *)key options:(BMSDImageCacheOptions)options context:(nullable BMSDWebImageContext *)context {
    NSData *data = [self diskImageDataForKey:key];
    UIImage *diskImage = [self diskImageForKey:key data:data options:options context:context];
    if (diskImage && self.config.shouldCacheImagesInMemory) {
        NSUInteger cost = diskImage.bmsd_memoryCost;
        [self.memoryCache setObject:diskImage forKey:key cost:cost];
    }

    return diskImage;
}

- (nullable UIImage *)imageFromCacheForKey:(nullable NSString *)key {
    return [self imageFromCacheForKey:key options:0 context:nil];
}

- (nullable UIImage *)imageFromCacheForKey:(nullable NSString *)key options:(BMSDImageCacheOptions)options context:(nullable BMSDWebImageContext *)context {
    // First check the in-memory cache...
    UIImage *image = [self imageFromMemoryCacheForKey:key];
    if (image) {
        return image;
    }
    
    // Second check the disk cache...
    image = [self imageFromDiskCacheForKey:key options:options context:context];
    return image;
}

- (nullable NSData *)diskImageDataBySearchingAllPathsForKey:(nullable NSString *)key {
    if (!key) {
        return nil;
    }
    
    NSData *data = [self.diskCache dataForKey:key];
    if (data) {
        return data;
    }
    
    // Addtional cache path for custom pre-load cache
    if (self.additionalCachePathBlock) {
        NSString *filePath = self.additionalCachePathBlock(key);
        if (filePath) {
            data = [NSData dataWithContentsOfFile:filePath options:self.config.diskCacheReadingOptions error:nil];
        }
    }

    return data;
}

- (nullable UIImage *)diskImageForKey:(nullable NSString *)key {
    NSData *data = [self diskImageDataForKey:key];
    return [self diskImageForKey:key data:data];
}

- (nullable UIImage *)diskImageForKey:(nullable NSString *)key data:(nullable NSData *)data {
    return [self diskImageForKey:key data:data options:0 context:nil];
}

- (nullable UIImage *)diskImageForKey:(nullable NSString *)key data:(nullable NSData *)data options:(BMSDImageCacheOptions)options context:(BMSDWebImageContext *)context {
    if (data) {
        UIImage *image = BMSDImageCacheDecodeImageData(data, key, [[self class] imageOptionsFromCacheOptions:options], context);
        if (image) {
            // Check extended data
            NSData *extendedData = [self.diskCache extendedDataForKey:key];
            if (extendedData) {
                id extendedObject;
                if (@available(iOS 11, tvOS 11, macOS 10.13, watchOS 4, *)) {
                    NSError *error;
                    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingFromData:extendedData error:&error];
                    unarchiver.requiresSecureCoding = NO;
                    extendedObject = [unarchiver decodeTopLevelObjectForKey:NSKeyedArchiveRootObjectKey error:&error];
                    if (error) {
                        NSLog(@"NSKeyedUnarchiver unarchive failed with error: %@", error);
                    }
                } else {
                    @try {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                        extendedObject = [NSKeyedUnarchiver unarchiveObjectWithData:extendedData];
#pragma clang diagnostic pop
                    } @catch (NSException *exception) {
                        NSLog(@"NSKeyedUnarchiver unarchive failed with exception: %@", exception);
                    }
                }
                image.bmsd_extendedObject = extendedObject;
            }
        }
        return image;
    } else {
        return nil;
    }
}

- (nullable NSOperation *)queryCacheOperationForKey:(NSString *)key done:(BMSDImageCacheQueryCompletionBlock)doneBlock {
    return [self queryCacheOperationForKey:key options:0 done:doneBlock];
}

- (nullable NSOperation *)queryCacheOperationForKey:(NSString *)key options:(BMSDImageCacheOptions)options done:(BMSDImageCacheQueryCompletionBlock)doneBlock {
    return [self queryCacheOperationForKey:key options:options context:nil done:doneBlock];
}

- (nullable NSOperation *)queryCacheOperationForKey:(nullable NSString *)key options:(BMSDImageCacheOptions)options context:(nullable BMSDWebImageContext *)context done:(nullable BMSDImageCacheQueryCompletionBlock)doneBlock {
    return [self queryCacheOperationForKey:key options:options context:context cacheType:BMSDImageCacheTypeAll done:doneBlock];
}

- (nullable NSOperation *)queryCacheOperationForKey:(nullable NSString *)key options:(BMSDImageCacheOptions)options context:(nullable BMSDWebImageContext *)context cacheType:(BMSDImageCacheType)queryCacheType done:(nullable BMSDImageCacheQueryCompletionBlock)doneBlock {
    if (!key) {
        if (doneBlock) {
            doneBlock(nil, nil, BMSDImageCacheTypeNone);
        }
        return nil;
    }
    // Invalid cache type
    if (queryCacheType == BMSDImageCacheTypeNone) {
        if (doneBlock) {
            doneBlock(nil, nil, BMSDImageCacheTypeNone);
        }
        return nil;
    }
    
    // First check the in-memory cache...
    UIImage *image;
    if (queryCacheType != BMSDImageCacheTypeDisk) {
        image = [self imageFromMemoryCacheForKey:key];
    }
    
    if (image) {
        if (options & BMSDImageCacheDecodeFirstFrameOnly) {
            // Ensure static image
            Class animatedImageClass = image.class;
            if (image.bmsd_isAnimated || ([animatedImageClass isSubclassOfClass:[UIImage class]] && [animatedImageClass conformsToProtocol:@protocol(BMSDAnimatedImage)])) {
#if BMSD_MAC
                image = [[NSImage alloc] initWithCGImage:image.CGImage scale:image.scale orientation:kCGImagePropertyOrientationUp];
#else
                image = [[UIImage alloc] initWithCGImage:image.CGImage scale:image.scale orientation:image.imageOrientation];
#endif
            }
        } else if (options & BMSDImageCacheMatchAnimatedImageClass) {
            // Check image class matching
            Class animatedImageClass = image.class;
            Class desiredImageClass = context[BMSDWebImageContextAnimatedImageClass];
            if (desiredImageClass && ![animatedImageClass isSubclassOfClass:desiredImageClass]) {
                image = nil;
            }
        }
    }

    BOOL shouldQueryMemoryOnly = (queryCacheType == BMSDImageCacheTypeMemory) || (image && !(options & BMSDImageCacheQueryMemoryData));
    if (shouldQueryMemoryOnly) {
        if (doneBlock) {
            doneBlock(image, nil, BMSDImageCacheTypeMemory);
        }
        return nil;
    }
    
    // Second check the disk cache...
    NSOperation *operation = [NSOperation new];
    // Check whether we need to synchronously query disk
    // 1. in-memory cache hit & memoryDataSync
    // 2. in-memory cache miss & diskDataSync
    BOOL shouldQueryDiskSync = ((image && options & BMSDImageCacheQueryMemoryDataSync) ||
                                (!image && options & BMSDImageCacheQueryDiskDataSync));
    void(^queryDiskBlock)(void) =  ^{
        if (operation.isCancelled) {
            if (doneBlock) {
                doneBlock(nil, nil, BMSDImageCacheTypeNone);
            }
            return;
        }
        
        @autoreleasepool {
            NSData *diskData = [self diskImageDataBySearchingAllPathsForKey:key];
            UIImage *diskImage;
            BMSDImageCacheType cacheType = BMSDImageCacheTypeNone;
            if (image) {
                // the image is from in-memory cache, but need image data
                diskImage = image;
                cacheType = BMSDImageCacheTypeMemory;
            } else if (diskData) {
                cacheType = BMSDImageCacheTypeDisk;
                // decode image data only if in-memory cache missed
                diskImage = [self diskImageForKey:key data:diskData options:options context:context];
                if (diskImage && self.config.shouldCacheImagesInMemory) {
                    NSUInteger cost = diskImage.bmsd_memoryCost;
                    [self.memoryCache setObject:diskImage forKey:key cost:cost];
                }
            }
            
            if (doneBlock) {
                if (shouldQueryDiskSync) {
                    doneBlock(diskImage, diskData, cacheType);
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        doneBlock(diskImage, diskData, cacheType);
                    });
                }
            }
        }
    };
    
    // Query in ioQueue to keep IO-safe
    if (shouldQueryDiskSync) {
        dispatch_sync(self.ioQueue, queryDiskBlock);
    } else {
        dispatch_async(self.ioQueue, queryDiskBlock);
    }
    
    return operation;
}

#pragma mark - Remove Ops

- (void)removeImageForKey:(nullable NSString *)key withCompletion:(nullable BMSDWebImageNoParamsBlock)completion {
    [self removeImageForKey:key fromDisk:YES withCompletion:completion];
}

- (void)removeImageForKey:(nullable NSString *)key fromDisk:(BOOL)fromDisk withCompletion:(nullable BMSDWebImageNoParamsBlock)completion {
    [self removeImageForKey:key fromMemory:YES fromDisk:fromDisk withCompletion:completion];
}

- (void)removeImageForKey:(nullable NSString *)key fromMemory:(BOOL)fromMemory fromDisk:(BOOL)fromDisk withCompletion:(nullable BMSDWebImageNoParamsBlock)completion {
    if (key == nil) {
        return;
    }

    if (fromMemory && self.config.shouldCacheImagesInMemory) {
        [self.memoryCache removeObjectForKey:key];
    }

    if (fromDisk) {
        dispatch_async(self.ioQueue, ^{
            [self.diskCache removeDataForKey:key];
            
            if (completion) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion();
                });
            }
        });
    } else if (completion) {
        completion();
    }
}

- (void)removeImageFromMemoryForKey:(NSString *)key {
    if (!key) {
        return;
    }
    
    [self.memoryCache removeObjectForKey:key];
}

- (void)removeImageFromDiskForKey:(NSString *)key {
    if (!key) {
        return;
    }
    dispatch_sync(self.ioQueue, ^{
        [self _removeImageFromDiskForKey:key];
    });
}

// Make sure to call from io queue by caller
- (void)_removeImageFromDiskForKey:(NSString *)key {
    if (!key) {
        return;
    }
    
    [self.diskCache removeDataForKey:key];
}

#pragma mark - Cache clean Ops

- (void)clearMemory {
    [self.memoryCache removeAllObjects];
}

- (void)clearDiskOnCompletion:(nullable BMSDWebImageNoParamsBlock)completion {
    dispatch_async(self.ioQueue, ^{
        [self.diskCache removeAllData];
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion();
            });
        }
    });
}

- (void)deleteOldFilesWithCompletionBlock:(nullable BMSDWebImageNoParamsBlock)completionBlock {
    dispatch_async(self.ioQueue, ^{
        [self.diskCache removeExpiredData];
        if (completionBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock();
            });
        }
    });
}

#pragma mark - UIApplicationWillTerminateNotification

#if BMSD_UIKIT || BMSD_MAC
- (void)applicationWillTerminate:(NSNotification *)notification {
    [self deleteOldFilesWithCompletionBlock:nil];
}
#endif

#pragma mark - UIApplicationDidEnterBackgroundNotification

#if BMSD_UIKIT
- (void)applicationDidEnterBackground:(NSNotification *)notification {
    if (!self.config.shouldRemoveExpiredDataWhenEnterBackground) {
        return;
    }
    Class UIApplicationClass = NSClassFromString(@"UIApplication");
    if(!UIApplicationClass || ![UIApplicationClass respondsToSelector:@selector(sharedApplication)]) {
        return;
    }
    UIApplication *application = [UIApplication performSelector:@selector(sharedApplication)];
    __block UIBackgroundTaskIdentifier bgTask = [application beginBackgroundTaskWithExpirationHandler:^{
        // Clean up any unfinished task business by marking where you
        // stopped or ending the task outright.
        [application endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];

    // Start the long-running task and return immediately.
    [self deleteOldFilesWithCompletionBlock:^{
        [application endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
}
#endif

#pragma mark - Cache Info

- (NSUInteger)totalDiskSize {
    __block NSUInteger size = 0;
    dispatch_sync(self.ioQueue, ^{
        size = [self.diskCache totalSize];
    });
    return size;
}

- (NSUInteger)totalDiskCount {
    __block NSUInteger count = 0;
    dispatch_sync(self.ioQueue, ^{
        count = [self.diskCache totalCount];
    });
    return count;
}

- (void)calculateSizeWithCompletionBlock:(nullable BMSDImageCacheCalculateSizeBlock)completionBlock {
    dispatch_async(self.ioQueue, ^{
        NSUInteger fileCount = [self.diskCache totalCount];
        NSUInteger totalSize = [self.diskCache totalSize];
        if (completionBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(fileCount, totalSize);
            });
        }
    });
}

#pragma mark - Helper
+ (BMSDWebImageOptions)imageOptionsFromCacheOptions:(BMSDImageCacheOptions)cacheOptions {
    BMSDWebImageOptions options = 0;
    if (cacheOptions & BMSDImageCacheScaleDownLargeImages) options |= BMSDWebImageScaleDownLargeImages;
    if (cacheOptions & BMSDImageCacheDecodeFirstFrameOnly) options |= BMSDWebImageDecodeFirstFrameOnly;
    if (cacheOptions & BMSDImageCachePreloadAllFrames) options |= BMSDWebImagePreloadAllFrames;
    if (cacheOptions & BMSDImageCacheAvoidDecodeImage) options |= BMSDWebImageAvoidDecodeImage;
    if (cacheOptions & BMSDImageCacheMatchAnimatedImageClass) options |= BMSDWebImageMatchAnimatedImageClass;
    
    return options;
}

@end

@implementation BMSDImageCache (SDImageCache)

#pragma mark - SDImageCache

- (id<BMSDWebImageOperation>)queryImageForKey:(NSString *)key options:(BMSDWebImageOptions)options context:(nullable BMSDWebImageContext *)context completion:(nullable BMSDImageCacheQueryCompletionBlock)completionBlock {
    return [self queryImageForKey:key options:options context:context cacheType:BMSDImageCacheTypeAll completion:completionBlock];
}

- (id<BMSDWebImageOperation>)queryImageForKey:(NSString *)key options:(BMSDWebImageOptions)options context:(nullable BMSDWebImageContext *)context cacheType:(BMSDImageCacheType)cacheType completion:(nullable BMSDImageCacheQueryCompletionBlock)completionBlock {
    BMSDImageCacheOptions cacheOptions = 0;
    if (options & BMSDWebImageQueryMemoryData) cacheOptions |= BMSDImageCacheQueryMemoryData;
    if (options & BMSDWebImageQueryMemoryDataSync) cacheOptions |= BMSDImageCacheQueryMemoryDataSync;
    if (options & BMSDWebImageQueryDiskDataSync) cacheOptions |= BMSDImageCacheQueryDiskDataSync;
    if (options & BMSDWebImageScaleDownLargeImages) cacheOptions |= BMSDImageCacheScaleDownLargeImages;
    if (options & BMSDWebImageAvoidDecodeImage) cacheOptions |= BMSDImageCacheAvoidDecodeImage;
    if (options & BMSDWebImageDecodeFirstFrameOnly) cacheOptions |= BMSDImageCacheDecodeFirstFrameOnly;
    if (options & BMSDWebImagePreloadAllFrames) cacheOptions |= BMSDImageCachePreloadAllFrames;
    if (options & BMSDWebImageMatchAnimatedImageClass) cacheOptions |= BMSDImageCacheMatchAnimatedImageClass;
    
    return [self queryCacheOperationForKey:key options:cacheOptions context:context cacheType:cacheType done:completionBlock];
}

- (void)storeImage:(UIImage *)image imageData:(NSData *)imageData forKey:(nullable NSString *)key cacheType:(BMSDImageCacheType)cacheType completion:(nullable BMSDWebImageNoParamsBlock)completionBlock {
    switch (cacheType) {
        case BMSDImageCacheTypeNone: {
            [self storeImage:image imageData:imageData forKey:key toMemory:NO toDisk:NO completion:completionBlock];
        }
            break;
        case BMSDImageCacheTypeMemory: {
            [self storeImage:image imageData:imageData forKey:key toMemory:YES toDisk:NO completion:completionBlock];
        }
            break;
        case BMSDImageCacheTypeDisk: {
            [self storeImage:image imageData:imageData forKey:key toMemory:NO toDisk:YES completion:completionBlock];
        }
            break;
        case BMSDImageCacheTypeAll: {
            [self storeImage:image imageData:imageData forKey:key toMemory:YES toDisk:YES completion:completionBlock];
        }
            break;
        default: {
            if (completionBlock) {
                completionBlock();
            }
        }
            break;
    }
}

- (void)removeImageForKey:(NSString *)key cacheType:(BMSDImageCacheType)cacheType completion:(nullable BMSDWebImageNoParamsBlock)completionBlock {
    switch (cacheType) {
        case BMSDImageCacheTypeNone: {
            [self removeImageForKey:key fromMemory:NO fromDisk:NO withCompletion:completionBlock];
        }
            break;
        case BMSDImageCacheTypeMemory: {
            [self removeImageForKey:key fromMemory:YES fromDisk:NO withCompletion:completionBlock];
        }
            break;
        case BMSDImageCacheTypeDisk: {
            [self removeImageForKey:key fromMemory:NO fromDisk:YES withCompletion:completionBlock];
        }
            break;
        case BMSDImageCacheTypeAll: {
            [self removeImageForKey:key fromMemory:YES fromDisk:YES withCompletion:completionBlock];
        }
            break;
        default: {
            if (completionBlock) {
                completionBlock();
            }
        }
            break;
    }
}

- (void)containsImageForKey:(NSString *)key cacheType:(BMSDImageCacheType)cacheType completion:(nullable BMSDImageCacheContainsCompletionBlock)completionBlock {
    switch (cacheType) {
        case BMSDImageCacheTypeNone: {
            if (completionBlock) {
                completionBlock(BMSDImageCacheTypeNone);
            }
        }
            break;
        case BMSDImageCacheTypeMemory: {
            BOOL isInMemoryCache = ([self imageFromMemoryCacheForKey:key] != nil);
            if (completionBlock) {
                completionBlock(isInMemoryCache ? BMSDImageCacheTypeMemory : BMSDImageCacheTypeNone);
            }
        }
            break;
        case BMSDImageCacheTypeDisk: {
            [self diskImageExistsWithKey:key completion:^(BOOL isInDiskCache) {
                if (completionBlock) {
                    completionBlock(isInDiskCache ? BMSDImageCacheTypeDisk : BMSDImageCacheTypeNone);
                }
            }];
        }
            break;
        case BMSDImageCacheTypeAll: {
            BOOL isInMemoryCache = ([self imageFromMemoryCacheForKey:key] != nil);
            if (isInMemoryCache) {
                if (completionBlock) {
                    completionBlock(BMSDImageCacheTypeMemory);
                }
                return;
            }
            [self diskImageExistsWithKey:key completion:^(BOOL isInDiskCache) {
                if (completionBlock) {
                    completionBlock(isInDiskCache ? BMSDImageCacheTypeDisk : BMSDImageCacheTypeNone);
                }
            }];
        }
            break;
        default:
            if (completionBlock) {
                completionBlock(BMSDImageCacheTypeNone);
            }
            break;
    }
}

- (void)clearWithCacheType:(BMSDImageCacheType)cacheType completion:(BMSDWebImageNoParamsBlock)completionBlock {
    switch (cacheType) {
        case BMSDImageCacheTypeNone: {
            if (completionBlock) {
                completionBlock();
            }
        }
            break;
        case BMSDImageCacheTypeMemory: {
            [self clearMemory];
            if (completionBlock) {
                completionBlock();
            }
        }
            break;
        case BMSDImageCacheTypeDisk: {
            [self clearDiskOnCompletion:completionBlock];
        }
            break;
        case BMSDImageCacheTypeAll: {
            [self clearMemory];
            [self clearDiskOnCompletion:completionBlock];
        }
            break;
        default: {
            if (completionBlock) {
                completionBlock();
            }
        }
            break;
    }
}

@end

