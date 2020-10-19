/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "UIImageView+BMHighlightedWebCache.h"

#if BMSD_UIKIT

#import "UIView+BMWebCacheOperation.h"
#import "UIView+BMWebCache.h"
#import "BMSDInternalMacros.h"

static NSString * const BMSDHighlightedImageOperationKey = @"UIImageViewImageOperationHighlighted";

@implementation UIImageView (BMHighlightedWebCache)

- (void)bmsd_setHighlightedImageWithURL:(nullable NSURL *)url host:(nullable NSString *)host {
    [self bmsd_setHighlightedImageWithURL:url host:host options:0 progress:nil completed:nil];
}

- (void)bmsd_setHighlightedImageWithURL:(nullable NSURL *)url host:(nullable NSString *)host options:(BMSDWebImageOptions)options {
    [self bmsd_setHighlightedImageWithURL:url host:host options:options progress:nil completed:nil];
}

- (void)bmsd_setHighlightedImageWithURL:(nullable NSURL *)url host:(nullable NSString *)host options:(BMSDWebImageOptions)options context:(nullable BMSDWebImageContext *)context {
    [self bmsd_setHighlightedImageWithURL:url host:host options:options context:context progress:nil completed:nil];
}

- (void)bmsd_setHighlightedImageWithURL:(nullable NSURL *)url host:(nullable NSString *)host completed:(nullable BMSDExternalCompletionBlock)completedBlock {
    [self bmsd_setHighlightedImageWithURL:url host:host options:0 progress:nil completed:completedBlock];
}

- (void)bmsd_setHighlightedImageWithURL:(nullable NSURL *)url host:(nullable NSString *)host options:(BMSDWebImageOptions)options completed:(nullable BMSDExternalCompletionBlock)completedBlock {
    [self bmsd_setHighlightedImageWithURL:url host:host options:options progress:nil completed:completedBlock];
}

- (void)bmsd_setHighlightedImageWithURL:(NSURL *)url host:(nullable NSString *)host options:(BMSDWebImageOptions)options progress:(nullable BMSDImageLoaderProgressBlock)progressBlock completed:(nullable BMSDExternalCompletionBlock)completedBlock {
    [self bmsd_setHighlightedImageWithURL:url host:host options:options context:nil progress:progressBlock completed:completedBlock];
}

- (void)bmsd_setHighlightedImageWithURL:(nullable NSURL *)url
                                   host:(nullable NSString *)host
                              options:(BMSDWebImageOptions)options
                              context:(nullable BMSDWebImageContext *)context
                             progress:(nullable BMSDImageLoaderProgressBlock)progressBlock
                            completed:(nullable BMSDExternalCompletionBlock)completedBlock {
    @bmweakify(self);
    BMSDWebImageMutableContext *mutableContext;
    if (context) {
        mutableContext = [context mutableCopy];
    } else {
        mutableContext = [NSMutableDictionary dictionary];
    }
    mutableContext[BMSDWebImageContextSetImageOperationKey] = BMSDHighlightedImageOperationKey;
    [self bmsd_internalSetImageWithURL:url
                                  host:host
                    placeholderImage:nil
                             options:options
                             context:mutableContext
                       setImageBlock:^(UIImage * _Nullable image, NSData * _Nullable imageData, BMSDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                           @bmstrongify(self);
                           self.highlightedImage = image;
                       }
                            progress:progressBlock
                           completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BMSDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                               if (completedBlock) {
                                   completedBlock(image, error, cacheType, imageURL);
                               }
                           }];
}

@end

#endif
