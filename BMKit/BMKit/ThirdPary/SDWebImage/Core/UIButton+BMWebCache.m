/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "UIButton+BMWebCache.h"

#if BMSD_UIKIT

#import "objc/runtime.h"
#import "UIView+BMWebCacheOperation.h"
#import "UIView+BMWebCache.h"
#import "BMSDInternalMacros.h"

static char imageBMURLStorageKey;

typedef NSMutableDictionary<NSString *, NSURL *> BMSDStateImageURLDictionary;

static inline NSString * imageBMURLKeyForState(UIControlState state) {
    return [NSString stringWithFormat:@"image_%lu", (unsigned long)state];
}

static inline NSString * backgroundImageBMURLKeyForState(UIControlState state) {
    return [NSString stringWithFormat:@"backgroundImage_%lu", (unsigned long)state];
}

static inline NSString * imageBMOperationKeyForState(UIControlState state) {
    return [NSString stringWithFormat:@"UIButtonImageOperation%lu", (unsigned long)state];
}

static inline NSString * backgroundImageBMOperationKeyForState(UIControlState state) {
    return [NSString stringWithFormat:@"UIButtonBackgroundImageOperation%lu", (unsigned long)state];
}

@implementation UIButton (BMWebCache)

#pragma mark - Image

- (nullable NSURL *)bmsd_currentImageURL {
    NSURL *url = self.bmsd_imageURLStorage[imageBMURLKeyForState(self.state)];

    if (!url) {
        url = self.bmsd_imageURLStorage[imageBMURLKeyForState(UIControlStateNormal)];
    }

    return url;
}

- (nullable NSURL *)bmsd_imageURLForState:(UIControlState)state {
    return self.bmsd_imageURLStorage[imageBMURLKeyForState(state)];
}

- (void)bmsd_setImageWithURL:(nullable NSURL *)url forState:(UIControlState)state {
    [self bmsd_setImageWithURL:url forState:state placeholderImage:nil options:0 completed:nil];
}

- (void)bmsd_setImageWithURL:(nullable NSURL *)url forState:(UIControlState)state placeholderImage:(nullable UIImage *)placeholder {
    [self bmsd_setImageWithURL:url forState:state placeholderImage:placeholder options:0 completed:nil];
}

- (void)bmsd_setImageWithURL:(nullable NSURL *)url forState:(UIControlState)state placeholderImage:(nullable UIImage *)placeholder options:(BMSDWebImageOptions)options {
    [self bmsd_setImageWithURL:url forState:state placeholderImage:placeholder options:options progress:nil completed:nil];
}

- (void)bmsd_setImageWithURL:(nullable NSURL *)url forState:(UIControlState)state placeholderImage:(nullable UIImage *)placeholder options:(BMSDWebImageOptions)options context:(nullable BMSDWebImageContext *)context {
    [self bmsd_setImageWithURL:url forState:state placeholderImage:placeholder options:options context:context progress:nil completed:nil];
}

- (void)bmsd_setImageWithURL:(nullable NSURL *)url forState:(UIControlState)state completed:(nullable BMSDExternalCompletionBlock)completedBlock {
    [self bmsd_setImageWithURL:url forState:state placeholderImage:nil options:0 completed:completedBlock];
}

- (void)bmsd_setImageWithURL:(nullable NSURL *)url forState:(UIControlState)state placeholderImage:(nullable UIImage *)placeholder completed:(nullable BMSDExternalCompletionBlock)completedBlock {
    [self bmsd_setImageWithURL:url forState:state placeholderImage:placeholder options:0 completed:completedBlock];
}

- (void)bmsd_setImageWithURL:(nullable NSURL *)url forState:(UIControlState)state placeholderImage:(nullable UIImage *)placeholder options:(BMSDWebImageOptions)options completed:(nullable BMSDExternalCompletionBlock)completedBlock {
    [self bmsd_setImageWithURL:url forState:state placeholderImage:placeholder options:options progress:nil completed:completedBlock];
}

