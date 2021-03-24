/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "BMSDWebImageCacheKeyFilter.h"

@interface BMSDWebImageCacheKeyFilter ()

@property (nonatomic, copy, nonnull) BMSDWebImageCacheKeyFilterBlock block;

@end

@implementation BMSDWebImageCacheKeyFilter

- (instancetype)initWithBlock:(BMSDWebImageCacheKeyFilterBlock)block {
    self = [super init];
    if (self) {
        self.block = block;
    }
    return self;
}

+ (instancetype)cacheKeyFilterWithBlock:(BMSDWebImageCacheKeyFilterBlock)block {
    BMSDWebImageCacheKeyFilter *cacheKeyFilter = [[BMSDWebImageCacheKeyFilter alloc] initWithBlock:block];
    return cacheKeyFilter;
}

- (NSString *)cacheKeyForURL:(NSURL *)url {
    if (!self.block) {
        return nil;
    }
    return self.block(url);
}

@end
