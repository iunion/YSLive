/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "BMSDAnimatedImageView+WebCache.h"

#if BMSD_UIKIT || BMSD_MAC

#import "UIView+BMWebCache.h"
#import "BMSDAnimatedImage.h"

@implementation BMSDAnimatedImageView (WebCache)

- (void)bmsd_setImageWithURL:(nullable NSURL *)url {
    [self bmsd_setImageWithURL:url placeholderImage:nil options:0 progress:nil completed:nil];
}

- (void)bmsd_setImageWithURL:(nullable NSURL *)url placeholderImage:(nullable UIImage *)placeholder {
    [self bmsd_setImageWithURL:url placeholderImage:placeholder options:0 progress:nil completed:nil];
}

- (void)bmsd_setImageWithURL:(nullable NSURL *)url placeholderImage:(nullable UIImage *)placeholder options:(BMSDWebImageOptions)options {
    [self bmsd_setImageWithURL:url placeholderImage:placeholder options:options progress:nil completed:nil];
}

- (void)bmsd_setImageWithURL:(nullable NSURL *)url placeholderImage:(nullable UIImage *)placeholder options:(BMSDWebImageOptions)options context:(nullable BMSDWebImageContext *)context {
    [self bmsd_setImageWithURL:url placeholderImage:placeholder options:options context:context progress:nil completed:nil];
}

- (void)bmsd_setImageWithURL:(nullable NSURL *)url completed:(nullable BMSDExternalCompletionBlock)completedBlock {
    [self bmsd_setImageWithURL:url placeholderImage:nil options:0 progress:nil completed:completedBlock];
}

- (void)bmsd_setImageWithURL:(nullable NSURL *)url placeholderImage:(nullable UIImage *)placeholder completed:(nullable BMSDExternalCompletionBlock)completedBlock {
    [self bmsd_setImageWithURL:url placeholderImage:placeholder options:0 progress:nil completed:completedBlock];
}

- (void)bmsd_setImageWithURL:(nullable NSURL *)url placeholderImage:(nullable UIImage *)placeholder options:(BMSDWebImageOptions)options completed:(nullable BMSDExternalCompletionBlock)completedBlock {
    [self bmsd_setImageWithURL:url placeholderImage:placeholder options:options progress:nil completed:completedBlock];
}

- (void)bmsd_setImageWithURL:(nullable NSURL *)url placeholderImage:(nullable UIImage *)placeholder options:(BMSDWebImageOptions)options progress:(nullable BMSDImageLoaderProgressBlock)progressBlock completed:(nullable BMSDExternalCompletionBlock)completedBlock {
    [self bmsd_setImageWithURL:url placeholderImage:placeholder options:options context:nil progress:progressBlock completed:completedBlock];
}

- (void)bmsd_setImageWithURL:(nullable NSURL *)url
          placeholderImage:(nullable UIImage *)placeholder
                   options:(BMSDWebImageOptions)options
                   context:(nullable BMSDWebImageContext *)context
                  progress:(nullable BMSDImageLoaderProgressBlock)progressBlock
                 completed:(nullable BMSDExternalCompletionBlock)completedBlock {
    Class animatedImageClass = [BMSDAnimatedImage class];
    BMSDWebImageMutableContext *mutableContext;
    if (context) {
        mutableContext = [context mutableCopy];
    } else {
        mutableContext = [NSMutableDictionary dictionary];
    }
    mutableContext[BMSDWebImageContextAnimatedImageClass] = animatedImageClass;
    [self bmsd_internalSetImageWithURL:url
                    placeholderImage:placeholder
                             options:options
                             context:mutableContext
                       setImageBlock:nil
                            progress:progressBlock
                           completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BMSDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                               if (completedBlock) {
                                   completedBlock(image, error, cacheType, imageURL);
                               }
                           }];
}

@end

#endif