- (void)bmsd_setImageWithURL:(nullable NSURL *)url forState:(UIControlState)state placeholderImage:(nullable UIImage *)placeholder options:(BMSDWebImageOptions)options progress:(nullable BMSDImageLoaderProgressBlock)progressBlock completed:(nullable BMSDExternalCompletionBlock)completedBlock {
    [self bmsd_setImageWithURL:url forState:state placeholderImage:placeholder options:options context:nil progress:progressBlock completed:completedBlock];
}

- (void)bmsd_setImageWithURL:(nullable NSURL *)url
                  forState:(UIControlState)state
          placeholderImage:(nullable UIImage *)placeholder
                   options:(BMSDWebImageOptions)options
                   context:(nullable BMSDWebImageContext *)context
                  progress:(nullable BMSDImageLoaderProgressBlock)progressBlock
                 completed:(nullable BMSDExternalCompletionBlock)completedBlock {
    if (!url) {
        [self.bmsd_imageURLStorage removeObjectForKey:imageBMURLKeyForState(state)];
    } else {
        self.bmsd_imageURLStorage[imageBMURLKeyForState(state)] = url;
    }
    
    BMSDWebImageMutableContext *mutableContext;
    if (context) {
        mutableContext = [context mutableCopy];
    } else {
        mutableContext = [NSMutableDictionary dictionary];
    }
    mutableContext[BMSDWebImageContextSetImageOperationKey] = imageBMOperationKeyForState(state);
    @bmweakify(self);
    [self bmsd_internalSetImageWithURL:url
                    placeholderImage:placeholder
                             options:options
                             context:mutableContext
                       setImageBlock:^(UIImage * _Nullable image, NSData * _Nullable imageData, BMSDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                           @bmstrongify(self);
                           [self setImage:image forState:state];
                       }
                            progress:progressBlock
                           completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BMSDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                               if (completedBlock) {
                                   completedBlock(image, error, cacheType, imageURL);
                               }
                           }];
}

#pragma mark - Background Image

- (nullable NSURL *)bmsd_currentBackgroundImageURL {
    NSURL *url = self.bmsd_imageURLStorage[backgroundImageBMURLKeyForState(self.state)];
    
    if (!url) {
        url = self.bmsd_imageURLStorage[backgroundImageBMURLKeyForState(UIControlStateNormal)];
    }
    
    return url;
}

- (nullable NSURL *)bmsd_backgroundImageURLForState:(UIControlState)state {
    return self.bmsd_imageURLStorage[backgroundImageBMURLKeyForState(state)];
}

- (void)bmsd_setBackgroundImageWithURL:(nullable NSURL *)url forState:(UIControlState)state {
    [self bmsd_setBackgroundImageWithURL:url forState:state placeholderImage:nil options:0 completed:nil];
}

- (void)bmsd_setBackgroundImageWithURL:(nullable NSURL *)url forState:(UIControlState)state placeholderImage:(nullable UIImage *)placeholder {
    [self bmsd_setBackgroundImageWithURL:url forState:state placeholderImage:placeholder options:0 completed:nil];
}

- (void)bmsd_setBackgroundImageWithURL:(nullable NSURL *)url forState:(UIControlState)state placeholderImage:(nullable UIImage *)placeholder options:(BMSDWebImageOptions)options {
    [self bmsd_setBackgroundImageWithURL:url forState:state placeholderImage:placeholder options:options progress:nil completed:nil];
}

- (void)bmsd_setBackgroundImageWithURL:(nullable NSURL *)url forState:(UIControlState)state placeholderImage:(nullable UIImage *)placeholder options:(BMSDWebImageOptions)options context:(nullable BMSDWebImageContext *)context {
    [self bmsd_setBackgroundImageWithURL:url forState:state placeholderImage:placeholder options:options context:context progress:nil completed:nil];
}

