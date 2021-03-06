/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "BMSDImageCacheConfig.h"
#import "BMSDMemoryCache.h"
#import "BMSDDiskCache.h"

#define DefaultBMCacheMaxDiskDay        (7)

static BMSDImageCacheConfig *_defaultBMCacheConfig;
//static const NSInteger kDefaultBMCacheMaxDiskAge = 60 * 60 * 24 * 7; // 1 week
static const NSInteger kDefaultBMCacheMaxDiskAge = 60 * 60 * 24 * DefaultBMCacheMaxDiskDay; // 1 week

@implementation BMSDImageCacheConfig

+ (BMSDImageCacheConfig *)defaultCacheConfig {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _defaultBMCacheConfig = [BMSDImageCacheConfig new];
    });
    return _defaultBMCacheConfig;
}

- (instancetype)init {
    if (self = [super init]) {
        _shouldDisableiCloud = YES;
        _shouldCacheImagesInMemory = YES;
        _shouldUseWeakMemoryCache = YES;
        _shouldRemoveExpiredDataWhenEnterBackground = YES;
        _shouldRemoveExpiredDataWhenTerminate = YES;
        _diskCacheReadingOptions = 0;
        _diskCacheWritingOptions = NSDataWritingAtomic;
        _maxDiskAge = kDefaultBMCacheMaxDiskAge;
        _maxDiskSize = 0;
        _diskCacheExpireType = BMSDImageCacheConfigExpireTypeModificationDate;
        _memoryCacheClass = [BMSDMemoryCache class];
        _diskCacheClass = [BMSDDiskCache class];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    BMSDImageCacheConfig *config = [[[self class] allocWithZone:zone] init];
    config.shouldDisableiCloud = self.shouldDisableiCloud;
    config.shouldCacheImagesInMemory = self.shouldCacheImagesInMemory;
    config.shouldUseWeakMemoryCache = self.shouldUseWeakMemoryCache;
    config.shouldRemoveExpiredDataWhenEnterBackground = self.shouldRemoveExpiredDataWhenEnterBackground;
    config.shouldRemoveExpiredDataWhenTerminate = self.shouldRemoveExpiredDataWhenTerminate;
    config.diskCacheReadingOptions = self.diskCacheReadingOptions;
    config.diskCacheWritingOptions = self.diskCacheWritingOptions;
    config.maxDiskAge = self.maxDiskAge;
    config.maxDiskSize = self.maxDiskSize;
    config.maxMemoryCost = self.maxMemoryCost;
    config.maxMemoryCount = self.maxMemoryCount;
    config.diskCacheExpireType = self.diskCacheExpireType;
    config.fileManager = self.fileManager; // NSFileManager does not conform to NSCopying, just pass the reference
    config.memoryCacheClass = self.memoryCacheClass;
    config.diskCacheClass = self.diskCacheClass;
    
    return config;
}

@end
