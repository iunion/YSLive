/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "BMSDWebImageOptionsProcessor.h"

@interface BMSDWebImageOptionsResult ()

@property (nonatomic, assign) BMSDWebImageOptions options;
@property (nonatomic, copy, nullable) BMSDWebImageContext *context;

@end

@implementation BMSDWebImageOptionsResult

- (instancetype)initWithOptions:(BMSDWebImageOptions)options context:(BMSDWebImageContext *)context {
    self = [super init];
    if (self) {
        self.options = options;
        self.context = context;
    }
    return self;
}

@end

@interface BMSDWebImageOptionsProcessor ()

@property (nonatomic, copy, nonnull) BMSDWebImageOptionsProcessorBlock block;

@end

@implementation BMSDWebImageOptionsProcessor

- (instancetype)initWithBlock:(BMSDWebImageOptionsProcessorBlock)block {
    self = [super init];
    if (self) {
        self.block = block;
    }
    return self;
}

+ (instancetype)optionsProcessorWithBlock:(BMSDWebImageOptionsProcessorBlock)block {
    BMSDWebImageOptionsProcessor *optionsProcessor = [[BMSDWebImageOptionsProcessor alloc] initWithBlock:block];
    return optionsProcessor;
}

- (BMSDWebImageOptionsResult *)processedResultForURL:(NSURL *)url options:(BMSDWebImageOptions)options context:(BMSDWebImageContext *)context {
    if (!self.block) {
        return nil;
    }
    return self.block(url, options, context);
}

@end
