/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import <Foundation/Foundation.h>
#import "BMSDImageIOAnimatedCoder.h"

/**
 Built in coder using ImageIO that supports APNG encoding/decoding
 */
@interface BMSDImageAPNGCoder : BMSDImageIOAnimatedCoder <BMSDProgressiveImageCoder, BMSDAnimatedImageCoder>

@property (nonatomic, class, readonly, nonnull) BMSDImageAPNGCoder *sharedCoder;

@end
