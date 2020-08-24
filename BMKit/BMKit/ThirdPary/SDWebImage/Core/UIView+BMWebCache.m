/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "UIView+BMWebCache.h"
#import "objc/runtime.h"
#import "UIView+BMWebCacheOperation.h"
#import "BMSDWebImageError.h"
#import "BMSDInternalMacros.h"
#import "BMSDWebImageTransitionInternal.h"

const int64_t BMSDWebImageProgressUnitCountUnknown = 1LL;

@implementation UIView (BMWebCache)

- (nullable NSURL *)bmsd_imageURL {
    return objc_getAssociatedObject(self, @selector(bmsd_imageURL));
}

- (void)setBmsd_imageURL:(NSURL * _Nullable)bmsd_imageURL {
    objc_setAssociatedObject(self, @selector(bmsd_imageURL), bmsd_imageURL, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (nullable NSString *)bmsd_latestOperationKey {
    return objc_getAssociatedObject(self, @selector(bmsd_latestOperationKey));
}

- (void)setBmsd_latestOperationKey:(NSString * _Nullable)bmsd_latestOperationKey {
    objc_setAssociatedObject(self, @selector(bmsd_latestOperationKey), bmsd_latestOperationKey, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSProgress *)bmsd_imageProgress {
    NSProgress *progress = objc_getAssociatedObject(self, @selector(bmsd_imageProgress));
    if (!progress) {
        progress = [[NSProgress alloc] initWithParent:nil userInfo:nil];
        self.bmsd_imageProgress = progress;
    }
    return progress;
}

- (void)setBmsd_imageProgress:(NSProgress *)bmsd_imageProgress {
    objc_setAssociatedObject(self, @selector(bmsd_imageProgress), bmsd_imageProgress, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)bmsd_internalSetImageWithURL:(nullable NSURL *)url
                  placeholderImage:(nullable UIImage *)placeholder
                           options:(BMSDWebImageOptions)options
                           context:(nullable BMSDWebImageContext *)context
                     setImageBlock:(nullable BMSDSetImageBlock)setImageBlock
                          progress:(nullable BMSDImageLoaderProgressBlock)progressBlock
                         completed:(nullable BMSDInternalCompletionBlock)completedBlock {
    if (context) {
        // copy to avoid mutable object
        context = [context copy];
    } else {
        context = [NSDictionary dictionary];
    }
    NSString *validOperationKey = context[BMSDWebImageContextSetImageOperationKey];
    if (!validOperationKey) {
        // pass through the operation key to downstream, which can used for tracing operation or image view class
        validOperationKey = NSStringFromClass([self class]);
        BMSDWebImageMutableContext *mutableContext = [context mutableCopy];
        mutableContext[BMSDWebImageContextSetImageOperationKey] = validOperationKey;
        context = [mutableContext copy];
    }
    self.bmsd_latestOperationKey = validOperationKey;
    [self bmsd_cancelImageLoadOperationWithKey:validOperationKey];
    self.bmsd_imageURL = url;
    
    if (!(options & BMSDWebImageDelayPlaceholder)) {
        dispatch_main_async_bmsafe(^{
            [self bmsd_setImage:placeholder imageData:nil basedOnClassOrViaCustomSetImageBlock:setImageBlock cacheType:BMSDImageCacheTypeNone imageURL:url];
        });
    }
    
    if (url) {
        // reset the progress
        NSProgress *imageProgress = objc_getAssociatedObject(self, @selector(bmsd_imageProgress));
        if (imageProgress) {
            imageProgress.totalUnitCount = 0;
            imageProgress.completedUnitCount = 0;
        }
        
#if BMSD_UIKIT || BMSD_MAC
        // check and start image indicator
        [self bmsd_startImageIndicator];
        id<BMSDWebImageIndicator> imageIndicator = self.bmsd_imageIndicator;
#endif
        BMSDWebImageManager *manager = context[BMSDWebImageContextCustomManager];
        if (!manager) {
            manager = [BMSDWebImageManager sharedManager];
        } else {
            // remove this manager to avoid retain cycle (manger -> loader -> operation -> context -> manager)
            BMSDWebImageMutableContext *mutableContext = [context mutableCopy];
            mutableContext[BMSDWebImageContextCustomManager] = nil;
            context = [mutableContext copy];
        }
        
        BMSDImageLoaderProgressBlock combinedProgressBlock = ^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
            if (imageProgress) {
                imageProgress.totalUnitCount = expectedSize;
                imageProgress.completedUnitCount = receivedSize;
            }
#if BMSD_UIKIT || BMSD_MAC
            if ([imageIndicator respondsToSelector:@selector(updateIndicatorProgress:)]) {
                double progress = 0;
                if (expectedSize != 0) {
                    progress = (double)receivedSize / expectedSize;
                }
                progress = MAX(MIN(progress, 1), 0); // 0.0 - 1.0
                dispatch_async(dispatch_get_main_queue(), ^{
                    [imageIndicator updateIndicatorProgress:progress];
                });
            }
#endif
            if (progressBlock) {
                progressBlock(receivedSize, expectedSize, targetURL);
            }
        };
        @bmweakify(self);
        id <BMSDWebImageOperation> operation = [manager loadImageWithURL:url options:options context:context progress:combinedProgressBlock completed:^(UIImage *image, NSData *data, NSError *error, BMSDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            @bmstrongify(self);
            if (!self) { return; }
            // if the progress not been updated, mark it to complete state
            if (imageProgress && finished && !error && imageProgress.totalUnitCount == 0 && imageProgress.completedUnitCount == 0) {
                imageProgress.totalUnitCount = BMSDWebImageProgressUnitCountUnknown;
                imageProgress.completedUnitCount = BMSDWebImageProgressUnitCountUnknown;
            }
            
#if BMSD_UIKIT || BMSD_MAC
            // check and stop image indicator
            if (finished) {
                [self bmsd_stopImageIndicator];
            }
#endif
            
            BOOL shouldCallCompletedBlock = finished || (options & BMSDWebImageAvoidAutoSetImage);
            BOOL shouldNotSetImage = ((image && (options & BMSDWebImageAvoidAutoSetImage)) ||
                                      (!image && !(options & BMSDWebImageDelayPlaceholder)));
            BMSDWebImageNoParamsBlock callCompletedBlockClojure = ^{
                if (!self) { return; }
                if (!shouldNotSetImage) {
                    [self bmsd_setNeedsLayout];
                }
                if (completedBlock && shouldCallCompletedBlock) {
                    completedBlock(image, data, error, cacheType, finished, url);
                }
            };
            
            // case 1a: we got an image, but the SDWebImageAvoidAutoSetImage flag is set
            // OR
            // case 1b: we got no image and the SDWebImageDelayPlaceholder is not set
            if (shouldNotSetImage) {
                dispatch_main_async_bmsafe(callCompletedBlockClojure);
                return;
            }
            
            UIImage *targetImage = nil;
            NSData *targetData = nil;
            if (image) {
                // case 2a: we got an image and the SDWebImageAvoidAutoSetImage is not set
                targetImage = image;
                targetData = data;
            } else if (options & BMSDWebImageDelayPlaceholder) {
                // case 2b: we got no image and the SDWebImageDelayPlaceholder flag is set
                targetImage = placeholder;
                targetData = nil;
            }
            
#if BMSD_UIKIT || BMSD_MAC
            // check whether we should use the image transition
            BMSDWebImageTransition *transition = nil;
            if (finished && (options & BMSDWebImageForceTransition || cacheType == BMSDImageCacheTypeNone)) {
                transition = self.bmsd_imageTransition;
            }
#endif
            dispatch_main_async_bmsafe(^{
#if BMSD_UIKIT || BMSD_MAC
                [self bmsd_setImage:targetImage imageData:targetData basedOnClassOrViaCustomSetImageBlock:setImageBlock transition:transition cacheType:cacheType imageURL:imageURL];
#else
                [self bmsd_setImage:targetImage imageData:targetData basedOnClassOrViaCustomSetImageBlock:setImageBlock cacheType:cacheType imageURL:imageURL];
#endif
                callCompletedBlockClojure();
            });
        }];
        [self bmsd_setImageLoadOperation:operation forKey:validOperationKey];
    } else {
#if BMSD_UIKIT || BMSD_MAC
        [self bmsd_stopImageIndicator];
#endif
        dispatch_main_async_bmsafe(^{
            if (completedBlock) {
                NSError *error = [NSError errorWithDomain:BMSDWebImageErrorDomain code:BMSDWebImageErrorInvalidURL userInfo:@{NSLocalizedDescriptionKey : @"Image url is nil"}];
                completedBlock(nil, nil, error, BMSDImageCacheTypeNone, YES, url);
            }
        });
    }
}

- (void)bmsd_cancelCurrentImageLoad {
    [self bmsd_cancelImageLoadOperationWithKey:self.bmsd_latestOperationKey];
    self.bmsd_latestOperationKey = nil;
}

- (void)bmsd_setImage:(UIImage *)image imageData:(NSData *)imageData basedOnClassOrViaCustomSetImageBlock:(BMSDSetImageBlock)setImageBlock cacheType:(BMSDImageCacheType)cacheType imageURL:(NSURL *)imageURL {
#if BMSD_UIKIT || BMSD_MAC
    [self bmsd_setImage:image imageData:imageData basedOnClassOrViaCustomSetImageBlock:setImageBlock transition:nil cacheType:cacheType imageURL:imageURL];
#else
    // watchOS does not support view transition. Simplify the logic
    if (setImageBlock) {
        setImageBlock(image, imageData, cacheType, imageURL);
    } else if ([self isKindOfClass:[UIImageView class]]) {
        UIImageView *imageView = (UIImageView *)self;
        [imageView setImage:image];
    }
#endif
}

#if BMSD_UIKIT || BMSD_MAC
- (void)bmsd_setImage:(UIImage *)image imageData:(NSData *)imageData basedOnClassOrViaCustomSetImageBlock:(BMSDSetImageBlock)setImageBlock transition:(BMSDWebImageTransition *)transition cacheType:(BMSDImageCacheType)cacheType imageURL:(NSURL *)imageURL {
    UIView *view = self;
    BMSDSetImageBlock finalSetImageBlock;
    if (setImageBlock) {
        finalSetImageBlock = setImageBlock;
    } else if ([view isKindOfClass:[UIImageView class]]) {
        UIImageView *imageView = (UIImageView *)view;
        finalSetImageBlock = ^(UIImage *setImage, NSData *setImageData, BMSDImageCacheType setCacheType, NSURL *setImageURL) {
            imageView.image = setImage;
        };
    }
#if BMSD_UIKIT
    else if ([view isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton *)view;
        finalSetImageBlock = ^(UIImage *setImage, NSData *setImageData, BMSDImageCacheType setCacheType, NSURL *setImageURL) {
            [button setImage:setImage forState:UIControlStateNormal];
        };
    }
#endif
#if BMSD_MAC
    else if ([view isKindOfClass:[NSButton class]]) {
        NSButton *button = (NSButton *)view;
        finalSetImageBlock = ^(UIImage *setImage, NSData *setImageData, BMSDImageCacheType setCacheType, NSURL *setImageURL) {
            button.image = setImage;
        };
    }
#endif
    
    if (transition) {
#if BMSD_UIKIT
        [UIView transitionWithView:view duration:0 options:0 animations:^{
            if (!view.bmsd_latestOperationKey) {
                return;
            }
            // 0 duration to let UIKit render placeholder and prepares block
            if (transition.prepares) {
                transition.prepares(view, image, imageData, cacheType, imageURL);
            }
        } completion:^(BOOL finished) {
            [UIView transitionWithView:view duration:transition.duration options:transition.animationOptions animations:^{
                if (!view.bmsd_latestOperationKey) {
                    return;
                }
                if (finalSetImageBlock && !transition.avoidAutoSetImage) {
                    finalSetImageBlock(image, imageData, cacheType, imageURL);
                }
                if (transition.animations) {
                    transition.animations(view, image);
                }
            } completion:^(BOOL finished) {
                if (!view.bmsd_latestOperationKey) {
                    return;
                }
                if (transition.completion) {
                    transition.completion(finished);
                }
            }];
        }];
#elif BMSD_MAC
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull prepareContext) {
            if (!view.sd_latestOperationKey) {
                return;
            }
            // 0 duration to let AppKit render placeholder and prepares block
            prepareContext.duration = 0;
            if (transition.prepares) {
                transition.prepares(view, image, imageData, cacheType, imageURL);
            }
        } completionHandler:^{
            [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
                if (!view.sd_latestOperationKey) {
                    return;
                }
                context.duration = transition.duration;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                CAMediaTimingFunction *timingFunction = transition.timingFunction;
#pragma clang diagnostic pop
                if (!timingFunction) {
                    timingFunction = SDTimingFunctionFromAnimationOptions(transition.animationOptions);
                }
                context.timingFunction = timingFunction;
                context.allowsImplicitAnimation = SD_OPTIONS_CONTAINS(transition.animationOptions, SDWebImageAnimationOptionAllowsImplicitAnimation);
                if (finalSetImageBlock && !transition.avoidAutoSetImage) {
                    finalSetImageBlock(image, imageData, cacheType, imageURL);
                }
                CATransition *trans = SDTransitionFromAnimationOptions(transition.animationOptions);
                if (trans) {
                    [view.layer addAnimation:trans forKey:kCATransition];
                }
                if (transition.animations) {
                    transition.animations(view, image);
                }
            } completionHandler:^{
                if (!view.sd_latestOperationKey) {
                    return;
                }
                if (transition.completion) {
                    transition.completion(YES);
                }
            }];
        }];
#endif
    } else {
        if (finalSetImageBlock) {
            finalSetImageBlock(image, imageData, cacheType, imageURL);
        }
    }
}
#endif

