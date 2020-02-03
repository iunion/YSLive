/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "UIImageView+BMHighlightedWebCache.h"

#if SD_UIKIT

#import "UIView+BMWebCacheOperation.h"
#import "UIView+BMWebCache.h"

@implementation UIImageView (BMHighlightedWebCache)

- (void)bm_setHighlightedImageWithURL:(nullable NSURL *)url {
    [self bm_setHighlightedImageWithURL:url options:0 progress:nil completed:nil];
}

- (void)bm_setHighlightedImageWithURL:(nullable NSURL *)url options:(SDWebImageOptions)options {
    [self bm_setHighlightedImageWithURL:url options:options progress:nil completed:nil];
}

- (void)bm_setHighlightedImageWithURL:(nullable NSURL *)url completed:(nullable SDExternalCompletionBlock)completedBlock {
    [self bm_setHighlightedImageWithURL:url options:0 progress:nil completed:completedBlock];
}

- (void)bm_setHighlightedImageWithURL:(nullable NSURL *)url options:(SDWebImageOptions)options completed:(nullable SDExternalCompletionBlock)completedBlock {
    [self bm_setHighlightedImageWithURL:url options:options progress:nil completed:completedBlock];
}

- (void)bm_setHighlightedImageWithURL:(nullable NSURL *)url
                              options:(SDWebImageOptions)options
                             progress:(nullable SDWebImageDownloaderProgressBlock)progressBlock
                            completed:(nullable SDExternalCompletionBlock)completedBlock {
    __weak typeof(self)weakSelf = self;
    [self bm_internalSetImageWithURL:url
                    placeholderImage:nil
                             options:options
                        operationKey:@"UIImageViewImageOperationHighlighted"
                       setImageBlock:^(UIImage *image, NSData *imageData) {
                           weakSelf.highlightedImage = image;
                       }
                            progress:progressBlock
                           completed:completedBlock];
}

@end

#endif