- (void)bmsd_setBackgroundImageWithURL:(nullable NSURL *)url forState:(UIControlState)state completed:(nullable BMSDExternalCompletionBlock)completedBlock {
    [self bmsd_setBackgroundImageWithURL:url forState:state placeholderImage:nil options:0 completed:completedBlock];
}

- (void)bmsd_setBackgroundImageWithURL:(nullable NSURL *)url forState:(UIControlState)state placeholderImage:(nullable UIImage *)placeholder completed:(nullable BMSDExternalCompletionBlock)completedBlock {
    [self bmsd_setBackgroundImageWithURL:url forState:state placeholderImage:placeholder options:0 completed:completedBlock];
}

- (void)bmsd_setBackgroundImageWithURL:(nullable NSURL *)url forState:(UIControlState)state placeholderImage:(nullable UIImage *)placeholder options:(BMSDWebImageOptions)options completed:(nullable BMSDExternalCompletionBlock)completedBlock {
    [self bmsd_setBackgroundImageWithURL:url forState:state placeholderImage:placeholder options:options progress:nil completed:completedBlock];
}

- (void)bmsd_setBackgroundImageWithURL:(nullable NSURL *)url forState:(UIControlState)state placeholderImage:(nullable UIImage *)placeholder options:(BMSDWebImageOptions)options progress:(nullable BMSDImageLoaderProgressBlock)progressBlock completed:(nullable BMSDExternalCompletionBlock)completedBlock {
    [self bmsd_setBackgroundImageWithURL:url forState:state placeholderImage:placeholder options:options context:nil progress:progressBlock completed:completedBlock];
}

- (void)bmsd_setBackgroundImageWithURL:(nullable NSURL *)url
                            forState:(UIControlState)state
                    placeholderImage:(nullable UIImage *)placeholder
                             options:(BMSDWebImageOptions)options
                             context:(nullable BMSDWebImageContext *)context
                            progress:(nullable BMSDImageLoaderProgressBlock)progressBlock
                           completed:(nullable BMSDExternalCompletionBlock)completedBlock {
    if (!url) {
        [self.bmsd_imageURLStorage removeObjectForKey:backgroundImageBMURLKeyForState(state)];
    } else {
        self.bmsd_imageURLStorage[backgroundImageBMURLKeyForState(state)] = url;
    }
    
    BMSDWebImageMutableContext *mutableContext;
    if (context) {
        mutableContext = [context mutableCopy];
    } else {
        mutableContext = [NSMutableDictionary dictionary];
    }
    mutableContext[BMSDWebImageContextSetImageOperationKey] = backgroundImageBMOperationKeyForState(state);
    @bmweakify(self);
    [self bmsd_internalSetImageWithURL:url
                    placeholderImage:placeholder
                             options:options
                             context:mutableContext
                       setImageBlock:^(UIImage * _Nullable image, NSData * _Nullable imageData, BMSDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                           @bmstrongify(self);
                           [self setBackgroundImage:image forState:state];
                       }
                            progress:progressBlock
                           completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BMSDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                               if (completedBlock) {
                                   completedBlock(image, error, cacheType, imageURL);
                               }
                           }];
}

#pragma mark - Cancel

- (void)bmsd_cancelImageLoadForState:(UIControlState)state {
    [self bmsd_cancelImageLoadOperationWithKey:imageBMOperationKeyForState(state)];
}

- (void)bmsd_cancelBackgroundImageLoadForState:(UIControlState)state {
    [self bmsd_cancelImageLoadOperationWithKey:backgroundImageBMOperationKeyForState(state)];
}

#pragma mark - Private

- (BMSDStateImageURLDictionary *)bmsd_imageURLStorage {
    BMSDStateImageURLDictionary *storage = objc_getAssociatedObject(self, &imageBMURLStorageKey);
    if (!storage) {
        storage = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, &imageBMURLStorageKey, storage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }

    return storage;
}

@end

#endif