- (void)bmsd_setNeedsLayout {
#if BMSD_UIKIT
    [self setNeedsLayout];
#elif BMSD_MAC
    [self setNeedsLayout:YES];
#elif BMSD_WATCH
    // Do nothing because WatchKit automatically layout the view after property change
#endif
}

#if BMSD_UIKIT || BMSD_MAC

#pragma mark - Image Transition
- (BMSDWebImageTransition *)bmsd_imageTransition {
    return objc_getAssociatedObject(self, @selector(bmsd_imageTransition));
}

- (void)setBmsd_imageTransition:(BMSDWebImageTransition *)bmsd_imageTransition {
    objc_setAssociatedObject(self, @selector(bmsd_imageTransition), bmsd_imageTransition, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - Indicator
- (id<BMSDWebImageIndicator>)bmsd_imageIndicator {
    return objc_getAssociatedObject(self, @selector(bmsd_imageIndicator));
}

- (void)setBmsd_imageIndicator:(id<BMSDWebImageIndicator>)bmsd_imageIndicator {
    // Remove the old indicator view
    id<BMSDWebImageIndicator> previousIndicator = self.bmsd_imageIndicator;
    [previousIndicator.indicatorView removeFromSuperview];
    
    objc_setAssociatedObject(self, @selector(bmsd_imageIndicator), bmsd_imageIndicator, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    // Add the new indicator view
    UIView *view = bmsd_imageIndicator.indicatorView;
    if (CGRectEqualToRect(view.frame, CGRectZero)) {
        view.frame = self.bounds;
    }
    // Center the indicator view
#if BMSD_MAC
    [view setFrameOrigin:CGPointMake(round((NSWidth(self.bounds) - NSWidth(view.frame)) / 2), round((NSHeight(self.bounds) - NSHeight(view.frame)) / 2))];
#else
    view.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
#endif
    view.hidden = NO;
    [self addSubview:view];
}

- (void)bmsd_startImageIndicator {
    id<BMSDWebImageIndicator> imageIndicator = self.bmsd_imageIndicator;
    if (!imageIndicator) {
        return;
    }
    dispatch_main_async_bmsafe(^{
        [imageIndicator startAnimatingIndicator];
    });
}

- (void)bmsd_stopImageIndicator {
    id<BMSDWebImageIndicator> imageIndicator = self.bmsd_imageIndicator;
    if (!imageIndicator) {
        return;
    }
    dispatch_main_async_bmsafe(^{
        [imageIndicator stopAnimatingIndicator];
    });
}

#endif

@end
