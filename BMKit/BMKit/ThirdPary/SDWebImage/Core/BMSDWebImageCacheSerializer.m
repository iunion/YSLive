/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "BMSDWebImageCacheSerializer.h"

@interface BMSDWebImageCacheSerializer ()

@property (nonatomic, copy, nonnull) BMSDWebImageCacheSerializerBlock block;

@end

@implementation BMSDWebImageCacheSerializer

- (instancetype)initWithBlock:(BMSDWebImageCacheSerializerBlock)block {
    self = [super init];
    if (self) {
        self.block = block;
    }
    return self;
}

+ (instancetype)cacheSerializerWithBlock:(BMSDWebImageCacheSerializerBlock)block {
    BMSDWebImageCacheSerializer *cacheSerializer = [[BMSDWebImageCacheSerializer alloc] initWithBlock:block];
    return cacheSerializer;
}

- (NSData *)cacheDataWithImage:(UIImage *)image originalData:(NSData *)data imageURL:(nullable NSURL *)imageURL {
    if (!self.block) {
        return nil;
    }
    return self.block(image, data, imageURL);
}

@end
