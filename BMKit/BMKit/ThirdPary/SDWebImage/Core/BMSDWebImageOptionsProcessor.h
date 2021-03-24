/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import <Foundation/Foundation.h>
#import "BMSDWebImageCompat.h"
#import "BMSDWebImageDefine.h"

@class BMSDWebImageOptionsResult;

typedef BMSDWebImageOptionsResult * _Nullable(^BMSDWebImageOptionsProcessorBlock)(NSURL * _Nullable url, BMSDWebImageOptions options, BMSDWebImageContext * _Nullable context);

/**
 The options result contains both options and context.
 */
@interface BMSDWebImageOptionsResult : NSObject

/**
 WebCache options.
 */
@property (nonatomic, assign, readonly) BMSDWebImageOptions options;

/**
 Context options.
 */
@property (nonatomic, copy, readonly, nullable) BMSDWebImageContext *context;

/**
 Create a new options result.

 @param options options
 @param context context
 @return The options result contains both options and context.
 */
- (nonnull instancetype)initWithOptions:(BMSDWebImageOptions)options context:(nullable BMSDWebImageContext *)context;

@end

/**
 This is the protocol for options processor.
 Options processor can be used, to control the final result for individual image request's `SDWebImageOptions` and `SDWebImageContext`
 Implements the protocol to have a global control for each indivadual image request's option.
 */
@protocol BMSDWebImageOptionsProcessor <NSObject>

/**
 Return the processed options result for specify image URL, with its options and context

 @param url The URL to the image
 @param options A mask to specify options to use for this request
 @param context A context contains different options to perform specify changes or processes, see `SDWebImageContextOption`. This hold the extra objects which `options` enum can not hold.
 @return The processed result, contains both options and context
 */
- (nullable BMSDWebImageOptionsResult *)processedResultForURL:(nullable NSURL *)url
                                                    options:(BMSDWebImageOptions)options
                                                    context:(nullable BMSDWebImageContext *)context;

@end

/**
 A options processor class with block.
 */
@interface BMSDWebImageOptionsProcessor : NSObject<BMSDWebImageOptionsProcessor>

- (nonnull instancetype)initWithBlock:(nonnull BMSDWebImageOptionsProcessorBlock)block;
+ (nonnull instancetype)optionsProcessorWithBlock:(nonnull BMSDWebImageOptionsProcessorBlock)block;

@end
