/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "UIImageView+BMWebCache.h"
#import "objc/runtime.h"
#import "UIView+BMWebCacheOperation.h"
#import "UIView+BMWebCache.h"

@implementation UIImageView (BMWebCache)

- (void)bmsd_setImageWithURL:(nullable NSURL *)url host:(nullable NSString *)host {
    [self bmsd_setImageWithURL:url host:host placeholderImage:nil options:0 progress:nil completed:nil];
}

- (void)bmsd_setImageWithURL:(nullable NSURL *)url host:(nullable NSString *)host placeholderImage:(nullable UIImage *)placeholder {
    [self bmsd_setImageWithURL:url host:host placeholderImage:placeholder options:0 progress:nil completed:nil];
}

- (void)bmsd_setImageWithURL:(nullable NSURL *)url host:(nullable NSString *)host placeholderImage:(nullable UIImage *)placeholder options:(BMSDWebImageOptions)options {
    [self bmsd_setImageWithURL:url host:host placeholderImage:placeholder options:options progress:nil completed:nil];
}

- (void)bmsd_setImageWithURL:(nullable NSURL *)url host:(nullable NSString *)host placeholderImage:(nullable UIImage *)placeholder options:(BMSDWebImageOptions)options context:(nullable BMSDWebImageContext *)context {
    [self bmsd_setImageWithURL:url host:host placeholderImage:placeholder options:options context:context progress:nil completed:nil];
}

- (void)bmsd_setImageWithURL:(nullable NSURL *)url host:(nullable NSString *)host completed:(nullable BMSDExternalCompletionBlock)completedBlock {
    [self bmsd_setImageWithURL:url host:host placeholderImage:nil options:0 progress:nil completed:completedBlock];
}

- (void)bmsd_setImageWithURL:(nullable NSURL *)url host:(nullable NSString *)host placeholderImage:(nullable UIImage *)placeholder completed:(nullable BMSDExternalCompletionBlock)completedBlock {
    [self bmsd_setImageWithURL:url host:host placeholderImage:placeholder options:0 progress:nil completed:completedBlock];
}

- (void)bmsd_setImageWithURL:(nullable NSURL *)url host:(nullable NSString *)host placeholderImage:(nullable UIImage *)placeholder options:(BMSDWebImageOptions)options completed:(nullable BMSDExternalCompletionBlock)completedBlock {
    [self bmsd_setImageWithURL:url host:host placeholderImage:placeholder options:options progress:nil completed:completedBlock];
}

- (void)bmsd_setImageWithURL:(nullable NSURL *)url host:(nullable NSString *)host placeholderImage:(nullable UIImage *)placeholder options:(BMSDWebImageOptions)options progress:(nullable BMSDImageLoaderProgressBlock)progressBlock completed:(nullable BMSDExternalCompletionBlock)completedBlock {
    [self bmsd_setImageWithURL:url host:host placeholderImage:placeholder options:options context:nil progress:progressBlock completed:completedBlock];
}

- (void)bmsd_setImageWithURL:(nullable NSURL *)url
                        host:(nullable NSString *)host
          placeholderImage:(nullable UIImage *)placeholder
                   options:(BMSDWebImageOptions)options
                   context:(nullable BMSDWebImageContext *)context
                  progress:(nullable BMSDImageLoaderProgressBlock)progressBlock
                 completed:(nullable BMSDExternalCompletionBlock)completedBlock {
    [self bmsd_internalSetImageWithURL:url
                                  host:host
                    placeholderImage:placeholder
                             options:options
                             context:context
                       setImageBlock:nil
                            progress:progressBlock
                           completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BMSDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                               if (completedBlock) {
                                   completedBlock(image, error, cacheType, imageURL);
                               }
                           }];
}

@end
